import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError } from '../../common/http/api-error';
import { LoginThrottle } from './login-throttle.service';
import { PasswordService } from './password.service';
import { TokenPair, TokenService } from './token.service';

/** The `/auth/me` payload. */
export interface CurrentUserView {
  id: string;
  display_name: string;
  preferred_locale: string;
  roles: string[];
  branch_id: string | null;
  reachable_child_ids: string[];
  reachable_group_ids: string[];
  /** The educator's availability window (`MSG-07`), null when none is set. */
  availability_hours: { start: string; end: string } | null;
}

/**
 * Sign-in, session lifecycle, and the current-user view.
 *
 * Registration is deliberately absent. `ACC-02` makes account creation an
 * Executive/Admin action; there is no public endpoint, and `login` behaves
 * identically for a number with no account, a deactivated account and a
 * wrong password, so that an unauthenticated caller cannot use it to discover
 * who is enrolled.
 */
@Injectable()
export class IdentityService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly passwords: PasswordService,
    private readonly throttle: LoginThrottle,
    private readonly tokens: TokenService,
  ) {}

  /**
   * Exchanges a phone number and password for a token pair.
   *
   * Every failure is `auth.invalid_credentials`: an unknown number, an
   * account with no password yet, a deactivated account and a wrong password
   * are indistinguishable from outside, and each one costs an attempt
   * against the throttle.
   */
  async login(
    phone: string,
    password: string,
    deviceId: string,
    clientIp: string,
  ): Promise<TokenPair> {
    await this.throttle.assertAllowed(phone, clientIp);

    const rows: Array<{ id: string; is_active: boolean; password_hash: string | null }> =
      await this.dataSource.query(
        'select id, is_active, password_hash from app_user where phone = $1',
        [phone],
      );
    const user = rows[0];
    // The hash runs whether or not the row exists, so the response time is
    // the same for a number with no account.
    const ok = await this.passwords.verify(password, user?.password_hash ?? null);
    if (!user || !user.is_active || !ok) {
      await this.throttle.recordFailure(phone, clientIp);
      throw ApiError.invalidCredentials();
    }

    await this.throttle.reset(phone);
    await this.registerDevice(user.id, deviceId);
    return this.tokens.issue(user.id, deviceId);
  }

  /**
   * Replaces the caller's own password after checking the current one.
   *
   * The current password is required even though the caller holds a valid
   * token: a phone left unlocked must not be enough to lock its owner out.
   */
  async changePassword(
    user: AuthenticatedUser,
    currentPassword: string,
    newPassword: string,
  ): Promise<void> {
    const rows: Array<{ password_hash: string | null }> = await this.dataSource.query(
      'select password_hash from app_user where id = $1',
      [user.id],
    );
    const ok = await this.passwords.verify(currentPassword, rows[0]?.password_hash ?? null);
    if (!ok) throw ApiError.invalidCredentials();
    await this.setPassword(this.dataSource.manager, user.id, newPassword);
  }

  /**
   * Stores a new password for [userId] — the provisioning path executives
   * use (`ACC-02`), and the change-password path above. Returns nothing: the
   * caller already holds the clear-text value it chose or generated.
   */
  async setPassword(
    tx: EntityManager | DataSource,
    userId: string,
    password: string,
  ): Promise<void> {
    const hash = await this.passwords.hash(password);
    await tx.query(
      `update app_user set password_hash = $2, password_set_at = now(), updated_at = now()
        where id = $1`,
      [userId, hash],
    );
  }

  /** Rotates a refresh token, ending the session if it is not current. */
  async refresh(
    refreshToken: string,
    deviceId: string,
  ): Promise<TokenPair> {
    // The refresh token does not identify its user on its own, so the device
    // row is the lookup — and a device revoked under ACC-07 has no live
    // session to rotate.
    const rows: Array<{ user_id: string }> = await this.dataSource.query(
      `select user_id from user_device
        where id = $1 and revoked_at is null`,
      [deviceId],
    );
    const device = rows[0];
    if (!device) throw new UnauthorizedException('Unknown or revoked device.');

    const pair = await this.tokens.rotate(device.user_id, deviceId, refreshToken);
    if (!pair) throw new UnauthorizedException('Refresh token is no longer valid.');
    return pair;
  }

  /** Revokes one device (`ACC-07`). */
  async revokeDevice(user: AuthenticatedUser, deviceId: string): Promise<void> {
    await this.dataSource.query(
      `update user_device set revoked_at = now()
        where id = $1 and user_id = $2 and revoked_at is null`,
      [deviceId, user.id],
    );
    await this.tokens.revokeDevice(user.id, deviceId);
  }

  /** The `/auth/me` view, built from live scope. */
  async currentUser(user: AuthenticatedUser): Promise<CurrentUserView> {
    const rows: Array<{ preferred_locale: string; display_name: string | null }> =
      await this.dataSource.query(
        'select preferred_locale, display_name from app_user where id = $1',
        [user.id],
      );
    const row = rows[0];
    const availability = await this.availabilityOf(user.id);

    return {
      id: user.id,
      // Empty until an executive enters the name — never the phone number,
      // which MSG-06 forbids returning to a non-executive role in any payload.
      display_name: row?.display_name ?? '',
      preferred_locale: row?.preferred_locale ?? 'ar',
      roles: [...user.roles],
      branch_id: user.branchId,
      reachable_child_ids: [...user.reachableChildIds],
      reachable_group_ids: [...user.reachableGroupIds],
      availability_hours: availability,
    };
  }

  /**
   * Sets the window in which a guardian's message reaches this educator
   * with a sound (`MSG-07`), on every group they currently lead.
   */
  async setAvailability(
    user: AuthenticatedUser,
    window: { start: string; end: string },
  ): Promise<{ start: string; end: string }> {
    await this.dataSource.query(
      `update group_educator set availability_hours_json = $2::jsonb
        where educator_user_id = $1 and unassigned_at is null`,
      [user.id, JSON.stringify(window)],
    );
    return window;
  }

  private async availabilityOf(userId: string): Promise<{ start: string; end: string } | null> {
    const rows: Array<{ availability_hours_json: { start?: unknown; end?: unknown } | null }> =
      await this.dataSource.query(
        `select availability_hours_json from group_educator
          where educator_user_id = $1 and unassigned_at is null
            and availability_hours_json is not null
          order by assigned_at desc limit 1`,
        [userId],
      );
    const json = rows[0]?.availability_hours_json;
    return json && typeof json.start === 'string' && typeof json.end === 'string'
      ? { start: json.start, end: json.end }
      : null;
  }

  /** Records the device so a refresh token has something to be scoped to. */
  private async registerDevice(userId: string, deviceId: string): Promise<void> {
    await this.dataSource.query(
      `insert into user_device (id, user_id, last_seen_at, created_at)
       values ($1, $2, now(), now())
       on conflict (id) do update
         set last_seen_at = now(),
             revoked_at = null`,
      [deviceId, userId],
    );
  }

  /** Refreshes the stored push token for a device. */
  async updateDevice(
    user: AuthenticatedUser,
    deviceId: string,
    pushToken: string | null,
    platform: string | null,
  ): Promise<void> {
    await this.dataSource.query(
      `insert into user_device (id, user_id, push_token, platform, last_seen_at, created_at)
       values ($1, $2, $3, $4, now(), now())
       on conflict (id) do update
         set push_token = excluded.push_token,
             platform = excluded.platform,
             last_seen_at = now()`,
      [deviceId, user.id, pushToken, platform],
    );
  }
}
