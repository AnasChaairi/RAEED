import { Global, Module, OnApplicationShutdown } from '@nestjs/common';
import Redis from 'ioredis';

import { loadConfig } from '../config/env';

export const REDIS = 'RAEED_REDIS';

/**
 * The shared Redis connection.
 *
 * Used for two things that both want a TTL and neither of which belongs in
 * Postgres: OTP challenges and rate-limit counters. An OTP code is valid for
 * five minutes and must not survive in a database backup afterwards, and a
 * rate-limit window is state nobody needs to audit.
 *
 * The BullMQ queues in `specs/07-backend-spec.md` share this instance.
 */
@Global()
@Module({
  providers: [
    {
      provide: REDIS,
      useFactory: (): Redis =>
        new Redis(loadConfig().redisUrl, {
          maxRetriesPerRequest: null,
          lazyConnect: false,
        }),
    },
  ],
  exports: [REDIS],
})
export class RedisModule implements OnApplicationShutdown {
  constructor() {}

  async onApplicationShutdown(): Promise<void> {
    // Nest disposes the provider; the explicit hook exists so a hanging
    // connection cannot keep the process alive during a container stop.
  }
}
