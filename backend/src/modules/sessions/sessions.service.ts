import { Inject, Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { Queue } from 'bullmq';
import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';
import { Locale, ORG_TIMEZONE, loadLocale, pick } from '../../common/i18n/user-locale';
import { CriticalJob, QUEUE_CRITICAL } from '../../common/queue/queues';
import { displayNameOf } from '../../common/sql/display-name';
import { MediaService } from '../media/media.service';
import { NotifyService } from '../notifications/notify.service';
import {
  AddMaterialDto,
  ChangeSessionDto,
  MaterialKind,
  MaterialVisibility,
  SendSummaryDto,
  UpdateSessionDto,
} from './dto/session.dto';

export type SessionStatus = 'planned' | 'delivered' | 'cancelled';

export interface SessionListItem {
  id: string;
  group: { id: string; name: string };
  title: string | null;
  theme: string | null;
  starts_at: string;
  ends_at: string;
  place: string | null;
  status: SessionStatus;
  is_customized: boolean;
  has_content: boolean;
  material_count: number;
  homework_count: number;
  attendance_recorded: boolean;
  summary_sent: boolean;
  rescheduled_from: string | null;
  co_educator_names: string[];
}

export interface MaterialView {
  id: string;
  kind: MaterialKind;
  title: string | null;
  storage_key: string;
  url: string | null;
  visibility: MaterialVisibility;
  size_bytes: number | null;
}

export interface HomeworkView {
  id: string;
  session_id: string;
  title: string | null;
  instructions: string;
  due_at: string;
  target_child_ids: string[] | null;
  target_count: number;
  done_count: number;
  attachment_url: string | null;
  created_at: string;
}

export interface PresenceTallies {
  yes: number;
  late: number;
  no: number;
  none: number;
}

export interface SessionDetailView extends SessionListItem {
  objectives: string | null;
  cancel_reason: string | null;
  changed_by_name: string | null;
  enrolled_count: number;
  guardian_count: number;
  family_count: number;
  materials: MaterialView[];
  homework: HomeworkView[];
  attendance: {
    recorded: boolean;
    present: number;
    late: number;
    excused: number;
    absent: number;
  };
  presence: (PresenceTallies & { sent: boolean }) | null;
  summary: { body: string; sent_at: string } | null;
}

export interface PresenceOverviewView {
  session_id: string;
  sent_at: string | null;
  deadline_at: string | null;
  reminder_sent_at: string | null;
  enrolled_count: number;
  expected: number;
  tallies: PresenceTallies;
  groups: Array<{
    answer: 'none' | 'no' | 'late' | 'yes';
    children: Array<{ id: string; full_name: string; reason: string | null }>;
  }>;
}

interface SessionRow {
  id: string;
  group_id: string;
  group_name: string;
  branch_id: string;
  title: string | null;
  theme: string | null;
  objectives: string | null;
  starts_at: Date;
  ends_at: Date;
  place: string | null;
  status: SessionStatus;
  is_customized: boolean;
  summary: string | null;
  summary_sent_at: Date | null;
  cancel_reason: string | null;
  rescheduled_from: Date | null;
  changed_by: string | null;
  changed_by_name: string | null;
  material_count: number;
  homework_count: number;
  attendance_recorded: boolean;
  co_educator_names: string[];
}

/**
 * Sessions as the educator works them: generated from the group's weekly
 * schedule, given content, summarised, cancelled or moved with everyone
 * told (`SES-02`, EDU-M-04).
 *
 * Every read and write checks the ability model against the session's
 * **own** group and branch, loaded from the row — never against anything
 * the request says.
 */
@Injectable()
export class SessionsService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    @Inject(QUEUE_CRITICAL) private readonly criticalQueue: Queue,
    private readonly notify: NotifyService,
  ) {}

  /**
   * Materialises the sessions a group's weekly schedule implies for every
   * day in [from, to], never touching a row that already exists — so an
   * educator's edits (`is_customized`) survive, and calling this on every
   * read is harmless (`SES-02`).
   *
   * Past days are left alone: a slot nobody planned in the past is not a
   * session that happened. Days before the season or after it are skipped.
   */
  async ensureGenerated(
    manager: EntityManager | DataSource,
    groupIds: string[],
    from: Date,
    to: Date,
  ): Promise<void> {
    if (groupIds.length === 0) return;
    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);
    const start = from > today ? from : today;
    if (start > to) return;

    await manager.query(
      `insert into session (group_id, starts_at, ends_at, status)
       select g.id,
              ((d::date + (slot->>'starts_at')::time) at time zone $4),
              ((d::date + (slot->>'ends_at')::time) at time zone $4),
              'planned'
         from "group" g
         join season se on se.id = g.season_id and se.status = 'active'
         cross join lateral jsonb_array_elements(g.weekly_schedule_json) as slot
         cross join generate_series($2::date, $3::date, interval '1 day') as d
        where g.id = any($1::uuid[]) and g.deleted_at is null
          and d::date between se.start_date and se.end_date
          and (slot->>'weekday') ~ '^[0-6]$'
          and extract(dow from d::date) = (slot->>'weekday')::int
          and (slot->>'starts_at') is not null and (slot->>'ends_at') is not null
       on conflict (group_id, starts_at) where deleted_at is null do nothing`,
      [groupIds, isoDate(start), isoDate(to), ORG_TIMEZONE],
    );
  }

  /** The sessions of the caller's groups in [from, to], generated first. */
  async list(
    user: AuthenticatedUser,
    options: { from: Date; to: Date; groupId?: string },
  ): Promise<SessionListItem[]> {
    const groupIds = await this.scopedGroupIds(user, options.groupId);
    if (groupIds.length === 0) return [];
    await this.ensureGenerated(this.dataSource, groupIds, options.from, options.to);

    const rows = await this.rows(
      `s.group_id = any($1::uuid[]) and s.starts_at >= $2 and s.starts_at < $3`,
      [groupIds, options.from, options.to],
      'order by s.starts_at, s.id',
    );
    return rows.map((row) => this.toItem(row));
  }

  async detail(user: AuthenticatedUser, sessionId: string): Promise<SessionDetailView> {
    const row = await this.loadReadable(user, sessionId, 'read');
    const [materials, homework, attendance, presence, counts] = await Promise.all([
      this.materials(row.id),
      this.homeworkOf(row.id),
      this.attendanceCounts(row.id),
      this.presenceTallies(row.id, row.group_id),
      this.audienceCounts(row.group_id),
    ]);

    return {
      ...this.toItem(row),
      objectives: row.objectives,
      cancel_reason: row.cancel_reason,
      changed_by_name: row.changed_by_name,
      enrolled_count: counts.enrolled,
      guardian_count: counts.guardians,
      family_count: counts.families,
      materials,
      homework,
      attendance,
      presence,
      summary:
        row.summary && row.summary_sent_at
          ? { body: row.summary, sent_at: row.summary_sent_at.toISOString() }
          : null,
    };
  }

  /** Adds or edits the content of a session; marks it customised. */
  async update(
    user: AuthenticatedUser,
    sessionId: string,
    input: UpdateSessionDto,
  ): Promise<SessionDetailView> {
    const row = await this.loadReadable(user, sessionId, 'update');
    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update session
            set title = coalesce($2, title),
                theme = coalesce($3, theme),
                objectives = coalesce($4, objectives),
                is_customized = true,
                updated_at = now()
          where id = $1`,
        [row.id, input.title?.trim() ?? null, input.theme?.trim() ?? null, input.objectives ?? null],
      );
      for (const material of input.materials ?? []) {
        await tx.query(
          `update material set visibility = $3
            where id = $1 and session_id = $2 and deleted_at is null`,
          [material.id, row.id, material.visibility],
        );
      }
      await this.audit(tx, user.id, 'session.update', row.id, {
        group_id: row.group_id,
        fields: Object.keys(input),
      });
    });
    return this.detail(user, sessionId);
  }

  async addMaterial(
    user: AuthenticatedUser,
    sessionId: string,
    input: AddMaterialDto,
  ): Promise<MaterialView> {
    const row = await this.loadReadable(user, sessionId, 'update');
    const rows: Array<{ id: string }> = await this.dataSource.query(
      `insert into material (session_id, storage_key, title, kind, visibility, size_bytes)
       values ($1, $2, $3, $4, $5, $6)
       returning id`,
      [
        row.id,
        input.storage_key,
        input.title?.trim() || null,
        input.kind,
        input.visibility ?? 'after_session',
        input.size_bytes ?? null,
      ],
    );
    await this.dataSource.query(
      `update session set is_customized = true, updated_at = now() where id = $1`,
      [row.id],
    );
    const materials = await this.materials(row.id);
    return materials.find((material) => material.id === rows[0].id)!;
  }

  async removeMaterial(user: AuthenticatedUser, materialId: string): Promise<void> {
    const rows: Array<{ session_id: string }> = await this.dataSource.query(
      'select session_id from material where id = $1 and deleted_at is null',
      [materialId],
    );
    if (rows.length === 0) throw ApiError.scopeForbidden('No such material, or not yours.');
    await this.loadReadable(user, rows[0].session_id, 'update');
    await this.dataSource.query('update material set deleted_at = now() where id = $1', [
      materialId,
    ]);
  }

  /**
   * Cancels or moves a session and tells everyone it concerns: the
   * group's guardians, its educators and the executives. Less than 24h
   * out it is a critical notice, on the same lane as an absence alert
   * (`09-notifications-spec.md`); otherwise a normal one.
   */
  async change(
    user: AuthenticatedUser,
    sessionId: string,
    input: ChangeSessionDto,
  ): Promise<{ notified_count: number; guardian_count: number }> {
    const row = await this.loadReadable(user, sessionId, 'update');
    if (row.status === 'cancelled') {
      throw ApiError.validationFailed({ status: 'already cancelled' });
    }
    if (input.mode === 'reschedule' && (!input.starts_at || !input.ends_at)) {
      throw ApiError.validationFailed({ starts_at: 'required to reschedule' });
    }
    const locale = await loadLocale(this.dataSource, user.id);
    const soon = row.starts_at.getTime() - Date.now() < 24 * 3600 * 1000;

    const result = await this.dataSource.transaction(async (tx) => {
      if (input.mode === 'cancel') {
        await tx.query(
          `update session
              set status = 'cancelled', cancel_reason = $2, changed_by = $3, changed_at = now(),
                  updated_at = now()
            where id = $1`,
          [row.id, input.reason.trim(), user.id],
        );
      } else {
        await tx.query(
          `update session
              set rescheduled_from = coalesce(rescheduled_from, starts_at),
                  starts_at = $2, ends_at = $3, place = coalesce($4, place),
                  cancel_reason = $5, changed_by = $6, changed_at = now(),
                  is_customized = true, updated_at = now()
            where id = $1`,
          [row.id, input.starts_at, input.ends_at, input.place?.trim() || null, input.reason.trim(), user.id],
        );
      }

      const guardians = await this.notify.guardiansOfGroup(tx, row.group_id);
      const educators = await this.notify.educatorsOfGroup(tx, row.group_id);
      const oversight = await this.notify.oversightUsers(tx);
      const recipients = [...guardians, ...educators, ...oversight].filter((id) => id !== user.id);

      const when = formatSlot(locale, input.mode === 'reschedule' ? new Date(input.starts_at!) : row.starts_at);
      const title =
        input.mode === 'cancel'
          ? pick(locale, {
              ar: `أُلغيت جلسة ${row.group_name}`,
              fr: `Séance annulée — ${row.group_name}`,
              en: `Session cancelled — ${row.group_name}`,
            })
          : pick(locale, {
              ar: `أُجّلت جلسة ${row.group_name} إلى ${when}`,
              fr: `Séance reportée — ${row.group_name}, ${when}`,
              en: `Session moved — ${row.group_name}, ${when}`,
            });
      const notified = await this.notify.notify(tx, recipients, {
        kind: soon ? 'critical' : 'other',
        title,
        body: input.reason.trim(),
        destination: 'groups',
        data: { type: 'session-change', session_id: row.id },
      });

      await this.audit(tx, user.id, input.mode === 'cancel' ? 'session.cancel' : 'session.reschedule', row.id, {
        group_id: row.group_id,
        reason: input.reason.trim(),
        notified: notified.length,
        within_24h: soon,
        ...(input.mode === 'reschedule' ? { from: row.starts_at.toISOString(), to: input.starts_at } : {}),
      });
      return { notified, guardians: guardians.length, title };
    });

    if (soon) {
      await this.criticalQueue.add(
        CriticalJob.SESSION_CHANGE,
        { sessionId: row.id, groupId: row.group_id, mode: input.mode, changedAt: new Date().toISOString() },
        { jobId: `session-change-${row.id}-${Date.now()}` },
      );
    }
    await this.notify.pushTo(this.dataSource.manager, result.notified, {
      kind: soon ? 'critical' : 'other',
      title: result.title,
      body: input.reason.trim(),
      data: { type: 'session-change', session_id: row.id },
    });

    return { notified_count: result.notified.length, guardian_count: result.guardians };
  }

  /** "What we did today", sent once to the group's guardians. */
  async sendSummary(
    user: AuthenticatedUser,
    sessionId: string,
    input: SendSummaryDto,
  ): Promise<{ sent_at: string; family_count: number }> {
    const row = await this.loadReadable(user, sessionId, 'update');
    if (row.summary_sent_at) throw ApiError.summaryAlreadySent();
    const locale = await loadLocale(this.dataSource, user.id);

    return this.dataSource.transaction(async (tx) => {
      const rows = updatedRows<{ summary_sent_at: Date }>(await tx.query(
        `update session
            set summary = $2, summary_sent_at = now(), status = 'delivered',
                is_customized = true, updated_at = now()
          where id = $1
          returning summary_sent_at`,
        [row.id, input.body.trim()],
      ));
      for (const key of input.media_keys ?? []) {
        await tx.query(
          `insert into material (session_id, storage_key, title, kind, visibility)
           values ($1, $2, $3, 'image', 'after_session')`,
          [row.id, key, pick(locale, { ar: 'صورة من الجلسة', fr: 'Photo de la séance', en: 'Session photo' })],
        );
      }
      const guardians = await this.notify.guardiansOfGroup(tx, row.group_id);
      await this.notify.notify(tx, guardians, {
        kind: 'other',
        title: pick(locale, {
          ar: `ملخّص جلسة ${row.group_name}`,
          fr: `Résumé de la séance — ${row.group_name}`,
          en: `Session summary — ${row.group_name}`,
        }),
        body: input.body.trim().slice(0, 140),
        destination: 'groups',
        data: { type: 'session-summary', session_id: row.id },
      });
      await this.audit(tx, user.id, 'session.summary', row.id, {
        group_id: row.group_id,
        media_count: input.media_keys?.length ?? 0,
        guardians: guardians.length,
      });
      const counts = await this.audienceCounts(row.group_id, tx);
      return { sent_at: rows[0].summary_sent_at.toISOString(), family_count: counts.families };
    });
  }

  /** Who said they are coming, who declined and why, who never answered. */
  async presence(user: AuthenticatedUser, sessionId: string): Promise<PresenceOverviewView> {
    const row = await this.loadReadable(user, sessionId, 'read');
    const confirmation = await this.confirmationOf(row.id);
    const children: Array<{ id: string; full_name: string; answer: string | null; reason: string | null }> =
      await this.dataSource.query(
        `select c.id, c.full_name, pa.answer, pa.reason
           from child_group cg
           join child c on c.id = cg.child_id and c.deleted_at is null
           left join presence_confirmation pc on pc.session_id = $1
           left join presence_answer pa on pa.presence_confirmation_id = pc.id and pa.child_id = c.id
          where cg.group_id = $2 and cg.valid_to is null
          order by c.full_name, c.id`,
        [row.id, row.group_id],
      );

    const tallies: PresenceTallies = { yes: 0, late: 0, no: 0, none: 0 };
    const grouped = new Map<'none' | 'no' | 'late' | 'yes', PresenceOverviewView['groups'][number]['children']>([
      ['none', []],
      ['no', []],
      ['late', []],
      ['yes', []],
    ]);
    for (const child of children) {
      const answer = (child.answer ?? 'none') as keyof PresenceTallies;
      tallies[answer] += 1;
      grouped.get(answer)!.push({ id: child.id, full_name: child.full_name, reason: child.reason });
    }

    return {
      session_id: row.id,
      sent_at: confirmation?.sent_at?.toISOString() ?? null,
      deadline_at: confirmation?.deadline_at?.toISOString() ?? null,
      reminder_sent_at: confirmation?.reminder_sent_at?.toISOString() ?? null,
      enrolled_count: children.length,
      expected: tallies.yes + tallies.late,
      tallies,
      groups: [...grouped.entries()].map(([answer, list]) => ({ answer, children: list })),
    };
  }

  /** One reminder to the guardians who have not answered — never a second. */
  async remind(user: AuthenticatedUser, sessionId: string): Promise<{ reminded_count: number; sent_at: string }> {
    const row = await this.loadReadable(user, sessionId, 'update');
    const confirmation = await this.confirmationOf(row.id);
    if (!confirmation || !confirmation.sent_at) {
      throw ApiError.validationFailed({ session: 'no presence confirmation was sent' });
    }
    if (confirmation.reminder_sent_at) throw ApiError.presenceReminderAlreadySent();
    const locale = await loadLocale(this.dataSource, user.id);

    return this.dataSource.transaction(async (tx) => {
      const unanswered: Array<{ id: string }> = await tx.query(
        `select c.id
           from child_group cg
           join child c on c.id = cg.child_id and c.deleted_at is null
          where cg.group_id = $2 and cg.valid_to is null
            and not exists (select 1 from presence_answer pa
                             where pa.presence_confirmation_id = $1 and pa.child_id = c.id)`,
        [confirmation.id, row.group_id],
      );
      const guardians = await this.notify.guardiansOfChildren(tx, unanswered.map((child) => child.id));
      const rows = updatedRows<{ reminder_sent_at: Date }>(await tx.query(
        `update presence_confirmation set reminder_sent_at = now() where id = $1 returning reminder_sent_at`,
        [confirmation.id],
      ));
      await this.notify.notify(tx, guardians, {
        kind: 'other',
        title: pick(locale, {
          ar: `تذكير: هل سيحضر طفلك جلسة ${row.group_name}؟`,
          fr: `Rappel : votre enfant vient-il à la séance ${row.group_name} ?`,
          en: `Reminder: is your child coming to ${row.group_name}?`,
        }),
        body: formatSlot(locale, row.starts_at),
        destination: 'groups',
        data: { type: 'presence-reminder', session_id: row.id },
      });
      await this.audit(tx, user.id, 'presence.remind', row.id, {
        group_id: row.group_id,
        guardians: guardians.length,
      });
      return { reminded_count: guardians.length, sent_at: rows[0].reminder_sent_at.toISOString() };
    });
  }

  // --- Shared with the homework and today services --------------------------

  async loadReadable(
    user: AuthenticatedUser,
    sessionId: string,
    action: 'read' | 'update',
  ): Promise<SessionRow> {
    const rows = await this.rows('s.id = $1', [sessionId], '');
    const row = rows[0];
    if (!row) throw ApiError.scopeForbidden('No such session, or not yours.');
    const ability = defineAbilityFor(user);
    if (!ability.can(action, subject('Session', { id: row.id, groupId: row.group_id, branchId: row.branch_id }))) {
      throw ApiError.scopeForbidden();
    }
    return row;
  }

  async scopedGroupIds(user: AuthenticatedUser, groupId?: string): Promise<string[]> {
    if (user.hasOversight) {
      const rows: Array<{ id: string }> = await this.dataSource.query(
        `select g.id from "group" g
          where g.deleted_at is null
            ${user.branchId ? 'and g.branch_id = $1' : ''}
            ${groupId ? `and g.id = $${user.branchId ? 2 : 1}` : ''}`,
        [user.branchId, groupId].filter((value) => value !== null && value !== undefined),
      );
      return rows.map((row) => row.id);
    }
    const mine = [...user.reachableGroupIds];
    return groupId ? mine.filter((id) => id === groupId) : mine;
  }

  async homeworkOf(sessionId: string, manager: EntityManager | DataSource = this.dataSource): Promise<HomeworkView[]> {
    const rows: Array<{
      id: string;
      session_id: string;
      title: string | null;
      instructions: string;
      due_at: Date;
      target_child_ids: string[] | null;
      attachment_storage_key: string | null;
      created_at: Date;
      target_count: number;
      done_count: number;
    }> = await manager.query(
      `select h.id, h.session_id, h.title, h.instructions, h.due_at, h.target_child_ids,
              h.attachment_storage_key, h.created_at,
              (select count(*) from homework_status hs where hs.homework_id = h.id)::int as target_count,
              (select count(*) from homework_status hs where hs.homework_id = h.id and hs.done)::int as done_count
         from homework h
        where h.session_id = $1 and h.deleted_at is null
        order by h.created_at desc`,
      [sessionId],
    );
    return rows.map((row) => ({
      id: row.id,
      session_id: row.session_id,
      title: row.title,
      instructions: row.instructions,
      due_at: row.due_at.toISOString(),
      target_child_ids: row.target_child_ids,
      target_count: row.target_count,
      done_count: row.done_count,
      attachment_url: row.attachment_storage_key ? MediaService.urlFor(row.attachment_storage_key) : null,
      created_at: row.created_at.toISOString(),
    }));
  }

  async presenceTallies(
    sessionId: string,
    groupId: string,
    manager: EntityManager | DataSource = this.dataSource,
  ): Promise<(PresenceTallies & { sent: boolean }) | null> {
    const rows: Array<{ sent: boolean; yes: number; late: number; no: number; none: number }> =
      await manager.query(
        `select (pc.sent_at is not null) as sent,
                count(*) filter (where pa.answer = 'yes')::int as yes,
                count(*) filter (where pa.answer = 'late')::int as late,
                count(*) filter (where pa.answer = 'no')::int as no,
                count(*) filter (where pa.answer is null)::int as none
           from presence_confirmation pc
           join child_group cg on cg.group_id = $2 and cg.valid_to is null
           join child c on c.id = cg.child_id and c.deleted_at is null
           left join presence_answer pa on pa.presence_confirmation_id = pc.id and pa.child_id = c.id
          where pc.session_id = $1
          group by pc.sent_at`,
        [sessionId, groupId],
      );
    const row = rows[0];
    return row ? { sent: row.sent, yes: row.yes, late: row.late, no: row.no, none: row.none } : null;
  }

  async attendanceCounts(
    sessionId: string,
    manager: EntityManager | DataSource = this.dataSource,
  ): Promise<SessionDetailView['attendance']> {
    const rows: Array<{ present: number; late: number; excused: number; absent: number }> =
      await manager.query(
        `select count(*) filter (where status = 'present')::int as present,
                count(*) filter (where status = 'late')::int as late,
                count(*) filter (where status = 'excused')::int as excused,
                count(*) filter (where status = 'absent')::int as absent
           from attendance_record
          where session_id = $1 and superseded_at is null`,
        [sessionId],
      );
    const row = rows[0] ?? { present: 0, late: 0, excused: 0, absent: 0 };
    const recorded = row.present + row.late + row.excused + row.absent > 0;
    return { recorded, ...row };
  }

  async audienceCounts(
    groupId: string,
    manager: EntityManager | DataSource = this.dataSource,
  ): Promise<{ enrolled: number; guardians: number; families: number }> {
    const rows: Array<{ enrolled: number; guardians: number; families: number }> = await manager.query(
      `with kids as (
         select c.id from child_group cg
           join child c on c.id = cg.child_id and c.deleted_at is null
          where cg.group_id = $1 and cg.valid_to is null),
       links as (
         select pc.guardian_user_id, pc.child_id from parent_child pc
          where pc.child_id in (select id from kids) and pc.unlinked_at is null)
       select (select count(*) from kids)::int as enrolled,
              (select count(distinct guardian_user_id) from links)::int as guardians,
              (select count(distinct household) from (
                 select string_agg(guardian_user_id::text, ',' order by guardian_user_id) as household
                   from links group by child_id) h)::int as families`,
      [groupId],
    );
    return rows[0] ?? { enrolled: 0, guardians: 0, families: 0 };
  }

  toItem(row: SessionRow): SessionListItem {
    return {
      id: row.id,
      group: { id: row.group_id, name: row.group_name },
      title: row.title,
      theme: row.theme,
      starts_at: row.starts_at.toISOString(),
      ends_at: row.ends_at.toISOString(),
      place: row.place,
      status: row.status,
      is_customized: row.is_customized,
      has_content: row.is_customized || row.title !== null || row.objectives !== null,
      material_count: row.material_count,
      homework_count: row.homework_count,
      attendance_recorded: row.attendance_recorded,
      summary_sent: row.summary_sent_at !== null,
      rescheduled_from: row.rescheduled_from ? row.rescheduled_from.toISOString() : null,
      co_educator_names: row.co_educator_names,
    };
  }

  rows(where: string, params: unknown[], orderBy: string): Promise<SessionRow[]> {
    return this.dataSource.query(
      `select s.id, s.group_id, g.name as group_name, g.branch_id,
              s.title, s.theme, s.objectives, s.starts_at, s.ends_at, s.place, s.status,
              s.is_customized, s.summary, s.summary_sent_at, s.cancel_reason,
              s.rescheduled_from, s.changed_by,
              case when s.changed_by is null then null else ${displayNameOf('s.changed_by')} end
                as changed_by_name,
              (select count(*) from material m where m.session_id = s.id and m.deleted_at is null)::int
                as material_count,
              (select count(*) from homework h where h.session_id = s.id and h.deleted_at is null)::int
                as homework_count,
              exists (select 1 from attendance_record ar
                       where ar.session_id = s.id and ar.superseded_at is null) as attendance_recorded,
              coalesce((select json_agg(${displayNameOf('ge.educator_user_id')} order by ge.assigned_at)
                          from group_educator ge
                         where ge.group_id = s.group_id and ge.unassigned_at is null), '[]'::json)
                as co_educator_names
         from session s
         join "group" g on g.id = s.group_id
        where s.deleted_at is null and ${where}
        ${orderBy}`,
      params,
    );
  }

  private async materials(sessionId: string): Promise<MaterialView[]> {
    const rows: Array<{
      id: string;
      kind: MaterialKind;
      title: string | null;
      storage_key: string;
      visibility: MaterialVisibility;
      size_bytes: number | null;
    }> = await this.dataSource.query(
      `select id, kind, title, storage_key, visibility, size_bytes
         from material
        where session_id = $1 and deleted_at is null
        order by created_at, id`,
      [sessionId],
    );
    return rows.map((row) => ({
      ...row,
      url: row.kind === 'link' ? row.storage_key : MediaService.urlFor(row.storage_key),
    }));
  }

  private async confirmationOf(
    sessionId: string,
  ): Promise<{ id: string; sent_at: Date | null; deadline_at: Date | null; reminder_sent_at: Date | null } | null> {
    const rows: Array<{ id: string; sent_at: Date | null; deadline_at: Date | null; reminder_sent_at: Date | null }> =
      await this.dataSource.query(
        'select id, sent_at, deadline_at, reminder_sent_at from presence_confirmation where session_id = $1',
        [sessionId],
      );
    return rows[0] ?? null;
  }

  private async audit(
    tx: EntityManager,
    actorId: string,
    action: string,
    sessionId: string,
    meta: Record<string, unknown>,
  ): Promise<void> {
    await tx.query(
      `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
       values ($1, $2, 'session', $3, $4::jsonb)`,
      [actorId, action, sessionId, JSON.stringify(meta)],
    );
  }
}

/**
 * TypeORM hands back `[rows, rowCount]` for an UPDATE and plain rows for
 * everything else; this reads the rows either way.
 */
function updatedRows<T>(result: unknown): T[] {
  if (Array.isArray(result) && Array.isArray(result[0])) return result[0] as T[];
  return (result as T[]) ?? [];
}

function isoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

/** "السبت 27 سبتمبر · 10:00" in the organisation's zone. */
export function formatSlot(locale: Locale, at: Date): string {
  const tag = locale === 'ar' ? 'ar-MA-u-nu-latn' : locale === 'fr' ? 'fr-MA' : 'en-GB';
  const day = new Intl.DateTimeFormat(tag, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    timeZone: ORG_TIMEZONE,
  }).format(at);
  const time = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
    timeZone: ORG_TIMEZONE,
  }).format(at);
  return `${day} · ${time}`;
}
