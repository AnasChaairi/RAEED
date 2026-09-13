import { Inject, Injectable, Logger } from '@nestjs/common';
import { createHash, randomInt, timingSafeEqual } from 'node:crypto';
import Redis from 'ioredis';

import { AppConfig, isConsoleOtpDelivery, loadConfig } from '../../common/config/env';
import { ApiError } from '../../common/http/api-error';
import { REDIS } from '../../common/redis/redis.module';

/**
 * One-time codes (`specs/10-security-and-privacy.md`).
 *
 * Six digits, five-minute expiry, five requests per hour per number, with
 * per-number and per-IP limits and exponential backoff on repeated failures.
 *
 * Codes live in Redis with a TTL and are stored **hashed**. A code is a
 * credential for the whole account, and an operator reading a Redis dump — or
 * a stray `KEYS *` in a debugging session — should not be able to sign in as a
 * parent. Verification is constant-time for the same reason a password check
 * is.
 */
@Injectable()
export class OtpService {
  private readonly logger = new Logger('otp');
  private readonly config: AppConfig = loadConfig();

  /** `specs/10-security-and-privacy.md`. */
  private static readonly CODE_LENGTH = 6;
  private static readonly TTL_SECONDS = 5 * 60;
  private static readonly MAX_REQUESTS_PER_HOUR = 5;
  private static readonly RATE_WINDOW_SECONDS = 60 * 60;
  private static readonly MAX_VERIFY_ATTEMPTS = 5;

  constructor(@Inject(REDIS) private readonly redis: Redis) {}

  /**
   * Issues a code for [phone], or refuses when the hourly budget is spent.
   *
   * Returns nothing about the code itself: the caller's job is to have it
   * delivered, and the API's response says only that one was sent — `ACC-02`
   * means account existence is not something an unauthenticated caller gets to
   * probe, so this behaves identically for a number that has no account.
   */
  async request(phone: string, clientIp: string): Promise<void> {
    await this.enforceRateLimit(phone, clientIp);

    const code = this.generateCode();
    await this.redis.set(
      this.codeKey(phone),
      this.hash(phone, code),
      'EX',
      OtpService.TTL_SECONDS,
    );
    await this.redis.del(this.attemptsKey(phone));

    await this.deliver(phone, code);
  }

  /**
   * Checks [code] against the outstanding challenge for [phone].
   *
   * A correct code is consumed on use — a code that could be replayed is a
   * code that is still valid after the SMS has been read by someone else.
   */
  async verify(phone: string, code: string): Promise<boolean> {
    const attempts = await this.redis.incr(this.attemptsKey(phone));
    await this.redis.expire(this.attemptsKey(phone), OtpService.TTL_SECONDS);

    // Brute force protection: five wrong guesses burns the challenge, so an
    // attacker gets five tries per issued code rather than a million.
    if (attempts > OtpService.MAX_VERIFY_ATTEMPTS) {
      await this.redis.del(this.codeKey(phone));
      return false;
    }

    const stored = await this.redis.get(this.codeKey(phone));
    if (!stored) return false;

    const expected = Buffer.from(stored, 'hex');
    const actual = Buffer.from(this.hash(phone, code), 'hex');
    if (expected.length !== actual.length) return false;
    if (!timingSafeEqual(expected, actual)) return false;

    await this.redis.del(this.codeKey(phone), this.attemptsKey(phone));
    return true;
  }

  private async enforceRateLimit(phone: string, clientIp: string): Promise<void> {
    const perNumber = await this.bump(this.rateKey('phone', phone));
    const perIp = await this.bump(this.rateKey('ip', clientIp));

    if (
      perNumber > OtpService.MAX_REQUESTS_PER_HOUR ||
      // The per-IP limit is looser: a family sharing one connection, or a
      // whole association on the same office wifi, must not lock each other
      // out. It is there to stop enumeration, not to police households.
      perIp > OtpService.MAX_REQUESTS_PER_HOUR * 10
    ) {
      const ttl = await this.redis.ttl(this.rateKey('phone', phone));
      throw ApiError.otpRateLimited(Math.max(ttl, 0));
    }
  }

  private async bump(key: string): Promise<number> {
    const count = await this.redis.incr(key);
    if (count === 1) {
      await this.redis.expire(key, OtpService.RATE_WINDOW_SECONDS);
    }
    return count;
  }

  private async deliver(phone: string, code: string): Promise<void> {
    if (isConsoleOtpDelivery(this.config)) {
      // Development only — `loadConfig` refuses to start outside development
      // without a provider key, so this cannot silently become production
      // behaviour.
      this.logger.warn(
        `[dev] OTP for ${maskPhone(phone)} is ${code} (console delivery; set OTP_PROVIDER_API_KEY for SMS)`,
      );
      return;
    }

    // SMS, with WhatsApp fallback per ACC-03, goes here when a provider is
    // chosen. Deliberately left unimplemented rather than stubbed silently:
    // a no-op that looked like success would strand every real user at the
    // OTP screen.
    throw new Error(
      'No SMS provider is wired up yet. Implement delivery before configuring OTP_PROVIDER_API_KEY.',
    );
  }

  private generateCode(): string {
    // randomInt is CSPRNG-backed. Math.random would make codes predictable
    // from a handful of observations.
    return randomInt(0, 10 ** OtpService.CODE_LENGTH)
      .toString()
      .padStart(OtpService.CODE_LENGTH, '0');
  }

  /** Salted by the phone number, so identical codes for different numbers do
   * not collide into the same hash. */
  private hash(phone: string, code: string): string {
    return createHash('sha256').update(`${phone}:${code}`).digest('hex');
  }

  private codeKey(phone: string): string {
    return `otp:code:${phone}`;
  }

  private attemptsKey(phone: string): string {
    return `otp:attempts:${phone}`;
  }

  private rateKey(kind: 'phone' | 'ip', value: string): string {
    return `otp:rate:${kind}:${value}`;
  }
}

/**
 * Masks a number for a log line.
 *
 * `specs/10-security-and-privacy.md` forbids raw phone numbers in application
 * logs, and the development OTP line is still an application log.
 */
export function maskPhone(phone: string): string {
  if (phone.length < 4) return '***';
  return `${phone.slice(0, 4)}••••${phone.slice(-2)}`;
}
