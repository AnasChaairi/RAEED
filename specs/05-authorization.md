# Authorization (RBAC / Ability Model)

Every permission question in RAEED is "what role, scoped to which child/group/branch relationship" — never just "what role". This is implemented once, centrally, with an ability library ([CASL](https://casl.js.org/) on the NestJS backend) — never as `if (user.role === 'educator')` scattered through controllers or Flutter widgets.

## Model

- A `role_assignment` row is `{ role: parent | educator | executive | admin, branch_id? }`. Scope is otherwise **derived, never stored redundantly**:
  - A parent's reachable children = `parent_child` rows where `unlinked_at is null`.
  - An educator's reachable groups = `group_educator` rows where `unassigned_at is null`; reachable children = children currently in those groups (`child_group`).
  - An executive/admin's reach is everything, optionally filtered to one `branch_id` if `role_assignment.branch_id` is set.
- Every check is `can(user, action, resource)`, where `resource` always carries its own `child_id` / `group_id` / `branch_id` — resolved from the database, never taken from the request.
- Two executive levels are two different ability sets built from the same primitives, not two hardcoded code branches: `admin` additionally gets `manage` on `Season`/`Category`/`Group`/`RoleAssignment` and `read` on `AuditLogEntry`.

## Shape (NestJS + CASL)

```ts
// abilities/define-ability.ts — one function, called once per request, cached per user
export function defineAbilityFor(user: AuthenticatedUser): AppAbility {
  const { can, cannot, build } = new AbilityBuilder<AppAbility>(createMongoAbility);

  if (user.hasRole('parent')) {
    can('read', 'Child', { id: { $in: user.reachableChildIds } });
    can('read', 'AttendanceRecord', { childId: { $in: user.reachableChildIds } });
    can('answer', 'PresenceConfirmation', { childId: { $in: user.reachableChildIds } });
    can('markDone', 'Homework', { childId: { $in: user.reachableChildIds } });
    cannot('read', 'Conversation', { type: 'staff' });
  }

  if (user.hasRole('educator')) {
    can('read', 'Child', { groupId: { $in: user.reachableGroupIds } });
    can('update', 'AttendanceRecord', { groupId: { $in: user.reachableGroupIds } });
    can('create', 'Session', { groupId: { $in: user.reachableGroupIds } });
    can('create', 'Announcement', { groupId: { $in: user.reachableGroupIds } });
    cannot('update', 'Child', { field: { $ne: 'staffNotes' } }); // staff notes only, CHD
  }

  if (user.hasRole('executive') || user.hasRole('admin')) {
    const scope = user.branchId ? { branchId: user.branchId } : {};
    can('manage', 'all', scope);          // oversight — every read/write is still audit-logged
    can('read', 'Conversation', scope);   // logged + disclosed per MSG-08
  }

  if (user.hasRole('admin')) {
    can('manage', ['Season', 'Category', 'Group', 'RoleAssignment']);
    can('read', 'AuditLogEntry');
  }

  return build();
}
```

A guard (`@CheckAbility('update', 'AttendanceRecord')`) resolves the target resource from the path, loads it, and calls `ability.can(action, resource)` before the controller method runs — every module in `07-backend-spec.md` uses the same guard, none re-implements the check.

## Permission matrix (mirrors the product scope's §6 one-for-one)

| Action | Parent | Educator | Executive | Admin |
|---|---|---|---|---|
| View child profile | Own children | Own groups' children | All (branch-scoped if restricted) | All |
| Edit child profile | Request only | Staff notes only | Approve requests, edit | Edit |
| View health info | Own children | Own groups | All — every view logged (`AUD-03`) | All — logged |
| Manage seasons/categories/groups/users | — | — | — | Yes |
| Plan sessions, mark attendance, assign homework | — | Own groups | All groups, corrections logged | All groups |
| Read any conversation | — | — | Yes — logged, disclosed to users | Yes — logged |
| Publish to any audience | — | Own groups | Any audience | Any audience |
| Export data / read audit logs | — | — | Export (logged) | Export + logs |

## Field-tier rule for child profile edits (`CHD-04`)

Not expressed in the ability model above (it's per-field, not per-resource) — enforced in the `children` service's `requestChange` use case:

| Tier | Fields | Behavior |
|---|---|---|
| Self-edit-instant | `school_level`, dietary preference note | Applied immediately, no `profile_change_request` row |
| Request-with-notify | Name spelling, photo | `profile_change_request` created and auto-approved; executive gets a notification, not a queue item |
| Request-with-approval | `health_json.*`, guardian linking | `profile_change_request` stays `pending` until an executive approves |
