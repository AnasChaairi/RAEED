import { Inject, Injectable, Logger, OnApplicationShutdown, OnModuleInit } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { Queue, Worker } from 'bullmq';
import Redis from 'ioredis';
import { DataSource, EntityManager } from 'typeorm';

import { presenceSettings } from '../../common/config/env';
import { Locale, ORG_TIMEZONE, pick } from '../../common/i18n/user-locale';
import { NORMAL_QUEUE, NormalJob, QUEUE_NORMAL, QUEUE_PREFIX } from '../../common/queue/queues';
import { REDIS } from '../../common/redis/redis.module';
import { NotifyService } from '../notifications/notify.service';
import { SessionsService, formatSlot } from './sessions.service';

interface DueSession {
  id: string;
  group_id: string;
  group_name: string;
  starts_at: Date;
}

interface DueReminder {
  id: string;
  session_id: string;
  group_id: string;
  group_name: string;
  starts_at: Date;
}

interface GuardianRow {
  user_id: string;
  preferred_locale: string | null;
}

/**
 * ATT-03 — the presence question goes out by itself.
 *
 * A repeatable job on the normal queue looks every few minutes. For every
 * planned session whose "evening before" has come, it opens the
 * `presence_confirmation`, sets the deadline and tells the group's guardians
 * in their own language; once, before the deadline, it reminds the ones who
 * have not answered. The educator's manual reminder (`POST …/presence/remind`)
 * keeps working and counts as the one reminder.
 *
 * Sessions are generated from the weekly schedule first, so a group nobody
 * has opened on the app still gets its question. Every step is idempotent —
 * one confirmation per session, one reminder — so two API instances ticking
 * at once cannot ask twice.
 */
@Injectable()
export class PresenceScheduler implements OnModuleInit, OnApplicationShutdown {
  private readonly logger = new Logger('presence');
  private readonly config = presenceSettings();
  private worker?: Worker;

  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    @Inject(REDIS) private readonly redis: Redis,
    @Inject(QUEUE_NORMAL) private readonly queue: Queue,
    private readonly sessions: SessionsService,
    private readonly notify: NotifyService,
  ) {}

  async onModuleInit(): Promise<void> {
    if (process.env.NODE_ENV === 'test') return;
    await this.queue.add(
      NormalJob.PRESENCE_TICK,
      {},
      {
        jobId: 'presence-tick',
        repeat: { every: Math.max(1, this.config.tickMinutes) * 60_000 },
        removeOnComplete: true,
        removeOnFail: { age: 24 * 3_600 },
      },
    );
    this.worker = new Worker(
      NORMAL_QUEUE,
      async (job) => {
        if (job.name === NormalJob.PRESENCE_TICK) await this.tick();
      },
      { connection: this.redis.duplicate(), prefix: QUEUE_PREFIX, concurrency: 1 },
    );
    this.worker.on('failed', (job, error) => {
      this.logger.error(`presence tick failed (${job?.id ?? 'unknown'}): ${error.message}`);
    });
  }

  async onApplicationShutdown(): Promise<void> {
    await this.worker?.close();
  }

  /** One pass: generate, ask what is due, remind what is due. */
  async tick(now: Date = new Date()): Promise<{ asked: number; reminded: number }> {
    await this.generateUpcoming(now);
    const asked = await this.askDue(now);
    const reminded = await this.remindDue(now);
    if (asked > 0 || reminded > 0) {
      this.logger.log(`presence tick: asked=${asked} reminded=${reminded}`);
    }
    return { asked, reminded };
  }

  private async generateUpcoming(now: Date): Promise<void> {
    const groups: Array<{ id: string }> = await this.dataSource.query(
      `select g.id from "group" g
         join season se on se.id = g.season_id and se.status = 'active'
        where g.deleted_at is null`,
    );
    await this.sessions.ensureGenerated(
      this.dataSource,
      groups.map((row) => row.id),
      now,
      new Date(now.getTime() + 3 * 24 * 3_600_000),
    );
  }

  /**
   * Sessions whose question is due: planned, not started, no confirmation
   * yet, and the send moment — the configured hour of the day before, in the
   * association's time zone — has passed. A session added inside that window
   * is due at once.
   */
  private async askDue(now: Date): Promise<number> {
    const due: DueSession[] = await this.dataSource.query(
      `select s.id, s.group_id, g.name as group_name, s.starts_at
         from session s
         join "group" g on g.id = s.group_id and g.deleted_at is null
        where s.deleted_at is null and s.status = 'planned'
          and s.starts_at > $1
          and not exists (select 1 from presence_confirmation pc where pc.session_id = s.id)
          and ((date_trunc('day', s.starts_at at time zone $2) - interval '1 day'
                + make_interval(hours => $3::int)) at time zone $2) <= $1
        order by s.starts_at`,
      [now, ORG_TIMEZONE, this.config.sendHour],
    );
    let asked = 0;
    for (const session of due) {
      const sent = await this.ask(session, now);
      if (sent) asked += 1;
    }
    return asked;
  }

  private async ask(session: DueSession, now: Date): Promise<boolean> {
    const deadlineFromSession = session.starts_at.getTime() - this.config.deadlineHoursBefore * 3_600_000;
    const deadline = new Date(Math.max(deadlineFromSession, now.getTime() + 30 * 60_000));

    const result = await this.dataSource.transaction(async (tx) => {
      const rows: Array<{ id: string }> = await tx.query(
        `insert into presence_confirmation (session_id, sent_at, deadline_at)
         values ($1, $2, $3)
         on conflict (session_id) do nothing
         returning id`,
        [session.id, now, deadline],
      );
      if (rows.length === 0) return null;
      const guardians = await this.guardiansOfGroup(tx, session.group_id);
      const notified = await this.tellByLocale(tx, guardians, (locale) => ({
        title: pick(locale, {
          ar: `هل سيحضر طفلك جلسة ${session.group_name}؟`,
          fr: `Votre enfant vient-il à la séance ${session.group_name} ?`,
          en: `Is your child coming to ${session.group_name}?`,
        }),
        body: formatSlot(locale, session.starts_at),
        type: 'presence-request',
        sessionId: session.id,
      }));
      return notified;
    });
    if (result === null) return false;
    await this.pushByLocale(result);
    return true;
  }

  /** Confirmations past their reminder moment with unanswered children. */
  private async remindDue(now: Date): Promise<number> {
    const due: DueReminder[] = await this.dataSource.query(
      `select pc.id, pc.session_id, s.group_id, g.name as group_name, s.starts_at
         from presence_confirmation pc
         join session s on s.id = pc.session_id and s.deleted_at is null and s.status = 'planned'
         join "group" g on g.id = s.group_id
        where pc.sent_at is not null and pc.reminder_sent_at is null
          and pc.deadline_at is not null and pc.deadline_at > $1
          and pc.deadline_at - make_interval(hours => $2::int) <= $1
        order by pc.deadline_at`,
      [now, this.config.reminderHoursBefore],
    );
    let reminded = 0;
    for (const confirmation of due) {
      if (await this.remind(confirmation, now)) reminded += 1;
    }
    return reminded;
  }

  private async remind(confirmation: DueReminder, now: Date): Promise<boolean> {
    const result = await this.dataSource.transaction(async (tx) => {
      const claimed: Array<{ id: string }> = await tx.query(
        `update presence_confirmation set reminder_sent_at = $2
          where id = $1 and reminder_sent_at is null returning id`,
        [confirmation.id, now],
      );
      if (claimed.length === 0) return null;
      const unanswered: GuardianRow[] = await tx.query(
        `select distinct pc.guardian_user_id as user_id, u.preferred_locale
           from child_group cg
           join child c on c.id = cg.child_id and c.deleted_at is null
           join parent_child pc on pc.child_id = c.id and pc.unlinked_at is null
           join app_user u on u.id = pc.guardian_user_id and u.is_active
          where cg.group_id = $2 and cg.valid_to is null
            and not exists (select 1 from presence_answer pa
                             where pa.presence_confirmation_id = $1 and pa.child_id = c.id)`,
        [confirmation.id, confirmation.group_id],
      );
      return this.tellByLocale(tx, unanswered, (locale) => ({
        title: pick(locale, {
          ar: `تذكير: هل سيحضر طفلك جلسة ${confirmation.group_name}؟`,
          fr: `Rappel : votre enfant vient-il à la séance ${confirmation.group_name} ?`,
          en: `Reminder: is your child coming to ${confirmation.group_name}?`,
        }),
        body: formatSlot(locale, confirmation.starts_at),
        type: 'presence-reminder',
        sessionId: confirmation.session_id,
      }));
    });
    if (result === null) return false;
    await this.pushByLocale(result);
    return true;
  }

  private async guardiansOfGroup(tx: EntityManager, groupId: string): Promise<GuardianRow[]> {
    return tx.query(
      `select distinct pc.guardian_user_id as user_id, u.preferred_locale
         from child_group cg
         join child c on c.id = cg.child_id and c.deleted_at is null
         join parent_child pc on pc.child_id = c.id and pc.unlinked_at is null
         join app_user u on u.id = pc.guardian_user_id and u.is_active
        where cg.group_id = $1 and cg.valid_to is null`,
      [groupId],
    );
  }

  /** One notification row per guardian, worded in that guardian's language. */
  private async tellByLocale(
    tx: EntityManager,
    guardians: GuardianRow[],
    content: (locale: Locale) => { title: string; body: string; type: string; sessionId: string },
  ): Promise<Array<{ userIds: string[]; title: string; body: string; type: string; sessionId: string }>> {
    const byLocale = new Map<Locale, string[]>();
    for (const guardian of guardians) {
      const locale = asLocale(guardian.preferred_locale);
      byLocale.set(locale, [...(byLocale.get(locale) ?? []), guardian.user_id]);
    }
    const batches: Array<{ userIds: string[]; title: string; body: string; type: string; sessionId: string }> = [];
    for (const [locale, userIds] of byLocale) {
      const words = content(locale);
      await this.notify.notify(tx, userIds, {
        kind: 'other',
        title: words.title,
        body: words.body,
        destination: 'groups',
        data: { type: words.type, session_id: words.sessionId },
      });
      batches.push({ userIds, ...words });
    }
    return batches;
  }

  private async pushByLocale(
    batches: Array<{ userIds: string[]; title: string; body: string; type: string; sessionId: string }>,
  ): Promise<void> {
    for (const batch of batches) {
      await this.notify.pushTo(this.dataSource.manager, batch.userIds, {
        kind: 'other',
        title: batch.title,
        body: batch.body,
        data: { type: batch.type, session_id: batch.sessionId },
      });
    }
  }
}

function asLocale(value: string | null): Locale {
  return value === 'fr' || value === 'en' ? value : 'ar';
}
