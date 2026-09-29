import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { loadLocale, scheduleLabel } from '../../common/i18n/user-locale';
import { ApiError } from '../../common/http/api-error';
import { displayNameOf } from '../../common/sql/display-name';
import { SessionsService } from '../sessions/sessions.service';
import {
  AssignChildrenDto,
  CreateGroupDto,
  ScheduleSlotDto,
  UpdateGroupScheduleDto,
} from './dto/group.dto';

export interface GroupView {
  id: string;
  name: string;
  category: { id: string; name: string };
  enrolled_count: number;
  capacity: number | null;
  educators: Array<{ id: string; display_name: string }>;
  schedule_label: string | null;
  /** The slots behind the label, for the editor. */
  weekly_schedule: ScheduleSlotDto[];
  place: string | null;
  /** The educator's at-a-glance numbers (EDU-M-06); absent for oversight lists. */
  stats?: GroupStats;
}

export interface GroupStats {
  attendance: { present: number; expected: number };
  homework: { done: number; total: number };
  next_session_at: string | null;
  /** Children with three or more consecutive unexplained absences — a care flag, not a ranking. */
  flags: Array<{ child_id: string; full_name: string; consecutive_absences: number }>;
}

export interface RosterChildView {
  id: string;
  full_name: string;
  photo_url: string | null;
  health_alert: boolean;
  image_rights_level: 'allowed' | 'app_only' | 'not_allowed';
  attendance: { present: number; expected: number };
  consecutive_absences: number;
  is_new: boolean;
}

export interface GroupSessionView {
  id: string;
  group_id: string;
  title: string | null;
  starts_at: string;
  ends_at: string;
  status: 'planned' | 'delivered' | 'cancelled';
  attendance: {
    recorded: boolean;
    present_count: number | null;
    enrolled_count: number | null;
  };
}

interface GroupRow {
  id: string;
  name: string;
  capacity: number | null;
  branch_id: string;
  category_id: string;
  category_name: string;
  enrolled_count: number;
  educators: Array<{ id: string; display_name: string }>;
  weekly_schedule_json: unknown;
  place: string | null;
}

/**
 * Groups as the executive's list and the educator's own view read them.
 *
 * Scope is applied in the query: an executive sees the active season's
 * groups in their branch scope, an educator exactly the groups they lead
 * (`group_educator.unassigned_at is null`), and a parent nothing at all — the
 * ability model grants parents no `read` on `Group`, and the guard turns
 * that into a 403 before this runs.
 */
@Injectable()
export class GroupsService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly sessionsService: SessionsService,
  ) {}

  async list(user: AuthenticatedUser): Promise<GroupView[]> {
    const params: unknown[] = [];
    const where: string[] = ["g.deleted_at is null", "se.status = 'active'"];

    if (user.hasOversight) {
      if (user.branchId) {
        params.push(user.branchId);
        where.push(`g.branch_id = $${params.length}`);
      }
    } else {
      params.push([...user.reachableGroupIds]);
      where.push(`g.id = any($${params.length}::uuid[])`);
    }

    const rows = await this.query(where, params, 'order by g.name, g.id');
    const locale = await loadLocale(this.dataSource, user.id);
    const views = rows.map((row) => this.toView(row, locale));
    if (user.hasOversight) return views;

    // The educator's cards carry their numbers; an executive's list has
    // its own dashboard for that and stays lean.
    const stats = await this.stats(rows.map((row) => row.id));
    return views.map((view) => ({ ...view, stats: stats.get(view.id) }));
  }

  /** The children currently in a group, as the educator's roster shows them. */
  async roster(user: AuthenticatedUser, groupId: string): Promise<RosterChildView[]> {
    const group = await this.loadReadable(user, groupId);
    const rows: Array<{
      id: string;
      full_name: string;
      photo_url: string | null;
      health_alert: boolean;
      image_rights_level: RosterChildView['image_rights_level'] | null;
      present: number;
      expected: number;
      consecutive_absences: number;
      is_new: boolean;
    }> = await this.dataSource.query(
      `select c.id, c.full_name, c.photo_url,
              (c.health_json is not null and c.health_json <> '{}'::jsonb) as health_alert,
              (select case when bool_or(l.level = 'not_allowed') then 'not_allowed'
                           when bool_or(l.level = 'app_only') then 'app_only'
                           when count(*) > 0 then 'allowed' end
                 from (select distinct on (cr.guardian_id) cr.level
                         from consent_record cr
                        where cr.child_id = c.id and cr.type = 'image_rights' and cr.level is not null
                        order by cr.guardian_id, cr.effective_at desc) l) as image_rights_level,
              (select count(*) from attendance_record ar
                 join session s on s.id = ar.session_id
                where ar.child_id = c.id and s.group_id = $1 and ar.superseded_at is null
                  and ar.status in ('present', 'late') and s.deleted_at is null
                  and s.starts_at >= cg.valid_from)::int as present,
              (select count(*) from session s
                where s.group_id = $1 and s.deleted_at is null and s.status <> 'cancelled'
                  and s.ends_at < now() and s.starts_at >= cg.valid_from)::int as expected,
              (select count(*) from (
                 select ar.status
                   from session s
                   left join attendance_record ar on ar.session_id = s.id and ar.child_id = c.id
                                                 and ar.superseded_at is null
                  where s.group_id = $1 and s.deleted_at is null and s.status <> 'cancelled'
                    and s.ends_at < now() and s.starts_at >= cg.valid_from
                  order by s.starts_at desc
                  limit 3) last3
                where last3.status = 'absent')::int as consecutive_absences,
              (cg.valid_from > now() - interval '14 days') as is_new
         from child_group cg
         join child c on c.id = cg.child_id and c.deleted_at is null
        where cg.group_id = $1 and cg.valid_to is null
        order by c.full_name, c.id`,
      [group.id],
    );
    return rows.map((row) => ({
      id: row.id,
      full_name: row.full_name,
      photo_url: row.photo_url,
      health_alert: row.health_alert,
      image_rights_level: row.image_rights_level ?? 'not_allowed',
      attendance: { present: row.present, expected: row.expected },
      // Three of the last three: a streak, not a count.
      consecutive_absences: row.consecutive_absences >= 3 ? 3 : 0,
      is_new: row.is_new,
    }));
  }

  private async stats(groupIds: string[]): Promise<Map<string, GroupStats>> {
    const result = new Map<string, GroupStats>();
    if (groupIds.length === 0) return result;
    const rows: Array<{
      group_id: string;
      present: number;
      expected: number;
      hw_done: number;
      hw_total: number;
      next_session_at: Date | null;
      flags: GroupStats['flags'];
    }> = await this.dataSource.query(
      `select g.id as group_id,
              (select count(*) from attendance_record ar
                 join session s on s.id = ar.session_id
                where s.group_id = g.id and s.deleted_at is null and ar.superseded_at is null
                  and ar.status in ('present', 'late'))::int as present,
              (select count(*) from session s
                 join child_group cg on cg.group_id = s.group_id
                                    and s.starts_at >= cg.valid_from
                                    and (cg.valid_to is null or s.starts_at < cg.valid_to)
                where s.group_id = g.id and s.deleted_at is null and s.status <> 'cancelled'
                  and s.ends_at < now())::int as expected,
              (select count(*) from homework_status hs join homework h on h.id = hs.homework_id
                where h.group_id = g.id and h.deleted_at is null and hs.done)::int as hw_done,
              (select count(*) from homework_status hs join homework h on h.id = hs.homework_id
                where h.group_id = g.id and h.deleted_at is null)::int as hw_total,
              (select min(s.starts_at) from session s
                where s.group_id = g.id and s.deleted_at is null and s.status <> 'cancelled'
                  and s.ends_at > now()) as next_session_at,
              coalesce((select json_agg(json_build_object('child_id', f.id, 'full_name', f.full_name,
                                                          'consecutive_absences', 3))
                          from (select c.id, c.full_name
                                  from child_group cg
                                  join child c on c.id = cg.child_id and c.deleted_at is null
                                 where cg.group_id = g.id and cg.valid_to is null
                                   and 3 = (select count(*) from (
                                              select ar.status
                                                from session s
                                                left join attendance_record ar
                                                       on ar.session_id = s.id and ar.child_id = c.id
                                                      and ar.superseded_at is null
                                               where s.group_id = g.id and s.deleted_at is null
                                                 and s.status <> 'cancelled' and s.ends_at < now()
                                                 and s.starts_at >= cg.valid_from
                                               order by s.starts_at desc limit 3) last3
                                             where last3.status = 'absent')) f),
                       '[]'::json) as flags
         from "group" g
        where g.id = any($1::uuid[])`,
      [groupIds],
    );
    for (const row of rows) {
      result.set(row.group_id, {
        attendance: { present: row.present, expected: row.expected },
        homework: { done: row.hw_done, total: row.hw_total },
        next_session_at: row.next_session_at ? row.next_session_at.toISOString() : null,
        flags: row.flags,
      });
    }
    return result;
  }

  async detail(user: AuthenticatedUser, groupId: string): Promise<GroupView> {
    const row = await this.loadReadable(user, groupId);
    const locale = await loadLocale(this.dataSource, user.id);
    return this.toView(row, locale);
  }

  /** The group's sessions, most recent first. */
  async sessions(
    user: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupSessionView[]> {
    const group = await this.loadReadable(user, groupId);
    // The schedule implies the coming sessions; materialise the next eight
    // weeks so the page shows them before an educator ever opens Today.
    await this.sessionsService.ensureGenerated(
      this.dataSource,
      [group.id],
      new Date(),
      new Date(Date.now() + 56 * 24 * 3600 * 1000),
    );

    const rows: Array<{
      id: string;
      title: string | null;
      starts_at: Date;
      ends_at: Date;
      status: GroupSessionView['status'];
      attendance_recorded: boolean;
      present_count: number;
    }> = await this.dataSource.query(
      `select s.id, s.title, s.starts_at, s.ends_at, s.status,
              exists (select 1 from attendance_record ar
                       where ar.session_id = s.id and ar.superseded_at is null)
                as attendance_recorded,
              (select count(*) from attendance_record ar
                where ar.session_id = s.id and ar.superseded_at is null
                  and ar.status in ('present', 'late'))::int as present_count
         from session s
        where s.group_id = $1 and s.deleted_at is null
        order by s.starts_at desc
        limit 60`,
      [group.id],
    );

    return rows.map((row) => ({
      id: row.id,
      group_id: group.id,
      title: row.title,
      starts_at: row.starts_at.toISOString(),
      ends_at: row.ends_at.toISOString(),
      status: row.status,
      attendance: {
        recorded: row.attendance_recorded,
        present_count: row.attendance_recorded ? row.present_count : null,
        enrolled_count: row.attendance_recorded ? group.enrolled_count : null,
      },
    }));
  }

  /**
   * Replaces the weekly schedule. Sessions already generated stay as they
   * are — a slot that was planned is a session that was planned — and the
   * new slots are materialised for the coming weeks at once.
   */
  async updateSchedule(
    user: AuthenticatedUser,
    groupId: string,
    input: UpdateGroupScheduleDto,
  ): Promise<GroupView> {
    const group = await this.loadReadable(user, groupId);
    const ability = defineAbilityFor(user);
    if (!ability.can('update', subject('Group', { id: group.id, branchId: group.branch_id }))) {
      throw ApiError.scopeForbidden();
    }
    for (const slot of input.weekly_schedule) {
      if (slot.ends_at <= slot.starts_at) {
        throw ApiError.validationFailed({ weekly_schedule: ['ends_at must be after starts_at'] });
      }
    }
    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update "group" set weekly_schedule_json = $2::jsonb, updated_at = now() where id = $1`,
        [group.id, JSON.stringify(input.weekly_schedule)],
      );
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'group.update', 'group', $2, $3::jsonb)`,
        [user.id, group.id, JSON.stringify({ changed: ['weekly_schedule'], slots: input.weekly_schedule.length })],
      );
    });
    await this.sessionsService.ensureGenerated(
      this.dataSource,
      [group.id],
      new Date(),
      new Date(Date.now() + 56 * 24 * 3600 * 1000),
    );
    return this.detail(user, groupId);
  }

  /**
   * Creates a group in the active season, with its educators and any
   * children picked from the unassigned list, recorded as one act.
   *
   * The branch is the caller's when they are restricted to one, else the
   * association's single branch; a multi-branch association will pass it
   * explicitly when the second branch exists.
   */
  async create(user: AuthenticatedUser, input: CreateGroupDto): Promise<GroupView> {
    const ability = defineAbilityFor(user);
    const branchId = user.branchId ?? (await this.defaultBranchId());
    if (!ability.can('create', subject('Group', { branchId }))) {
      throw ApiError.scopeForbidden();
    }
    const seasons: Array<{ id: string }> = await this.dataSource.query(
      `select id from season where status = 'active' order by start_date desc limit 1`,
    );
    if (seasons.length === 0) throw ApiError.groupsNoActiveSeason();

    const groupId = await this.dataSource.transaction(async (tx) => {
      const rows: Array<{ id: string }> = await tx.query(
        `insert into "group" (name, category_id, season_id, branch_id, capacity, weekly_schedule_json)
         values ($1, $2, $3, $4, $5, $6::jsonb) returning id`,
        [
          input.name.trim(),
          input.category_id,
          seasons[0].id,
          branchId,
          input.capacity ?? null,
          JSON.stringify(input.weekly_schedule ?? []),
        ],
      );
      const id = rows[0].id;
      for (const educatorId of input.educator_ids) {
        await tx.query(
          `insert into group_educator (group_id, educator_user_id) values ($1, $2)`,
          [id, educatorId],
        );
      }
      // A staff channel exists from the first day (Epic E).
      await tx.query(`insert into conversation (type, ref_group_id) values ('staff', $1)`, [id]);
      for (const childId of input.child_ids ?? []) await this.moveChild(tx, childId, id);
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'group.create', 'group', $2, $3::jsonb)`,
        [
          user.id,
          id,
          JSON.stringify({ educator_ids: input.educator_ids, child_ids: input.child_ids ?? [] }),
        ],
      );
      return id;
    });

    return this.detail(user, groupId);
  }

  /**
   * Assigns children to a group as their main group.
   *
   * Moving a child is a new `child_group` row with the previous one closed
   * (`ORG-04`), never an update, so the history of where a child was stays
   * readable. Over capacity is allowed — the executive confirmed it — and
   * shows up as the warning the dashboard raises.
   */
  async assign(
    user: AuthenticatedUser,
    groupId: string,
    input: AssignChildrenDto,
  ): Promise<{ enrolled_count: number; capacity: number | null }> {
    const group = await this.loadReadable(user, groupId);
    const ability = defineAbilityFor(user);
    if (!ability.can('update', subject('Group', { id: group.id, branchId: group.branch_id }))) {
      throw ApiError.scopeForbidden();
    }

    await this.dataSource.transaction(async (tx) => {
      for (const childId of input.child_ids) await this.moveChild(tx, childId, group.id);
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'group.assign', 'group', $2, $3::jsonb)`,
        [user.id, group.id, JSON.stringify({ child_ids: input.child_ids })],
      );
    });

    const after = await this.loadReadable(user, groupId);
    return { enrolled_count: after.enrolled_count, capacity: after.capacity };
  }

  private async moveChild(tx: EntityManager, childId: string, groupId: string): Promise<void> {
    const exists: Array<{ id: string }> = await tx.query(
      'select id from child where id = $1 and deleted_at is null',
      [childId],
    );
    if (exists.length === 0) throw ApiError.validationFailed({ child_ids: [`unknown child ${childId}`] });
    await tx.query(
      `update child_group set valid_to = now()
        where child_id = $1 and is_main and valid_to is null and group_id <> $2`,
      [childId, groupId],
    );
    await tx.query(
      `insert into child_group (child_id, group_id, is_main)
       select $1, $2, true
        where not exists (select 1 from child_group
                           where child_id = $1 and group_id = $2 and valid_to is null)`,
      [childId, groupId],
    );
  }

  private async defaultBranchId(): Promise<string> {
    const rows: Array<{ id: string }> = await this.dataSource.query(
      'select id from branch where deleted_at is null order by created_at limit 1',
    );
    if (rows.length === 0) throw ApiError.groupsNoBranch();
    return rows[0].id;
  }

  /**
   * Loads a group and checks the caller may read it — against the row's own
   * branch, never anything the request supplied. A missing group answers
   * exactly like a forbidden one.
   */
  private async loadReadable(
    user: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupRow> {
    const rows = await this.query(['g.id = $1', 'g.deleted_at is null'], [groupId], '');
    const row = rows[0];
    if (!row) throw ApiError.scopeForbidden('No such group, or not yours.');

    const ability = defineAbilityFor(user);
    const resource = subject('Group', { id: row.id, branchId: row.branch_id });
    if (!ability.can('read', resource)) throw ApiError.scopeForbidden();
    return row;
  }

  private query(
    where: string[],
    params: unknown[],
    orderBy: string,
  ): Promise<GroupRow[]> {
    return this.dataSource.query(
      `select g.id, g.name, g.capacity, g.branch_id, g.weekly_schedule_json,
              cat.id as category_id, cat.name_ar as category_name,
              (select count(*)
                 from child_group cg
                 join child c on c.id = cg.child_id and c.deleted_at is null
                where cg.group_id = g.id and cg.valid_to is null)::int as enrolled_count,
              coalesce((select json_agg(json_build_object(
                                 'id', ge.educator_user_id,
                                 'display_name', ${displayNameOf('ge.educator_user_id')})
                               order by ge.assigned_at)
                          from group_educator ge
                         where ge.group_id = g.id and ge.unassigned_at is null),
                       '[]'::json) as educators,
              (select s.place from session s
                where s.group_id = g.id and s.deleted_at is null and s.place is not null
                order by s.starts_at desc limit 1) as place
         from "group" g
         join category cat on cat.id = g.category_id
         join season se on se.id = g.season_id
        where ${where.join(' and ')}
        ${orderBy}`,
      params,
    );
  }

  private toView(row: GroupRow, locale: 'ar' | 'fr' | 'en'): GroupView {
    return {
      id: row.id,
      name: row.name,
      category: { id: row.category_id, name: row.category_name },
      enrolled_count: row.enrolled_count,
      capacity: row.capacity,
      educators: row.educators,
      schedule_label: scheduleLabel(locale, row.weekly_schedule_json),
      weekly_schedule: scheduleSlots(row.weekly_schedule_json),
      place: row.place,
    };
  }
}

/** The stored slots, kept only when well-formed — a malformed entry is dropped, not guessed at. */
function scheduleSlots(raw: unknown): ScheduleSlotDto[] {
  if (!Array.isArray(raw)) return [];
  const slots: ScheduleSlotDto[] = [];
  for (const entry of raw) {
    if (!entry || typeof entry !== 'object') continue;
    const { weekday, starts_at, ends_at } = entry as Record<string, unknown>;
    if (
      typeof weekday === 'number' && weekday >= 0 && weekday <= 6 &&
      typeof starts_at === 'string' && typeof ends_at === 'string'
    ) {
      slots.push({ weekday, starts_at, ends_at });
    }
  }
  return slots;
}
