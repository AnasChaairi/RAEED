/// What the role-scoped home is a home *for*.
///
/// `specs/06-mobile-app-spec.md` routes every role to the same `/home`, and
/// `specs/05-authorization.md` forbids `if (role == 'educator')` in a widget.
/// So the screen asks this instead: it resolves the scope by putting questions
/// to the ability model and reading the answers, never by reading a role name.
///
/// The distinction matters beyond tidiness. A user is frequently both parent
/// and educator, and "which role is this person" has no single answer for them
/// — but "can this principal reach a group" does.
library;

import '../../../core/authorization/ability.dart';

/// Whose children this home is showing.
enum HomeScope {
  /// A guardian's own children (`parent_child`).
  ownChildren,

  /// The children in the groups this user leads (`group_educator`).
  groupChildren,

  /// Association-wide oversight, optionally narrowed to one branch.
  allChildren,

  /// Nothing is reachable — signed in, but with no children, no groups and no
  /// oversight. Renders the "contact the association" state, because
  /// post-onboarding this signals a data problem, not an empty inbox.
  none,
}

/// Resolves which home to show for [ability].
///
/// Ordered widest-first so a user holding several roles lands on the surface
/// with the most reach, matching `AppSession.effectiveRole`'s reasoning: an
/// executive who is also a parent opened the app for the oversight view.
///
/// Each branch asks a question only one grant in `specs/05-authorization.md`
/// can answer yes to:
///
/// * `manage` on the dashboard is granted to oversight roles alone;
/// * `read` on a group (as a type query, i.e. "any group at all") is granted
///   to an educator with at least one live `group_educator` row;
/// * `read` on a child is granted to a guardian with at least one live
///   `parent_child` row.
HomeScope resolveHomeScope(Ability ability) {
  if (ability.can(
    AbilityAction.manage,
    const ResourceRef.type(AbilitySubject.dashboard),
  )) {
    return HomeScope.allChildren;
  }
  if (ability.can(
    AbilityAction.read,
    const ResourceRef.type(AbilitySubject.group),
  )) {
    return HomeScope.groupChildren;
  }
  if (ability.can(
    AbilityAction.read,
    const ResourceRef.type(AbilitySubject.child),
  )) {
    return HomeScope.ownChildren;
  }
  return HomeScope.none;
}
