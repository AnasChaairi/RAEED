import { RoleName } from '../../modules/identity/entities/role-assignment.entity';

/**
 * The caller, with the scope their abilities are built from.
 *
 * Every set here is **derived at request time** from live join-table rows, per
 * `specs/05-authorization.md`: a parent's reachable children are `parent_child`
 * rows with `unlinked_at is null`; an educator's reachable groups are
 * `group_educator` rows with `unassigned_at is null`, and their reachable
 * children are whoever is currently in those groups.
 *
 * Nothing here is taken from the request. The JWT carries a user id and nothing
 * else that matters — a token claiming `role: admin` would be ignored, because
 * roles are loaded from `role_assignment` on every request. That is the
 * difference between a token being a *reference* to an identity and a token
 * being an *assertion* about one.
 */
export class AuthenticatedUser {
  constructor(
    readonly id: string,
    readonly roles: ReadonlySet<RoleName>,
    readonly reachableChildIds: ReadonlySet<string>,
    readonly reachableGroupIds: ReadonlySet<string>,
    /** Set when an executive/admin is restricted to one branch (`ACC-08`). */
    readonly branchId: string | null,
  ) {}

  hasRole(role: RoleName): boolean {
    return this.roles.has(role);
  }

  get hasOversight(): boolean {
    return this.hasRole('executive') || this.hasRole('admin');
  }

  /** Whether this user guards [childId] right now. */
  guards(childId: string): boolean {
    return this.reachableChildIds.has(childId);
  }

  /** Whether this user currently leads [groupId]. */
  leads(groupId: string): boolean {
    return this.reachableGroupIds.has(groupId);
  }
}
