import { Injectable } from '@nestjs/common';
import { randomBytes, randomInt, scrypt, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

const scryptAsync = promisify(scrypt) as (
  password: string,
  salt: Buffer,
  keylen: number,
  options: { N: number; r: number; p: number },
) => Promise<Buffer>;

/**
 * Passwords (`specs/10-security-and-privacy.md`).
 *
 * A password is exactly six characters, letters and digits — short enough
 * for an executive to hand over by phone or in person to a guardian, which
 * is how accounts are provisioned (`ACC-02`). What keeps six characters
 * workable is the rest of the login path: a slow hash here, and
 * `LoginThrottle` limiting failed attempts per number and per address.
 *
 * Hashing is scrypt from `node:crypto`, so no dependency carries the
 * credential of every family in the association. The stored form carries
 * its parameters, so they can be raised later without re-hashing everyone
 * on the same day.
 */
@Injectable()
export class PasswordService {
  /** The one shape a password may have. */
  static readonly LENGTH = 6;
  static readonly PATTERN = /^[A-Za-z0-9]{6}$/;

  /**
   * Letters and digits that cannot be misread when written on a slip of
   * paper or read out: no 0/O, 1/l/I, and lower case only.
   */
  private static readonly HANDOVER_ALPHABET = 'abcdefghjkmnpqrstuvwxyz23456789';

  private static readonly SCRYPT = { N: 16384, r: 8, p: 1 };
  private static readonly KEY_LENGTH = 32;
  private static readonly SALT_LENGTH = 16;

  /** Whether [password] has the shape the policy allows. */
  isWellFormed(password: string): boolean {
    return PasswordService.PATTERN.test(password);
  }

  /** A fresh password for an account an executive is provisioning. */
  generate(): string {
    const alphabet = PasswordService.HANDOVER_ALPHABET;
    let out = '';
    for (let index = 0; index < PasswordService.LENGTH; index += 1) {
      // randomInt is CSPRNG-backed; Math.random would make a handed-over
      // password guessable from the time it was issued.
      out += alphabet[randomInt(0, alphabet.length)];
    }
    return out;
  }

  /** The stored form: `scrypt$N$r$p$<salt>$<key>`, base64url. */
  async hash(password: string): Promise<string> {
    const salt = randomBytes(PasswordService.SALT_LENGTH);
    const { N, r, p } = PasswordService.SCRYPT;
    const key = await scryptAsync(password, salt, PasswordService.KEY_LENGTH, { N, r, p });
    return ['scrypt', N, r, p, salt.toString('base64url'), key.toString('base64url')].join('$');
  }

  /**
   * Constant-time check of [password] against [stored].
   *
   * A null or malformed stored value (an account that has never been given a
   * password) still runs a hash so the response time does not reveal whether
   * the number has an account (`ACC-02`).
   */
  async verify(password: string, stored: string | null): Promise<boolean> {
    const parsed = PasswordService.parse(stored);
    const salt = parsed?.salt ?? Buffer.alloc(PasswordService.SALT_LENGTH);
    const params = parsed?.params ?? PasswordService.SCRYPT;
    const key = await scryptAsync(password, salt, PasswordService.KEY_LENGTH, params);
    if (!parsed) return false;
    return key.length === parsed.key.length && timingSafeEqual(key, parsed.key);
  }

  private static parse(
    stored: string | null,
  ): { params: { N: number; r: number; p: number }; salt: Buffer; key: Buffer } | null {
    if (!stored) return null;
    const [scheme, n, r, p, salt, key] = stored.split('$');
    if (scheme !== 'scrypt' || !salt || !key) return null;
    const params = { N: Number(n), r: Number(r), p: Number(p) };
    if (![params.N, params.r, params.p].every((value) => Number.isInteger(value) && value > 0)) {
      return null;
    }
    return { params, salt: Buffer.from(salt, 'base64url'), key: Buffer.from(key, 'base64url') };
  }
}
