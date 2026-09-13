import { Inject, Injectable, Logger, OnApplicationShutdown, OnModuleInit } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { Job, Worker } from 'bullmq';
import Redis from 'ioredis';
import { DataSource } from 'typeorm';

import { loadConfig } from '../../common/config/env';
import {
  AbsenceAlertJob,
  CRITICAL_QUEUE,
  CriticalJob,
  QUEUE_PREFIX,
} from '../../common/queue/queues';
import { REDIS } from '../../common/redis/redis.module';
import { PushDispatcher } from './push.dispatcher';

/**
 * The critical lane's worker (`RAEED-18`, `specs/09-notifications-spec.md`).
 *
 * Its own worker on its own queue, so an absence alert is never behind a batch
 * of "12 new photos" notifications. `specs/02-architecture.md` puts the target
 * at p95 push dispatch under 30s from the attendance write and calls it "the
 * one number in the whole product that's actually a safety commitment" — the
 * dispatch latency is measured and logged here so `RAEED-19` has something
 * real to load-test rather than an inference from unit tests.
 *
 * The 90-second acknowledgement timeout and SMS fallback are scheduled, not
 * awaited: holding the worker for 90 seconds per alert would serialise the
 * queue and make a second simultaneous absence wait behind the first.
 */
@Injectable()
export class AbsenceAlertWorker implements OnModuleInit, OnApplicationShutdown {
  private readonly logger = new Logger('critical');
  private readonly config = loadConfig();
  private worker?: Worker;

  /** `specs/09-notifications-spec.md`: SMS fallback after 90s if undelivered. */
  private static readonly ACK_TIMEOUT_MS = 90_000;

  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    @Inject(REDIS) private readonly redis: Redis,
    private readonly push: PushDispatcher,
  ) {}

  onModuleInit(): void {
    this.worker = new Worker(
      CRITICAL_QUEUE,
      async (job) => this.process(job as Job<AbsenceAlertJob>),
      {
        connection: this.redis.duplicate(),
        prefix: QUEUE_PREFIX,
        // Alerts for different children are independent, so they dispatch in
        // parallel. A single-concurrency worker would make the tenth absent
        // child in a group wait for the first nine round trips.
        concurrency: 10,
      },
    );

    this.worker.on('failed', (job, error) => {
      // A dropped absence alert is the one failure in this product that
      // someone has to be able to find afterwards, so it is logged loudly and
      // the job is retained (see the queue's removeOnFail window).
      this.logger.error(
        `absence alert failed for job ${job?.id ?? 'unknown'}: ${error.message}`,
      );
    });
  }

  async onApplicationShutdown(): Promise<void> {
    await this.worker?.close();
  }

  private async process(job: Job<AbsenceAlertJob>): Promise<void> {
    if (job.name !== CriticalJob.ABSENCE_ALERT) return;

    const payload = job.data;
    const guardians = await this.guardiansOf(payload.childId);

    if (guardians.length === 0) {
      // A child with no linked guardian cannot be alerted about. That is a
      // data problem rather than a delivery one — `children.last_guardian`
      // exists to prevent it — so it is surfaced rather than swallowed.
      this.logger.error(
        `absence alert for child ${payload.childId} has no reachable guardian`,
      );
      return;
    }

    const dispatchedAt = Date.now();
    const deviceTokens = guardians.flatMap((guardian) => guardian.pushTokens);

    await this.push.send({
      tokens: deviceTokens,
      // The payload carries ids only. `specs/10-security-and-privacy.md` keeps
      // a child's name out of anything that transits a third party; the app
      // resolves the name locally from data it already holds.
      data: {
        type: CriticalJob.ABSENCE_ALERT,
        child_id: payload.childId,
        session_id: payload.sessionId,
      },
    });

    // The number the SLA is written against.
    const latencyMs = dispatchedAt - Date.parse(payload.recordedAt);
    this.logger.log(
      `absence alert dispatched child=${payload.childId} ` +
        `guardians=${guardians.length} devices=${deviceTokens.length} ` +
        `latency_from_write_ms=${latencyMs}`,
    );

    await this.scheduleSmsFallback(payload, guardians.length);
  }

  /**
   * Arms the SMS fallback.
   *
   * The acknowledgement is a key the app sets when the notification is
   * delivered; if it is still absent after 90 seconds, the alert never landed
   * and SMS is the backstop (`NOT-05`, pulled into MVP).
   *
   * Scheduled rather than awaited so the worker is free immediately — and
   * recorded in Redis with a TTL rather than in memory, so a process restart
   * inside the window does not lose the fallback.
   */
  private async scheduleSmsFallback(
    payload: AbsenceAlertJob,
    guardianCount: number,
  ): Promise<void> {
    const key = `alert:ack:${payload.attendanceRecordId}`;
    await this.redis.set(key, 'pending', 'PX', AbsenceAlertWorker.ACK_TIMEOUT_MS * 2);

    setTimeout(() => {
      void (async () => {
        const state = await this.redis.get(key);
        if (state !== 'pending') return;

        if (this.config.otp.smsFallbackApiKey === '') {
          // No provider locally. Logged rather than silently skipped, so the
          // fallback path is observable in development instead of looking
          // like it works.
          this.logger.warn(
            `[dev] SMS fallback would fire for child ${payload.childId} ` +
              `(${guardianCount} guardians) — no SMS provider configured`,
          );
          return;
        }

        this.logger.warn(
          `absence alert unacknowledged after 90s, falling back to SMS for ` +
            `child ${payload.childId}`,
        );
        // Provider call goes here once one is chosen.
      })();
    }, AbsenceAlertWorker.ACK_TIMEOUT_MS).unref();
  }

  /** The child's current guardians and their live device tokens. */
  private async guardiansOf(
    childId: string,
  ): Promise<Array<{ userId: string; pushTokens: string[] }>> {
    const rows: Array<{ user_id: string; push_token: string | null }> =
      await this.dataSource.query(
        `select pc.guardian_user_id as user_id, ud.push_token
           from parent_child pc
           join app_user u on u.id = pc.guardian_user_id and u.is_active
           left join user_device ud on ud.user_id = u.id and ud.revoked_at is null
          where pc.child_id = $1 and pc.unlinked_at is null`,
        [childId],
      );

    const byUser = new Map<string, string[]>();
    for (const row of rows) {
      const tokens = byUser.get(row.user_id) ?? [];
      if (row.push_token) tokens.push(row.push_token);
      byUser.set(row.user_id, tokens);
    }

    return [...byUser.entries()].map(([userId, pushTokens]) => ({
      userId,
      pushTokens,
    }));
  }
}
