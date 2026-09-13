import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';

import { AppUser } from './app-user.entity';

/**
 * `user_device` — one row per install, carrying the push token and the
 * revocation flag behind `ACC-07`.
 *
 * Refresh tokens are device-scoped, so revoking a device is a row update here
 * rather than a global sign-out: a parent who loses a phone must be able to
 * kill that phone's session without ending the one on their tablet.
 */
@Entity({ name: 'user_device' })
export class UserDevice {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @ManyToOne(() => AppUser, (user) => user.devices)
  @JoinColumn({ name: 'user_id' })
  user: AppUser;

  /** FCM registration token. Delivery only — no other Firebase product. */
  @Column({ name: 'push_token', type: 'text', nullable: true })
  pushToken: string | null;

  @Column({ type: 'text', nullable: true })
  platform: 'ios' | 'android' | 'web' | null;

  @Column({ name: 'last_seen_at', type: 'timestamptz', nullable: true })
  lastSeenAt: Date | null;

  @Column({ name: 'revoked_at', type: 'timestamptz', nullable: true })
  revokedAt: Date | null;

  @Column({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}
