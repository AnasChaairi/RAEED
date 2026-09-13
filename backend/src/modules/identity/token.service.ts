import { Inject, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { createHash, randomBytes } from 'node:crypto';
import Redis from 'ioredis';

import { loadConfig } from '../../common/config/env';
import { REDIS } from '../../common/redis/redis.module';

export interface TokenPair {
  readonly accessToken: string;
  readonly refreshToken: string;
}

/**
 * Issues and rotates the token pair (`specs/10-security-and-privacy.md`).
 *
 * A 15-minute access token plus a refresh token that is **device-scoped and
 * rotating**: each use mints a new one and invalidates the old. That is what
 * makes `DELETE /auth/sessions/{deviceId}` meaningful — revoking a device
 * revokes exactly that device, not every session the user has.
 *
 * Refresh tokens are stored hashed, for the same reason OTP codes are: the
 * token is a long-lived credential, and a Redis dump should not be a set of
 * working logins.
 */
@Injectable()
export class TokenService {
  private readonly config = loadConfig();

  constructor(
    private readonly jwt: JwtService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  /** Mints a fresh pair and registers the refresh token against the device. */
  async issue(userId: string, deviceId: string): Promise<TokenPair> {
    const accessToken = await this.jwt.signAsync(
      { sub: userId, device_id: deviceId },
      {
        secret: this.config.jwt.accessSecret,
        // Seconds rather than the "15m" string: jsonwebtoken's typings accept
        // a number unambiguously, and a duration that has already been parsed
        // cannot be mistyped in a config file and silently become 15 seconds.
        expiresIn: durationToSeconds(this.config.jwt.accessTtl, 15 * 60),
      },
    );

    const refreshToken = randomBytes(48).toString('base64url');
    await this.redis.set(
      this.refreshKey(userId, deviceId),
      this.hash(refreshToken),
      'EX',
      this.refreshTtlSeconds(),
    );

    return { accessToken, refreshToken };
  }

  /**
   * Rotates a refresh token, or returns null when it is unknown, expired, or
   * already used.
   *
   * "Already used" matters: rotation means a replayed token is evidence that
   * someone other than the device holds it. Returning null ends the session
   * rather than quietly issuing a second valid pair.
   */
  async rotate(
    userId: string,
    deviceId: string,
    presented: string,
  ): Promise<TokenPair | null> {
    const key = this.refreshKey(userId, deviceId);
    const stored = await this.redis.get(key);
    if (!stored) return null;
    if (stored !== this.hash(presented)) return null;

    // Delete before issuing, so two concurrent refreshes cannot both succeed.
    const removed = await this.redis.del(key);
    if (removed === 0) return null;

    return this.issue(userId, deviceId);
  }

  /** Revokes one device's session (`ACC-07`). */
  async revokeDevice(userId: string, deviceId: string): Promise<void> {
    await this.redis.del(this.refreshKey(userId, deviceId));
  }

  /** Revokes every device — used when an account is deactivated. */
  async revokeAll(userId: string): Promise<void> {
    const keys = await this.redis.keys(this.refreshKey(userId, '*'));
    if (keys.length > 0) await this.redis.del(...keys);
  }

  private refreshKey(userId: string, deviceId: string): string {
    return `auth:refresh:${userId}:${deviceId}`;
  }

  private hash(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  private refreshTtlSeconds(): number {
    return durationToSeconds(this.config.jwt.refreshTtl, 30 * 24 * 60 * 60);
  }
}

/**
 * Parses a `15m` / `30d` duration into seconds.
 *
 * Falls back to [fallbackSeconds] rather than throwing, but never to something
 * longer: a malformed TTL should shorten a session, not extend one.
 */
export function durationToSeconds(value: string, fallbackSeconds: number): number {
  const match = /^(\d+)([smhd])$/.exec(value.trim());
  if (!match) return fallbackSeconds;

  const amount = Number(match[1]);
  const multiplier = { s: 1, m: 60, h: 3600, d: 86400 }[match[2]] ?? 1;
  const seconds = amount * multiplier;
  return seconds > 0 ? seconds : fallbackSeconds;
}
