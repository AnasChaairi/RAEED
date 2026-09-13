import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';

import { AppUser } from './app-user.entity';

export type RoleName = 'parent' | 'educator' | 'executive' | 'admin';

/**
 * `role_assignment` — a role, optionally narrowed to one branch (`ACC-08`).
 *
 * This row is the *only* thing scope is stored as. Everything else an ability
 * check needs — which children, which groups — is derived at request time from
 * `parent_child` / `group_educator` (`specs/05-authorization.md`, "derived,
 * never stored redundantly"). A cached copy of someone's reachable children
 * would go stale the moment a guardian is unlinked, and it would go stale
 * silently.
 */
@Entity({ name: 'role_assignment' })
export class RoleAssignment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @ManyToOne(() => AppUser, (user) => user.roleAssignments)
  @JoinColumn({ name: 'user_id' })
  user: AppUser;

  @Column({ type: 'text' })
  role: RoleName;

  @Column({ name: 'branch_id', type: 'uuid', nullable: true })
  branchId: string | null;

  @Column({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}
