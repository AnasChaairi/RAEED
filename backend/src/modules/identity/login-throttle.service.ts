import { Inject, Injectable } from '@nestjs/common';
import Redis from 'ioredis';

import { ApiError } from '../../common/http/api-error';
import { REDIS } from '../../common/redis/redis.module';

/**
 * Brute-force protection for `POST /auth/login`
 * (`specs/10-security-and-privacy.md`).
 *
 * A six-character password is only as safe as the number of guesses an
 * attacker gets, so the limits are per number and per address: five failed
 * attempts lock a number for fifteen minutes; an address is allowed a much
 * larger budget so a family sharing one connection, or the whole association
 * on the office wifi, cannot lock each other out.
 *
 * Counters live in Redis with a TTL. A successful sign-in clears the number's
 * counter — the lock exists to slow a guesser down, not to punish a guardian
 * who mistyped twice and then got it right.
 */
@Injectable()
export class LoginThrottle {
  static readonly MAX_FAILURES_PER_NUMBER = 5;
  static readonly MAX_FAILURES_PER_IP = 100;
  static readonly WINDOW_SECONDS = 15 * 60;

  constructor(@Inject(REDIS) private readonly redis: Redis) {}

  /** Refuses with `auth.rate_limited` while either budget is spent. */
  async assertAllowed(phone: string, clientIp: string): Promise<void> {
    const [byNumber, byIp] = await Promise.all([
      this.redis.get(this.key('phone', phone)),
      this.redis.get(this.key('ip', clientIp)),
    ]);
    if (
      Number(byNumber ?? 0) >= LoginThrottle.MAX_FAILURES_PER_NUMBER ||
      Number(byIp ?? 0) >= LoginThrottle.MAX_FAILURES_PER_IP
    ) {
      const ttl = await this.redis.ttl(this.key('phone', phone));
      throw ApiError.rateLimited(Math.max(ttl, 0));
    }
  }

  /** Counts one failed attempt against both budgets. */
  async recordFailure(phone: string, clientIp: string): Promise<void> {
    await Promise.all([this.bump(this.key('phone', phone)), this.bump(this.key('ip', clientIp))]);
  }

  /** Forgets the number's failures after a successful sign-in. */
  async reset(phone: string): Promise<void> {
    await this.redis.del(this.key('phone', phone));
  }

  private async bump(key: string): Promise<void> {
    const count = await this.redis.incr(key);
    if (count === 1) await this.redis.expire(key, LoginThrottle.WINDOW_SECONDS);
  }

  private key(kind: 'phone' | 'ip', value: string): string {
    return `login:failures:${kind}:${value}`;
  }
}
