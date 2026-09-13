import { AbilityBuilder, createMongoAbility, MongoAbility } from '@casl/ability';

import { AuthenticatedUser } from './authenticated-user';

/**
 * The one place a permission question is answered
 * (`specs/05-authorization.md`).
 *
 * Every rule below is scoped by relationship, never by role alone. "Can an
 * educator read a child" has no answer without knowing *which* child and
 * whether that child sits in one of their groups — which is exactly the bug a
 * bare `if (role === 'educator')` produces, and why the spec forbids one.
 *
 * The mobile app carries a mirror of this in Dart
 * (`mobile/lib/core/authorization/ability.dart`), but only to decide which
 * affordances to render. This is the enforcement point. A client that skipped
 * its own checks gains nothing here.
 */
export type AbilityAction =
  | 'manage'
  | 'read'
  | 'create'
  | 'update'
  | 'delete'
  | 'answer'
  | 'markDone';

export type AbilitySubject =
  | 'Child'
  | 'ChildHealth'
  | 'AttendanceRecord'
  | 'PresenceConfirmation'
  | 'Session'
  | 'Material'
  | 'Homework'
  | 'Conversation'
  | 'Announcement'
  | 'MemoriesPost'
  | 'Group'
  | 'Season'
  | 'Category'
  | 'RoleAssignment'
  | 'Dashboard'
  | 'AuditLogEntry'
  | 'all';

export type AppAbility = MongoAbility<[AbilityAction, AbilitySubject | Record<string, unknown>]>;

/**
 * Builds the ability set for one request.
 *
 * Called once per request and cached on the request object — rebuilding it per
 * controller method would re-run the same scope queries several times for a
 * single call.
 */
export function defineAbilityFor(user: AuthenticatedUser): AppAbility {
  const { can, cannot, build } = new AbilityBuilder<AppAbility>(createMongoAbility);

  const childIds = [...user.reachableChildIds];
  const groupIds = [...user.reachableGroupIds];

  if (user.hasRole('parent')) {
    // A parent reaches exactly their own children. An empty list stays empty:
    // `$in: []` matches nothing, which is the correct answer for a guardian
    // whose last link was removed.
    can('read', 'Child', { id: { $in: childIds } });
    can('read', 'ChildHealth', { childId: { $in: childIds } });
    can('read', 'AttendanceRecord', { childId: { $in: childIds } });
    can('answer', 'PresenceConfirmation', { childId: { $in: childIds } });
    can('markDone', 'Homework', { childId: { $in: childIds } });
    can('read', 'Homework', { childId: { $in: childIds } });
    can('read', 'Session', { childId: { $in: childIds } });
    can('read', 'Material', { childId: { $in: childIds } });
    can('read', 'Announcement');
    can('read', 'MemoriesPost');

    // A parent may request a profile change; which tier it falls into —
    // instant, notify, or approval — is decided by the children service, not
    // here, because it is per-field rather than per-resource (`CHD-04`).
    can('create', 'Child', { id: { $in: childIds } });

    // No parent ever reads a staff channel. Stated as its own denial so the
    // rule is greppable and has a test of its own.
    cannot('read', 'Conversation', { type: 'staff' });
  }

  if (user.hasRole('educator')) {
    can('read', 'Child', { groupId: { $in: groupIds } });
    can('read', 'ChildHealth', { groupId: { $in: groupIds } });
    can('read', 'Group', { id: { $in: groupIds } });

    can(['read', 'create', 'update'], 'Session', { groupId: { $in: groupIds } });
    can(['read', 'create', 'update'], 'Material', { groupId: { $in: groupIds } });
    can(['read', 'create', 'update'], 'Homework', { groupId: { $in: groupIds } });
    can(['read', 'create', 'update'], 'AttendanceRecord', {
      groupId: { $in: groupIds },
    });
    can(['read', 'create', 'update'], 'PresenceConfirmation', {
      groupId: { $in: groupIds },
    });
    can(['read', 'create'], 'MemoriesPost', { groupId: { $in: groupIds } });

    // `ANN-03`: educators publish to their own groups only, never
    // association-wide.
    can(['read', 'create'], 'Announcement', { groupId: { $in: groupIds } });
    can('read', 'Announcement');

    can(['read', 'create'], 'Conversation', { groupId: { $in: groupIds } });

    // An educator may edit staff notes on a child and nothing else on the
    // profile. The field-level rule is enforced in the children service; what
    // the ability model says is that a general profile edit is not theirs.
    cannot('update', 'Child');
  }

  if (user.hasOversight) {
    // Branch-scoped if restricted, association-wide otherwise. Every read and
    // write is audit-logged server-side — the breadth of this grant is
    // precisely why that logging is not optional.
    const scope = user.branchId ? { branchId: user.branchId } : {};

    can('manage', 'Child', scope);
    can('manage', 'ChildHealth', scope);
    can('manage', 'AttendanceRecord', scope);
    can('manage', 'PresenceConfirmation', scope);
    can('manage', 'Session', scope);
    can('manage', 'Material', scope);
    can('manage', 'Homework', scope);
    can('manage', 'Announcement', scope);
    can('manage', 'MemoriesPost', scope);
    can('manage', 'Group', scope);
    can('read', 'Dashboard', scope);

    // `MSG-08`: oversight may read any conversation. It is logged, and
    // disclosed to the participants.
    can('read', 'Conversation', scope);
  }

  if (user.hasRole('admin')) {
    // Structure management is not branch-scoped: the spec's grant on
    // Season/Category/Group/RoleAssignment carries no branch condition.
    can('manage', 'Season');
    can('manage', 'Category');
    can('manage', 'Group');
    can('manage', 'RoleAssignment');
    can('read', 'AuditLogEntry');
  }

  return build({
    // Without this, CASL infers the subject type from the constructor name,
    // which for a plain resolved object is `Object` — and every check would
    // silently fail closed in a way that is maddening to debug.
    detectSubjectType: (subject) =>
      (subject as { __type: AbilitySubject }).__type,
  });
}

/**
 * Wraps a resolved resource so CASL can see both its type and the relationship
 * fields the rules test.
 *
 * The fields come from the database, never from the request
 * (`specs/04-api/conventions.md`): a client that could name its own `groupId`
 * would simply assert its way past every scope rule above.
 */
export function subject<T extends Record<string, unknown>>(
  type: AbilitySubject,
  resource: T,
): T & { __type: AbilitySubject } {
  return { ...resource, __type: type };
}
