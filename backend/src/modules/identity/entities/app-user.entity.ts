import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';

import { RoleAssignment } from './role-assignment.entity';
import { UserDevice } from './user-device.entity';

/**
 * `app_user` — the only table holding identifying contact information.
 *
 * That concentration is deliberate (`specs/03-domain-model/schema.sql`):
 * `MSG-06` forbids rendering a phone number to a non-executive role in any
 * payload, and having exactly one column to guard is what makes that rule
 * enforceable rather than aspirational. Nothing outside this module returns
 * `phone` or `email`, and the serialisers that could are tested for it.
 */
@Entity({ name: 'app_user' })
export class AppUser {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /** E.164, e.g. `+2126XXXXXXXX`. */
  @Column({ type: 'text', nullable: true, unique: true })
  phone: string | null;

  @Column({ type: 'text', nullable: true, unique: true })
  email: string | null;

  @Column({ name: 'preferred_locale', type: 'text', default: 'ar' })
  preferredLocale: 'ar' | 'fr' | 'en';

  /** `ACC-07`: flips to false on deactivation, which revokes every device. */
  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @Column({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  @OneToMany(() => RoleAssignment, (assignment) => assignment.user)
  roleAssignments: RoleAssignment[];

  @OneToMany(() => UserDevice, (device) => device.user)
  devices: UserDevice[];
}
