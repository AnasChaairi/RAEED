import { Global, Inject, Injectable, Module, OnApplicationShutdown } from '@nestjs/common';
import { Queue, QueueOptions } from 'bullmq';
import Redis from 'ioredis';

import { REDIS } from '../redis/redis.module';

/**
 * The two BullMQ lanes from `specs/07-backend-spec.md`.
 *
 * `critical` exists as a separate queue rather than as a high-priority job on
 * a shared one, and that distinction is the whole point of
 * `specs/02-architecture.md`'s design: a media-compression job or a batch of
 * "new materials" notifications must never sit in front of an absence alert.
 * A priority field on one queue would still leave the alert behind whatever is
 * already being processed; a dedicated queue with its own worker does not.
 */
// No colons: BullMQ uses `:` as its own Redis key separator and rejects it in
// a queue name. Namespacing is the `prefix` option below instead.
export const CRITICAL_QUEUE = 'critical';
export const NORMAL_QUEUE = 'normal';

/** Keeps RAEED's queue keys out of the way of anything else on this Redis. */
export const QUEUE_PREFIX = 'raeed';

/** Job names on the critical queue. */
export const CriticalJob = {
  /** `ATT-07` — a child marked absent with no prior declared absence. */
  ABSENCE_ALERT: 'absence-alert',
  /** An announcement published with `priority: urgent`. */
  URGENT_ANNOUNCEMENT: 'urgent-announcement-dispatch',
} as const;

/** The payload an absence alert carries. */
export interface AbsenceAlertJob {
  readonly attendanceRecordId: string;
  readonly sessionId: string;
  readonly childId: string;
  readonly groupId: string;
  /** Server time the mark was written — the clock the SLA is measured from. */
  readonly recordedAt: string;
}

export const QUEUE_CRITICAL = 'RAEED_QUEUE_CRITICAL';
export const QUEUE_NORMAL = 'RAEED_QUEUE_NORMAL';

function queueOptions(connection: Redis): QueueOptions {
  return {
    connection,
    prefix: QUEUE_PREFIX,
    defaultJobOptions: {
      // A failed alert retries hard and fast. The SLA is p95 push dispatch
      // under 30s from the attendance write (`specs/02-architecture.md`), so a
      // long backoff would blow it on the first transient FCM error.
      attempts: 5,
      backoff: { type: 'exponential', delay: 1_000 },
      // Completed jobs are kept briefly so the load test in RAEED-19 can
      // measure real dispatch latency rather than inferring it.
      removeOnComplete: { age: 3_600, count: 1_000 },
      // Failures are kept far longer: a dropped absence alert is the one
      // failure in this product someone has to be able to go back and find.
      removeOnFail: { age: 7 * 24 * 3_600 },
    },
  };
}

@Injectable()
export class QueueRegistry implements OnApplicationShutdown {
  constructor(
    @Inject(QUEUE_CRITICAL) readonly critical: Queue,
    @Inject(QUEUE_NORMAL) readonly normal: Queue,
  ) {}

  async onApplicationShutdown(): Promise<void> {
    await Promise.all([this.critical.close(), this.normal.close()]);
  }
}

@Global()
@Module({
  providers: [
    {
      provide: QUEUE_CRITICAL,
      inject: [REDIS],
      useFactory: (connection: Redis): Queue =>
        new Queue(CRITICAL_QUEUE, queueOptions(connection.duplicate())),
    },
    {
      provide: QUEUE_NORMAL,
      inject: [REDIS],
      useFactory: (connection: Redis): Queue =>
        new Queue(NORMAL_QUEUE, queueOptions(connection.duplicate())),
    },
    QueueRegistry,
  ],
  exports: [QUEUE_CRITICAL, QUEUE_NORMAL, QueueRegistry],
})
export class QueueModule {}
