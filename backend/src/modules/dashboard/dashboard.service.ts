import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { displayNameOf } from '../../common/sql/display-name';
import {
  Locale,
  loadLocale,
  ORG_TIMEZONE,
  pick,
} from '../../common/i18n/user-locale';

export type AlertSeverity = 'danger' | 'warning' | 'info';
export type AlertDestination =
  | 'groups'
  | 'memories'
  | 'messages'
  | 'announcements'
  | 'notifications';

export interface DashboardAlertView {
  id: string;
  severity: AlertSeverity;
  text: string;
  destination: AlertDestination;
  raised_at: string;
  group_id?: string;
  session_id?: string;
}

export interface DashboardOverviewView {
  alerts: DashboardAlertView[];
  stats: Record<
    'children' | 'families' | 'groups' | 'educators',
    { value: number; delta: number | null }
  >;
  weekly_attendance: {
    present_count: number;
    expected_count: number;
    weekly_rates: number[];
    delta_points: number | null;
  } | null;
  today_sessions: Array<{
    id: string;
    group_id: string;
    group_name: string;
    title: string | null;
    educator_name: string | null;
    starts_at: string;
    ends_at: string;
    attendance_recorded: boolean;
  }>;
}

/** A `where` fragment narrowing groups to the caller's branch, if any. */
interface Scope {
  readonly clause: string;
  readonly params: unknown[];
}

/**
 * The executive overview (`DSH-01`, EXEC-M-01).
 *
 * Read-only, and scoped the way every other module is: an executive
 * restricted to a branch (`ACC-08`) sees that branch's groups and nothing
 * else, applied in the query rather than by filtering afterwards. Every
 * number here is computed from the same tables the operational screens
 * read — there is no separate reporting path (`specs/13-roadmap-and-tickets.md`,
 * Epic G).
 *
 * The alerts answer the executive's first question, "is any child
 * unaccounted for?", before anything else: sessions that ended without a
 * mark, and today's unexplained absences, are the two danger alerts; a group
 * over capacity is a warning; posts and reports awaiting a decision are
 * information.
 */
@Injectable()
export class DashboardService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  async overview(user: AuthenticatedUser): Promise<DashboardOverviewView> {
    const locale = await loadLocale(this.dataSource, user.id);
    const scope = this.scopeOf(user);

    const [alerts, stats, weekly, today] = await Promise.all([
      this.alerts(scope, locale),
      this.stats(scope),
      this.weeklyAttendance(scope),
      this.todaySessions(scope),
    ]);

    return { alerts, stats, weekly_attendance: weekly, today_sessions: today };
  }

  private scopeOf(user: AuthenticatedUser): Scope {
    if (user.branchId) {
      return { clause: 'and g.branch_id = $1', params: [user.branchId] };
    }
    return { clause: '', params: [] };
  }

  private async alerts(
    scope: Scope,
    locale: Locale,
  ): Promise<DashboardAlertView[]> {
    const alerts: DashboardAlertView[] = [];

    // Sessions that ended in the last week with no attendance mark at all —
    // the escalation `RAEED-20` makes visible to executives beyond the
    // educator's own reminder.
    const unrecorded: Array<{ n: number; at: Date | null }> =
      await this.dataSource.query(
        `select count(*)::int as n, max(s.ends_at) as at
           from session s
           join "group" g on g.id = s.group_id
          where s.deleted_at is null
            and s.status <> 'cancelled'
            and s.ends_at < now()
            and s.ends_at > now() - interval '7 days'
            and not exists (
              select 1 from attendance_record ar
               where ar.session_id = s.id and ar.superseded_at is null)
            ${scope.clause}`,
        scope.params,
      );
    if (unrecorded[0]?.n > 0) {
      const n = unrecorded[0].n;
      alerts.push({
        id: 'sessions-unrecorded',
        severity: 'danger',
        text: pick(locale, {
          ar: `${n} جلسات في الأسبوع الأخير بلا تسجيل حضور`,
          fr: `${n} séance(s) de la semaine sans présence enregistrée`,
          en: `${n} session(s) this week with no attendance recorded`,
        }),
        destination: 'groups',
        raised_at: (unrecorded[0].at ?? new Date()).toISOString(),
      });
    }

    // Today's unexplained absences: `absent` with no prior `no`/`late`
    // answer — the same rule that fires the critical alert (`ATT-07`).
    const absences: Array<{ n: number; at: Date | null }> =
      await this.dataSource.query(
        `select count(*)::int as n, max(ar.recorded_at) as at
           from attendance_record ar
           join session s on s.id = ar.session_id
           join "group" g on g.id = s.group_id
          where ar.superseded_at is null
            and ar.status = 'absent'
            and (s.starts_at at time zone $${scope.params.length + 1})::date
                = (now() at time zone $${scope.params.length + 1})::date
            and not exists (
              select 1
                from presence_answer pa
                join presence_confirmation pc on pc.id = pa.presence_confirmation_id
               where pc.session_id = s.id
                 and pa.child_id = ar.child_id
                 and pa.answer in ('no', 'late'))
            ${scope.clause}`,
        [...scope.params, ORG_TIMEZONE],
      );
    if (absences[0]?.n > 0) {
      const n = absences[0].n;
      alerts.push({
        id: 'absences-today',
        severity: 'danger',
        text: pick(locale, {
          ar: `${n} تنبيهات غياب اليوم دون إشعار مسبق`,
          fr: `${n} absence(s) sans préavis aujourd'hui`,
          en: `${n} absence(s) without notice today`,
        }),
        destination: 'groups',
        raised_at: (absences[0].at ?? new Date()).toISOString(),
      });
    }

    const overCapacity: Array<{
      id: string;
      name: string;
      capacity: number;
      enrolled: number;
      since: Date;
    }> = await this.dataSource.query(
      `select g.id, g.name, g.capacity,
              count(c.id)::int as enrolled,
              max(cg.valid_from) as since
         from "group" g
         join season se on se.id = g.season_id and se.status = 'active'
         left join child_group cg on cg.group_id = g.id and cg.valid_to is null
         left join child c on c.id = cg.child_id and c.deleted_at is null
        where g.deleted_at is null
          and g.capacity is not null
          ${scope.clause}
        group by g.id
       having count(c.id) > g.capacity
        order by g.name`,
      scope.params,
    );
    for (const group of overCapacity) {
      alerts.push({
        id: `over-capacity-${group.id}`,
        severity: 'warning',
        text: pick(locale, {
          ar: `${group.name} فوق السعة: ${group.enrolled} من ${group.capacity}`,
          fr: `${group.name} au-delà de la capacité : ${group.enrolled} sur ${group.capacity}`,
          en: `${group.name} over capacity: ${group.enrolled} of ${group.capacity}`,
        }),
        destination: 'groups',
        raised_at: group.since.toISOString(),
        group_id: group.id,
      });
    }

    const pendingPosts: Array<{ n: number; at: Date | null }> =
      await this.dataSource.query(
        `select count(*)::int as n, max(p.created_at) as at
           from post p
           join album a on a.id = p.album_id
           left join "group" g on g.id = a.group_id
          where p.deleted_at is null
            and (p.moderation_status = 'pending'
                 or (p.moderation_status = 'hidden' and p.hidden_reason = 'consent_blocked'))
            ${scope.clause.replace('and g.branch_id', 'and (g.id is null or g.branch_id')}${scope.clause ? ')' : ''}`,
        scope.params,
      );
    if (pendingPosts[0]?.n > 0) {
      const n = pendingPosts[0].n;
      alerts.push({
        id: 'posts-pending',
        severity: 'info',
        text: pick(locale, {
          ar: `${n} منشورات بانتظار الاعتماد`,
          fr: `${n} publication(s) en attente d'approbation`,
          en: `${n} post(s) awaiting approval`,
        }),
        destination: 'memories',
        raised_at: (pendingPosts[0].at ?? new Date()).toISOString(),
      });
    }

    const reports: Array<{ n: number; at: Date | null }> =
      await this.dataSource.query(
        `select count(*)::int as n, max(r.created_at) as at
           from message_report r
           join message m on m.id = r.message_id
           join conversation cv on cv.id = m.conversation_id
           left join "group" gs on gs.id = cv.ref_group_id
           left join child_group cg on cg.child_id = cv.ref_child_id
                  and cg.valid_to is null and cg.is_main
           left join "group" g on g.id = coalesce(gs.id, cg.group_id)
          where r.resolved_at is null
            ${scope.clause.replace('and g.branch_id', 'and (g.id is null or g.branch_id')}${scope.clause ? ')' : ''}`,
        scope.params,
      );
    if (reports[0]?.n > 0) {
      const n = reports[0].n;
      alerts.push({
        id: 'reports-open',
        severity: 'info',
        text: pick(locale, {
          ar: `${n} بلاغات على رسائل بانتظار قرارك`,
          fr: `${n} signalement(s) de message en attente`,
          en: `${n} message report(s) awaiting your decision`,
        }),
        destination: 'messages',
        raised_at: (reports[0].at ?? new Date()).toISOString(),
      });
    }

    return alerts;
  }

  private async stats(scope: Scope): Promise<DashboardOverviewView['stats']> {
    // Children, families and educators are counted through the group they
    // sit in, so a branch restriction narrows all four numbers the same way.
    const rows: Array<{
      children: number;
      families: number;
      groups: number;
      educators: number;
    }> = await this.dataSource.query(
      `with scoped_groups as (
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
       )
       select (select count(*) from scoped_children)::int as children,
              (select count(distinct pc.guardian_user_id)
                 from parent_child pc
                 join scoped_children sc on sc.id = pc.child_id
                where pc.unlinked_at is null)::int as families,
              (select count(*) from scoped_groups)::int as groups,
              (select count(distinct ge.educator_user_id)
                 from group_educator ge
                 join scoped_groups sg on sg.id = ge.group_id
                where ge.unassigned_at is null)::int as educators`,
      scope.params,
    );
    const row = rows[0];
    // Deltas need a previous period to compare against, which the schema
    // does not keep yet. Null rather than zero: "no change" is a claim.
    return {
      children: { value: row?.children ?? 0, delta: null },
      families: { value: row?.families ?? 0, delta: null },
      groups: { value: row?.groups ?? 0, delta: null },
      educators: { value: row?.educators ?? 0, delta: null },
    };
  }

  /**
   * Attendance per week for the trailing eight weeks.
   *
   * Expected marks are the currently enrolled children of every session that
   * has already started that week; present marks are `present` or `late`.
   * Enrolment is read as it stands now rather than as it was on the day —
   * `child_group` keeps the history, and a later ticket can pin each session
   * to its own roster.
   */
  private async weeklyAttendance(
    scope: Scope,
  ): Promise<DashboardOverviewView['weekly_attendance']> {
    const tzParam = scope.params.length + 1;
    const rows: Array<{ week_start: Date; expected: number; present: number }> =
      await this.dataSource.query(
        `with bounds as (
           select date_trunc('week', now() at time zone $${tzParam}) as this_week
         ),
         weeks as (
           select generate_series(
                    (select this_week from bounds) - interval '7 weeks',
                    (select this_week from bounds),
                    interval '1 week') as week_start
         ),
         sess as (
           select s.id,
                  date_trunc('week', s.starts_at at time zone $${tzParam}) as week_start,
                  (select count(*)
                     from child_group cg
                     join child c on c.id = cg.child_id and c.deleted_at is null
                    where cg.group_id = s.group_id and cg.valid_to is null) as enrolled
             from session s
             join "group" g on g.id = s.group_id
            where s.deleted_at is null
              and s.status <> 'cancelled'
              and s.starts_at < now()
              and s.starts_at at time zone $${tzParam}
                  >= (select this_week from bounds) - interval '7 weeks'
              ${scope.clause}
         ),
         present as (
           select sess.week_start, count(*)::int as n
             from sess
             join attendance_record ar
               on ar.session_id = sess.id and ar.superseded_at is null
              and ar.status in ('present', 'late')
            group by sess.week_start
         ),
         expected as (
           select week_start, sum(enrolled)::int as n from sess group by week_start
         )
         select w.week_start,
                coalesce(e.n, 0)::int as expected,
                coalesce(p.n, 0)::int as present
           from weeks w
           left join expected e on e.week_start = w.week_start
           left join present p on p.week_start = w.week_start
          order by w.week_start`,
        [...scope.params, ORG_TIMEZONE],
      );

    if (rows.length === 0) return null;
    const rates = rows
      .filter((row) => row.expected > 0)
      .map((row) => Math.round((row.present * 100) / row.expected));
    const thisWeek = rows[rows.length - 1];
    const lastWeek = rows.length > 1 ? rows[rows.length - 2] : null;
    const rate = (row: { expected: number; present: number }): number | null =>
      row.expected > 0 ? Math.round((row.present * 100) / row.expected) : null;
    const thisRate = rate(thisWeek);
    const lastRate = lastWeek ? rate(lastWeek) : null;

    return {
      present_count: thisWeek.present,
      expected_count: thisWeek.expected,
      weekly_rates: rates,
      delta_points:
        thisRate !== null && lastRate !== null ? thisRate - lastRate : null,
    };
  }

  private async todaySessions(
    scope: Scope,
  ): Promise<DashboardOverviewView['today_sessions']> {
    const tzParam = scope.params.length + 1;
    const rows: Array<{
      id: string;
      group_id: string;
      group_name: string;
      title: string | null;
      starts_at: Date;
      ends_at: Date;
      attendance_recorded: boolean;
      educator_name: string | null;
    }> = await this.dataSource.query(
      `select s.id, s.group_id, g.name as group_name, s.title, s.starts_at, s.ends_at,
              (select string_agg(${displayNameOf('ge.educator_user_id')}, '، ' order by ge.assigned_at)
                 from group_educator ge
                where ge.group_id = g.id and ge.unassigned_at is null) as educator_name,
              exists (select 1 from attendance_record ar
                       where ar.session_id = s.id and ar.superseded_at is null)
                as attendance_recorded
         from session s
         join "group" g on g.id = s.group_id
        where s.deleted_at is null
          and s.status <> 'cancelled'
          and (s.starts_at at time zone $${tzParam})::date
              = (now() at time zone $${tzParam})::date
          ${scope.clause}
        order by s.starts_at`,
      [...scope.params, ORG_TIMEZONE],
    );
    return rows.map((row) => ({
      id: row.id,
      group_id: row.group_id,
      group_name: row.group_name,
      title: row.title,
      educator_name: row.educator_name || null,
      starts_at: row.starts_at.toISOString(),
      ends_at: row.ends_at.toISOString(),
      attendance_recorded: row.attendance_recorded,
    }));
  }
}
