import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { RoleName } from '../../modules/identity/entities/role-assignment.entity';
import { AuthenticatedUser } from './authenticated-user';

/**
 * Resolves a user id into the scope their abilities are built from.
 *
 * This is the single query path that decides what anyone can see, so it is
 * written as explicit SQL rather than through the ORM's relation loading: the
 * `unlinked_at is null` / `unassigned_at is null` / `valid_to is null`
 * predicates are the security boundary, and they should be visible in one
 * place rather than spread across three entity decorators.
 *
 * `specs/05-authorization.md`: scope is derived, never stored redundantly.
 */
@Injectable()
export class ScopeService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  /**
   * Builds the caller for this request, or null when the account no longer
   * exists or has been deactivated (`ACC-07`).
   */
  async resolve(userId: string): Promise<AuthenticatedUser | null> {
    const users: Array<{ id: string; is_active: boolean }> =
      await this.dataSource.query(
        'select id, is_active from app_user where id = $1',
        [userId],
      );
    const user = users[0];
    if (!user || !user.is_active) return null;

    const roleRows: Array<{ role: RoleName; branch_id: string | null }> =
      await this.dataSource.query(
        'select role, branch_id from role_assignment where user_id = $1',
        [userId],
      );

    const roles = new Set<RoleName>(roleRows.map((row) => row.role));

    // A user with no role assignment can do nothing. That is the correct
    // outcome for an account that exists but has not been given a part to
    // play yet — not an error, and not a default of "parent".
    const branchId =
      roleRows.find((row) => row.branch_id !== null)?.branch_id ?? null;

    const [childIds, groupIds] = await Promise.all([
      this.reachableChildIds(userId, roles),
      this.reachableGroupIds(userId, roles),
    ]);

    return new AuthenticatedUser(userId, roles, childIds, groupIds, branchId);
  }

  /**
   * Children this user may reach: their own as a guardian, plus everyone
   * currently in a group they lead.
   *
   * Oversight roles are deliberately *not* expanded into a list here. An
   * executive reaches every child, and materialising 200 ids on every request
   * to express that would be both slow and a lie — the ability rules give them
   * a scope-wide grant instead.
   */
  private async reachableChildIds(
    userId: string,
    roles: ReadonlySet<RoleName>,
  ): Promise<ReadonlySet<string>> {
    const ids = new Set<string>();

    if (roles.has('parent')) {
      const rows: Array<{ child_id: string }> = await this.dataSource.query(
        `select distinct pc.child_id
           from parent_child pc
           join child c on c.id = pc.child_id
          where pc.guardian_user_id = $1
            and pc.unlinked_at is null
            and c.deleted_at is null`,
        [userId],
      );
      for (const row of rows) ids.add(row.child_id);
    }

    if (roles.has('educator')) {
      const rows: Array<{ child_id: string }> = await this.dataSource.query(
        `select distinct cg.child_id
           from group_educator ge
           join child_group cg on cg.group_id = ge.group_id
           join child c on c.id = cg.child_id
          where ge.educator_user_id = $1
            and ge.unassigned_at is null
            and cg.valid_to is null
            and c.deleted_at is null`,
        [userId],
      );
      for (const row of rows) ids.add(row.child_id);
    }

    return ids;
  }

  private async reachableGroupIds(
    userId: string,
    roles: ReadonlySet<RoleName>,
  ): Promise<ReadonlySet<string>> {
    if (!roles.has('educator')) return new Set();

    const rows: Array<{ group_id: string }> = await this.dataSource.query(
      `select distinct ge.group_id
         from group_educator ge
         join "group" g on g.id = ge.group_id
        where ge.educator_user_id = $1
          and ge.unassigned_at is null
          and g.deleted_at is null`,
      [userId],
    );
    return new Set(rows.map((row) => row.group_id));
  }
}
