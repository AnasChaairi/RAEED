import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { loadLocale, scheduleLabel } from '../../common/i18n/user-locale';
import { ApiError } from '../../common/http/api-error';
import { displayNameOf } from '../../common/sql/display-name';
import { ChildrenService } from './children.service';

export interface ExecutiveChildView {
  id: string;
  full_name: string;
  photo_url: string | null;
  dob: string;
  school_level: string | null;
  group: { id: string; name: string } | null;
  health_alert: boolean;
  /** Always empty here: the text is read through the logged route. */
  health_json: Record<string, never>;
  image_rights_level: 'allowed' | 'app_only' | 'not_allowed';
  season_attendance: { present: number; expected: number } | null;
  guardians: Array<{
    id: string;
    display_name: string;
    relationship: string;
    /** active = has signed in; pending = account exists, never signed in. */
    account: 'active' | 'pending';
    last_seen_at: string | null;
    /** The masked tail of the number — the full number is a logged reveal. */
    phone_hint: string | null;
  }>;
  consents: {
    privacy_policy: Array<{ guardian_id: string; version: number; at: string }>;
    image_rights: Array<{
      guardian_id: string;
      level: 'allowed' | 'app_only' | 'not_allowed';
      version: number;
      at: string;
    }>;
  };
  groups: Array<{
    id: string;
    name: string;
    is_main: boolean;
    educator_names: string[];
    schedule_label: string | null;
    attendance: { present: number; expected: number };
  }>;
  conversation_id: string | null;
}

/** The educator's view of a child in one of their groups (EDU-M-06). */
export interface EducatorChildView {
  id: string;
  full_name: string;
  photo_url: string | null;
  dob: string;
  school_level: string | null;
  group: { id: string; name: string } | null;
  health_alert: boolean;
  image_rights_level: 'allowed' | 'app_only' | 'not_allowed';
  season_attendance: { present: number; expected: number } | null;
  homework: { done: number; total: number };
  guardians: Array<{
    id: string;
    display_name: string;
    relationship: string;
    account: 'active' | 'pending';
    is_emergency_contact: boolean;
  }>;
  conversation_id: string | null;
}

export interface EmergencyCallView {
  guardian_id: string;
  display_name: string;
  /** Handed to the dialer, never rendered (`MSG-06`); the reveal is recorded. */
  phone: string | null;
  recorded_at: string;
}

export interface HealthView {
  child_id: string;
  health_json: Record<string, unknown>;
  health_json_version: number;
  special_needs_notes: string | null;
  viewed_at: string;
}

export interface GuardianPhoneView {
  guardian_id: string;
  phone: string | null;
  revealed_at: string;
}

interface ChildRow {
  id: string;
  full_name: string;
  photo_url: string | null;
  dob: string;
  school_level: string | null;
  health_json: Record<string, unknown>;
  health_json_version: number;
  special_needs_notes: string | null;
  group_id: string | null;
  group_name: string | null;
  branch_id: string | null;
}

/**
 * The executive's view of a child (EXEC-M-09).
 *
 * Two reads on this screen are audit-logged on the server at the moment
 * they happen, because the brief requires the log to back the on-screen
 * promise: the health text (`AUD-03`) and a guardian's phone number
 * (`MSG-06`). Neither is in the profile payload; each is its own route so
 * that fetching the profile can never accidentally log — or leak — either.
 */
@Injectable()
export class ExecutiveChildrenService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly children: ChildrenService,
  ) {}

  async detail(user: AuthenticatedUser, childId: string): Promise<ExecutiveChildView> {
    const row = await this.loadReadable(user, childId);
    const locale = await loadLocale(this.dataSource, user.id);

    const [guardians, privacy, imageRights, groups, conversation, attendance] =
      await Promise.all([
        this.guardians(childId),
        this.privacyConsents(childId),
        this.imageRightsConsents(childId),
        this.groups(childId),
        this.conversationId(childId),
        this.seasonAttendance(childId),
      ]);

    return {
      id: row.id,
      full_name: row.full_name,
      photo_url: row.photo_url,
      dob: row.dob,
      school_level: row.school_level,
      group: row.group_id && row.group_name ? { id: row.group_id, name: row.group_name } : null,
      health_alert: Object.keys(row.health_json ?? {}).length > 0,
      health_json: {},
      image_rights_level: await this.children.currentImageRights(childId),
      season_attendance: attendance,
      guardians,
      consents: { privacy_policy: privacy, image_rights: imageRights },
      groups: groups.map((group) => ({
        id: group.id,
        name: group.name,
        is_main: group.is_main,
        educator_names: group.educator_names,
        schedule_label: scheduleLabel(locale, group.weekly_schedule_json),
        attendance: { present: group.present, expected: group.expected },
      })),
      conversation_id: conversation,
    };
  }

  /**
   * The child as their educator sees them: standing, guardians by name and
   * account state, the thread — no phone, no consent history, and the health
   * text only through the logged route below, exactly like an executive.
   */
  async educatorDetail(user: AuthenticatedUser, childId: string): Promise<EducatorChildView> {
    const row = await this.loadReadable(user, childId);
    const [guardians, conversation, attendance, homework] = await Promise.all([
      this.guardians(childId),
      this.conversationId(childId),
      this.seasonAttendance(childId),
      this.homeworkCounts(childId),
    ]);
    return {
      id: row.id,
      full_name: row.full_name,
      photo_url: row.photo_url,
      dob: row.dob,
      school_level: row.school_level,
      group: row.group_id && row.group_name ? { id: row.group_id, name: row.group_name } : null,
      health_alert: Object.keys(row.health_json ?? {}).length > 0,
      image_rights_level: await this.children.currentImageRights(childId),
      season_attendance: attendance,
      homework,
      guardians: guardians.map((guardian) => ({
        id: guardian.id,
        display_name: guardian.display_name,
        relationship: guardian.relationship,
        account: guardian.account,
        is_emergency_contact: guardian.relationship === 'emergency',
      })),
      conversation_id: conversation,
    };
  }

  /**
   * An emergency call to a guardian from an educator's phone. The number is
   * handed to the dialer and never shown; the act is recorded like a reveal,
   * because for the guardian it is one.
   */
  async emergencyCall(user: AuthenticatedUser, childId: string): Promise<EmergencyCallView> {
    await this.loadReadable(user, childId);
    const rows: Array<{ id: string; display_name: string; phone: string | null; relationship: string }> =
      await this.dataSource.query(
        `select u.id, coalesce(u.display_name, '') as display_name, u.phone, pc.relationship_type as relationship
           from parent_child pc
           join app_user u on u.id = pc.guardian_user_id and u.is_active
          where pc.child_id = $1 and pc.unlinked_at is null
          order by (pc.relationship_type = 'emergency') desc, pc.linked_at
          limit 1`,
        [childId],
      );
    const contact = rows[0];
    if (!contact) throw ApiError.scopeForbidden('No reachable guardian.');
    const recordedAt = await this.audit(user.id, 'guardian.emergency_call', 'app_user', contact.id, {
      child_id: childId,
    });
    return { guardian_id: contact.id, display_name: contact.display_name, phone: contact.phone, recorded_at: recordedAt };
  }

  private async homeworkCounts(childId: string): Promise<{ done: number; total: number }> {
    const rows: Array<{ done: number; total: number }> = await this.dataSource.query(
      `select count(*) filter (where hs.done)::int as done, count(*)::int as total
         from homework_status hs
         join homework h on h.id = hs.homework_id and h.deleted_at is null
        where hs.child_id = $1`,
      [childId],
    );
    return rows[0] ?? { done: 0, total: 0 };
  }

  /** Logs first, then reads: an unlogged view must be impossible. */
  async health(user: AuthenticatedUser, childId: string): Promise<HealthView> {
    // Staff only: a guardian reads their own child's health on the profile
    // itself, by relationship, and never through the recorded route.
    if (!user.hasOversight && !user.hasRole('educator')) throw ApiError.scopeForbidden();
    const row = await this.loadReadable(user, childId, 'ChildHealth');
    const viewedAt = await this.audit(user.id, 'child.health_view', 'child', childId, {
      context: 'child_profile',
    });
    return {
      child_id: row.id,
      health_json: row.health_json ?? {},
      health_json_version: row.health_json_version,
      special_needs_notes: row.special_needs_notes,
      viewed_at: viewedAt,
    };
  }

  async guardianPhone(
    user: AuthenticatedUser,
    childId: string,
    guardianId: string,
  ): Promise<GuardianPhoneView> {
    // A number on screen is the executive's act alone (`MSG-06`); an
    // educator reaches a guardian through the thread or the emergency call.
    if (!user.hasOversight) throw ApiError.scopeForbidden();
    await this.loadReadable(user, childId);
    const rows: Array<{ phone: string | null }> = await this.dataSource.query(
      `select u.phone
         from parent_child pc
         join app_user u on u.id = pc.guardian_user_id
        where pc.child_id = $1 and pc.guardian_user_id = $2 and pc.unlinked_at is null`,
      [childId, guardianId],
    );
    if (rows.length === 0) throw ApiError.scopeForbidden('No such guardian, or not yours.');

    const revealedAt = await this.audit(user.id, 'guardian.phone_reveal', 'app_user', guardianId, {
      child_id: childId,
    });
    return { guardian_id: guardianId, phone: rows[0].phone, revealed_at: revealedAt };
  }

  private async loadReadable(
    user: AuthenticatedUser,
    childId: string,
    subjectType: 'Child' | 'ChildHealth' = 'Child',
  ): Promise<ChildRow> {
    const rows: ChildRow[] = await this.dataSource.query(
      `select c.id, c.full_name, c.photo_url, to_char(c.dob, 'YYYY-MM-DD') as dob, c.school_level,
              c.health_json, c.health_json_version, c.special_needs_notes,
              g.id as group_id, g.name as group_name, g.branch_id
         from child c
         left join child_group cg on cg.child_id = c.id and cg.valid_to is null and cg.is_main
         left join "group" g on g.id = cg.group_id
        where c.id = $1 and c.deleted_at is null`,
      [childId],
    );
    const row = rows[0];
    if (!row) throw ApiError.scopeForbidden('No such child, or not yours.');

    const ability = defineAbilityFor(user);
    const resource = subject(subjectType, {
      id: row.id,
      childId: row.id,
      groupId: row.group_id,
      branchId: row.branch_id,
    });
    // An educator reads a child in their own group; oversight reads in its
    // branch. Both come from the ability model, never from the role name.
    if (!ability.can('read', resource)) throw ApiError.scopeForbidden();
    return row;
  }

  private async audit(
    actorId: string,
    action: string,
    resourceType: string,
    resourceId: string,
    meta: Record<string, unknown>,
  ): Promise<string> {
    const rows: Array<{ at: Date }> = await this.dataSource.query(
      `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
       values ($1, $2, $3, $4, $5::jsonb)
       returning at`,
      [actorId, action, resourceType, resourceId, JSON.stringify(meta)],
    );
    return rows[0].at.toISOString();
  }

  private guardians(childId: string): Promise<ExecutiveChildView['guardians']> {
    return this.dataSource.query(
      `select u.id, coalesce(u.display_name, '') as display_name,
              pc.relationship_type as relationship,
              case when exists (select 1 from user_device d
                                 where d.user_id = u.id and d.revoked_at is null
                                   and d.last_seen_at is not null)
                   then 'active' else 'pending' end as account,
              (select max(d.last_seen_at) from user_device d where d.user_id = u.id) as last_seen_at,
              case when u.phone is null then null
                   else '•• ' || right(u.phone, 2) end as phone_hint
         from parent_child pc
         join app_user u on u.id = pc.guardian_user_id
        where pc.child_id = $1 and pc.unlinked_at is null
        order by pc.linked_at`,
      [childId],
    ).then((rows: Array<ExecutiveChildView['guardians'][number] & { last_seen_at: Date | null }>) =>
      rows.map((row) => ({
        ...row,
        last_seen_at: row.last_seen_at ? new Date(row.last_seen_at).toISOString() : null,
      })),
    );
  }

  private privacyConsents(
    childId: string,
  ): Promise<ExecutiveChildView['consents']['privacy_policy']> {
    return this.dataSource
      .query(
        `select distinct on (cr.guardian_id) cr.guardian_id, cr.version, cr.effective_at as at
           from consent_record cr
           join parent_child pc on pc.guardian_user_id = cr.guardian_id
                and pc.child_id = $1 and pc.unlinked_at is null
          where cr.type = 'privacy_policy'
          order by cr.guardian_id, cr.effective_at desc`,
        [childId],
      )
      .then((rows: Array<{ guardian_id: string; version: number; at: Date }>) =>
        rows.map((row) => ({ ...row, at: row.at.toISOString() })),
      );
  }

  private imageRightsConsents(
    childId: string,
  ): Promise<ExecutiveChildView['consents']['image_rights']> {
    return this.dataSource
      .query(
        `select distinct on (cr.guardian_id) cr.guardian_id, cr.level, cr.version, cr.effective_at as at
           from consent_record cr
          where cr.child_id = $1 and cr.type = 'image_rights' and cr.level is not null
          order by cr.guardian_id, cr.effective_at desc`,
        [childId],
      )
      .then(
        (
          rows: Array<{
            guardian_id: string;
            level: 'allowed' | 'app_only' | 'not_allowed';
            version: number;
            at: Date;
          }>,
        ) => rows.map((row) => ({ ...row, at: row.at.toISOString() })),
      );
  }

  private groups(childId: string): Promise<
    Array<{
      id: string;
      name: string;
      is_main: boolean;
      educator_names: string[];
      weekly_schedule_json: unknown;
      present: number;
      expected: number;
    }>
  > {
    return this.dataSource.query(
      `select g.id, g.name, cg.is_main, g.weekly_schedule_json,
              coalesce((select array_agg(${displayNameOf('ge.educator_user_id')} order by ge.assigned_at)
                          from group_educator ge
                         where ge.group_id = g.id and ge.unassigned_at is null), '{}'::text[])
                as educator_names,
              (select count(*) from attendance_record ar
                 join session s on s.id = ar.session_id
                where ar.child_id = $1 and ar.superseded_at is null
                  and s.group_id = g.id and s.deleted_at is null
                  and s.starts_at >= cg.valid_from
                  and ar.status in ('present', 'late'))::int as present,
              (select count(*) from session s
                where s.group_id = g.id and s.deleted_at is null
                  and s.status <> 'cancelled' and s.ends_at < now()
                  and s.starts_at >= cg.valid_from)::int as expected
         from child_group cg
         join "group" g on g.id = cg.group_id and g.deleted_at is null
        where cg.child_id = $1 and cg.valid_to is null
        order by cg.is_main desc, g.name`,
      [childId],
    );
  }

  private async conversationId(childId: string): Promise<string | null> {
    const rows: Array<{ id: string }> = await this.dataSource.query(
      `select id from conversation where type = 'child' and ref_child_id = $1 limit 1`,
      [childId],
    );
    return rows[0]?.id ?? null;
  }

  private async seasonAttendance(
    childId: string,
  ): Promise<{ present: number; expected: number } | null> {
    const rows: Array<{ present: number; expected: number }> = await this.dataSource.query(
      `select (select count(*) from attendance_record ar
                 join session s on s.id = ar.session_id and s.deleted_at is null
                 join child_group cg on cg.group_id = s.group_id and cg.child_id = $1
                where ar.child_id = $1 and ar.superseded_at is null
                  and ar.status in ('present', 'late')
                  and s.starts_at >= cg.valid_from
                  and (cg.valid_to is null or s.starts_at < cg.valid_to))::int as present,
              (select count(*) from session s
                 join child_group cg on cg.group_id = s.group_id and cg.child_id = $1
                where s.deleted_at is null and s.status <> 'cancelled' and s.ends_at < now()
                  and s.starts_at >= cg.valid_from
                  and (cg.valid_to is null or s.starts_at < cg.valid_to))::int as expected`,
      [childId],
    );
    const row = rows[0];
    if (!row || row.expected === 0) return null;
    return row;
  }
}
