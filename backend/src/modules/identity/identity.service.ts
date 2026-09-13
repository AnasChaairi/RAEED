import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError } from '../../common/http/api-error';
import { OtpService } from './otp.service';
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
}

/**
 * Sign-in, session lifecycle, and the current-user view.
 *
 * Registration is deliberately absent. `ACC-02` makes account creation an
 * Executive/Admin action; there is no public endpoint, and `requestOtp`
 * behaves identically for a number with no account so that an unauthenticated
 * caller cannot use it to discover who is enrolled.
 */
@Injectable()
export class IdentityService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly otp: OtpService,
    private readonly tokens: TokenService,
  ) {}

  /** Sends a code, whether or not the number has an account. */
  async requestOtp(phone: string, clientIp: string): Promise<void> {
    await this.otp.request(phone, clientIp);
  }

  /**
   * Exchanges a verified code for a token pair.
   *
   * The account lookup happens *after* code verification, so a wrong code and
   * an unknown number are indistinguishable from outside — both are
   * `auth.otp_invalid`.
   */
  async verifyOtp(
    phone: string,
    code: string,
    deviceId: string,
  ): Promise<TokenPair> {
    const ok = await this.otp.verify(phone, code);
    if (!ok) throw ApiError.otpInvalid();

    const rows: Array<{ id: string; is_active: boolean }> =
      await this.dataSource.query(
        'select id, is_active from app_user where phone = $1',
        [phone],
      );
    const user = rows[0];
    if (!user || !user.is_active) throw ApiError.otpInvalid();

    await this.registerDevice(user.id, deviceId);
    return this.tokens.issue(user.id, deviceId);
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
    const rows: Array<{ preferred_locale: string; phone: string | null }> =
      await this.dataSource.query(
        'select preferred_locale, phone from app_user where id = $1',
        [user.id],
      );
    const row = rows[0];

    return {
      id: user.id,
      // `app_user` has no display name column, so the guardian's name comes
      // from elsewhere in a later ticket. Until then a neutral placeholder,
      // never the phone number — MSG-06 forbids returning that to a
      // non-executive role in any payload, and "show the phone as a name" is
      // exactly how that rule gets broken by accident.
      display_name: '',
      preferred_locale: row?.preferred_locale ?? 'ar',
      roles: [...user.roles],
      branch_id: user.branchId,
      reachable_child_ids: [...user.reachableChildIds],
      reachable_group_ids: [...user.reachableGroupIds],
    };
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
