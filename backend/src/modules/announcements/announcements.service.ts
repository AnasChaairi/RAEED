import { Inject, Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { Queue } from 'bullmq';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';
import { CriticalJob, QUEUE_CRITICAL } from '../../common/queue/queues';
import { NotifyService } from '../notifications/notify.service';
import { AudienceDto, AudienceType, CreateAnnouncementDto } from './dto/announcement.dto';

/** The read model a guardian or educator receives. */
export interface AnnouncementView {
  id: string;
  title: string;
  body: string | null;
  priority: 'normal' | 'urgent';
  pinned: boolean;
  publish_at: string;
  ack_required: boolean;
  /** Whether the caller confirmed reading it (`ANN-06`). */
  confirmed: boolean;
}

/**
 * The executive's read model: adds who it went to and how many opened it.
 *
 * Only ever sent to an oversight caller. A guardian must not learn which
 * other families an announcement reached, and a read rate is a statistic
 * about other people.
 */
export interface ExecutiveAnnouncementView extends AnnouncementView {
  audience: { type: AudienceType; category_ids: string[]; group_ids: string[] };
  expire_at: string | null;
  is_draft: false;
  read_count: number;
  audience_count: number | null;
}

export interface ReachView {
  all: number;
  parents: number;
  educators: number;
  categories: Array<{ id: string; name: string; guardian_count: number }>;
  /** The caller's groups with their guardian counts — the educator's audience (`ANN-03`). */
  groups: Array<{ id: string; name: string; guardian_count: number }>;
}

interface AnnouncementRow {
  id: string;
  title: string;
  body: string | null;
  priority: 'normal' | 'urgent';
  pinned: boolean;
  publish_at: Date;
  expire_at: Date | null;
  audience_json: unknown;
  read_count: number;
  ack_required: boolean;
  confirmed: boolean;
}

/** Groups the caller may address, as a `where` fragment on alias `g`. */
interface Scope {
  readonly clause: string;
  readonly params: unknown[];
}

@Injectable()
export class AnnouncementsService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    @Inject(QUEUE_CRITICAL) private readonly criticalQueue: Queue,
    private readonly notify: NotifyService,
  ) {}

  /**
   * Announcements visible to the caller.
   *
   * Guardians and educators see what is live. An executive sees every state
   * — scheduled, expired, pinned — because the list is theirs to manage, and
   * each row carries its audience and read count.
   *
   * Audience targeting below `all` is evaluated association-wide for
   * non-oversight readers for now; per-group filtering lands with the rest
   * of Epic E.
   */
  async list(
    user: AuthenticatedUser,
  ): Promise<AnnouncementView[] | ExecutiveAnnouncementView[]> {
    const liveOnly = user.hasOversight
      ? ''
      : 'and publish_at <= now() and (expire_at is null or expire_at > now())';

    const rows: AnnouncementRow[] = await this.dataSource.query(
      `select a.id, a.title, a.body, a.priority, a.pinned, a.publish_at, a.expire_at,
              a.audience_json, a.ack_required,
              (select count(*) from announcement_read r
                where r.announcement_id = a.id)::int as read_count,
              exists (select 1 from announcement_read r
                       where r.announcement_id = a.id and r.user_id = $1 and r.confirmed_at is not null)
                as confirmed
         from announcement a
        where a.deleted_at is null ${liveOnly}
        order by a.pinned desc, a.publish_at desc
        limit 50`,
      [user.id],
    );

    if (!user.hasOversight) {
      return rows.map((row) => this.toView(row));
    }

    const reach = await this.reach(user);
    return rows.map((row) => {
      const audience = parseAudience(row.audience_json);
      return {
        ...this.toView(row),
        audience,
        expire_at: row.expire_at ? row.expire_at.toISOString() : null,
        is_draft: false,
        read_count: row.read_count,
        audience_count: audienceCount(audience, reach),
      };
    });
  }

  /**
   * How many people each audience reaches right now, in the caller's scope.
   *
   * Computed here rather than on the device so the number the executive
   * confirms on the urgent dialog is the number the send will reach.
   */
  async reach(user: AuthenticatedUser): Promise<ReachView> {
    const scope = this.scopeOf(user);

    const totals: Array<{ all_count: number; parents: number; educators: number }> =
      await this.dataSource.query(
        `${this.scopedCtes(scope)}
         select (select count(*) from (select user_id from guardians
                                       union select user_id from educators) u)::int as all_count,
                (select count(*) from guardians)::int as parents,
                (select count(*) from educators)::int as educators`,
        scope.params,
      );

    const categories: Array<{ id: string; name: string; guardian_count: number }> =
      await this.dataSource.query(
        `${this.scopedCtes(scope)}
         select cat.id, cat.name_ar as name,
                count(distinct pc.guardian_user_id)::int as guardian_count
           from category cat
           join "group" g on g.category_id = cat.id
           join scoped_groups sg on sg.id = g.id
           left join child_group cg on cg.group_id = g.id and cg.valid_to is null
           left join child c on c.id = cg.child_id and c.deleted_at is null
           left join parent_child pc on pc.child_id = c.id and pc.unlinked_at is null
          group by cat.id
          order by cat.name_ar`,
        scope.params,
      );

    const groups: Array<{ id: string; name: string; guardian_count: number }> =
      await this.dataSource.query(
        `${this.scopedCtes(scope)}
         select g.id, g.name, count(distinct pc.guardian_user_id)::int as guardian_count
           from "group" g
           join scoped_groups sg on sg.id = g.id
           left join child_group cg on cg.group_id = g.id and cg.valid_to is null
           left join child c on c.id = cg.child_id and c.deleted_at is null
           left join parent_child pc on pc.child_id = c.id and pc.unlinked_at is null
          group by g.id
          order by g.name`,
        scope.params,
      );

    const row = totals[0];
    return {
      all: row?.all_count ?? 0,
      parents: row?.parents ?? 0,
      educators: row?.educators ?? 0,
      categories,
      groups,
    };
  }

  /** "I have read this" (`ANN-06`); idempotent. */
  async confirmRead(user: AuthenticatedUser, announcementId: string): Promise<{ confirmed_at: string }> {
    const rows: Array<{ confirmed_at: Date }> = await this.dataSource.query(
      `insert into announcement_read (announcement_id, user_id, read_at, confirmed_at)
       select a.id, $2, now(), now() from announcement a
        where a.id = $1 and a.deleted_at is null
       on conflict (announcement_id, user_id)
         do update set confirmed_at = coalesce(announcement_read.confirmed_at, now())
       returning confirmed_at`,
      [announcementId, user.id],
    );
    if (rows.length === 0) throw ApiError.scopeForbidden('No such announcement.');
    return { confirmed_at: rows[0].confirmed_at.toISOString() };
  }

  /**
   * Publishes an announcement.
   *
   * An executive may target any audience in their branch scope. An educator
   * may only address their own groups (`ANN-03`), checked against the ability
   * model per group — never against the request's say-so. Urgent sends are
   * put on the critical lane before this returns, like an absence alert
   * (`specs/09-notifications-spec.md`).
   */
  async publish(
    user: AuthenticatedUser,
    input: CreateAnnouncementDto,
  ): Promise<{ id: string }> {
    this.assertMayAddress(user, input.audience);

    const priority = input.priority ?? 'normal';
    const audienceJson = {
      type: input.audience.type,
      category_ids: input.audience.category_ids ?? [],
      group_ids: input.audience.group_ids ?? [],
    };

    const id = await this.dataSource.transaction(async (tx) => {
      const rows: Array<{ id: string }> = await tx.query(
        `insert into announcement (author_id, title, body, audience_json, priority, expire_at, ack_required)
         values ($1, $2, $3, $4::jsonb, $5, $6, $7)
         returning id`,
        [
          user.id,
          input.title.trim(),
          input.body?.trim() || null,
          JSON.stringify(audienceJson),
          priority,
          input.expire_at ?? null,
          input.ack_required ?? false,
        ],
      );
      const announcementId = rows[0].id;

      // A group announcement tells the groups' guardians and co-educators
      // now; wider audiences are the executive's and go through the
      // announcement feed (urgent ones through the critical lane below).
      if (audienceJson.type === 'groups') {
        const recipients: string[] = [];
        for (const groupId of audienceJson.group_ids) {
          recipients.push(...(await this.notify.guardiansOfGroup(tx, groupId)));
          recipients.push(...(await this.notify.educatorsOfGroup(tx, groupId)));
        }
        await this.notify.notify(
          tx,
          recipients.filter((id) => id !== user.id),
          {
            kind: 'other',
            title: input.title.trim(),
            body: input.body?.trim() || null,
            destination: 'announcements',
            data: { type: 'announcement', announcement_id: announcementId },
          },
        );
      }

      // Publishing is recorded with its audience and priority: an urgent send
      // pages every recipient and costs the association SMS, and the brief
      // requires that to be traceable to a person.
      await tx.query(
        `insert into audit_log_entry
           (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'announcement.publish', 'announcement', $2, $3::jsonb)`,
        [user.id, announcementId, JSON.stringify({ audience: audienceJson, priority })],
      );
      return announcementId;
    });

    if (priority === 'urgent') {
      await this.criticalQueue.add(
        CriticalJob.URGENT_ANNOUNCEMENT,
        { announcementId: id },
        { jobId: `urgent-announcement-${id}` },
      );
    }

    return { id };
  }

  private assertMayAddress(user: AuthenticatedUser, audience: AudienceDto): void {
    const ability = defineAbilityFor(user);

    if (audience.type === 'groups') {
      const groupIds = audience.group_ids ?? [];
      if (groupIds.length === 0) throw ApiError.scopeForbidden('No group named.');
      for (const groupId of groupIds) {
        if (!ability.can('create', subject('Announcement', { groupId }))) {
          throw ApiError.scopeForbidden();
        }
      }
      return;
    }

    // Everything wider than a group is an oversight audience.
    const wide = subject(
      'Announcement',
      user.branchId ? { branchId: user.branchId } : {},
    );
    if (!user.hasOversight || !ability.can('create', wide)) {
      throw ApiError.scopeForbidden();
    }
  }

  private scopeOf(user: AuthenticatedUser): Scope {
    if (user.hasOversight) {
      return user.branchId
        ? { clause: 'and g.branch_id = $1', params: [user.branchId] }
        : { clause: '', params: [] };
    }
    return {
      clause: 'and g.id = any($1::uuid[])',
      params: [[...user.reachableGroupIds]],
    };
  }

  private scopedCtes(scope: Scope): string {
    return `with scoped_groups as (
              select g.id
                from "group" g
                join season se on se.id = g.season_id and se.status = 'active'
               where g.deleted_at is null ${scope.clause}
            ),
            scoped_children as (
              select distinct c.id
                from child c
                join child_group cg on cg.child_id = c.id and cg.valid_to is null
                join scoped_groups sg on sg.id = cg.group_id
               where c.deleted_at is null
            ),
            guardians as (
              select distinct pc.guardian_user_id as user_id
                from parent_child pc
                join scoped_children sc on sc.id = pc.child_id
               where pc.unlinked_at is null
            ),
            educators as (
              select distinct ge.educator_user_id as user_id
                from group_educator ge
                join scoped_groups sg on sg.id = ge.group_id
               where ge.unassigned_at is null
            )`;
  }

  private toView(row: AnnouncementRow): AnnouncementView {
    return {
      id: row.id,
      title: row.title,
      body: row.body,
      priority: row.priority,
      pinned: row.pinned,
      publish_at: row.publish_at.toISOString(),
      ack_required: row.ack_required,
      confirmed: row.confirmed,
    };
  }
}

/**
 * Reads `audience_json`, tolerating the `{"all": true}` shorthand the first
 * seed used before the composer existed.
 */
export function parseAudience(
  json: unknown,
): ExecutiveAnnouncementView['audience'] {
  const object =
    typeof json === 'object' && json !== null
      ? (json as Record<string, unknown>)
      : {};
  const type = object.type;
  const ids = (value: unknown): string[] =>
    Array.isArray(value) ? value.filter((v): v is string => typeof v === 'string') : [];

  if (
    type === 'parents' ||
    type === 'educators' ||
    type === 'categories' ||
    type === 'groups'
  ) {
    return {
      type,
      category_ids: ids(object.category_ids),
      group_ids: ids(object.group_ids),
    };
  }
  return { type: 'all', category_ids: [], group_ids: [] };
}

/** The number of people an audience reaches, from the caller's reach. */
export function audienceCount(
  audience: ExecutiveAnnouncementView['audience'],
  reach: ReachView,
): number | null {
  switch (audience.type) {
    case 'all':
      return reach.all;
    case 'parents':
      return reach.parents;
    case 'educators':
      return reach.educators;
    case 'categories':
      return reach.categories
        .filter((category) => audience.category_ids.includes(category.id))
        .reduce((sum, category) => sum + category.guardian_count, 0);
    case 'groups':
      // Per-group reach is not computed yet.
      return null;
  }
}
