/// The client-side mirror of the CASL ability model in
/// `specs/05-authorization.md`.
///
/// ## What this is for, and what it is emphatically not for
///
/// This decides **which affordances to render** — whether the attendance
/// screen shows a submit button, whether the Memories composer is reachable,
/// whether a child card is tappable. It is a UI concern.
///
/// It is **not** an enforcement point. The backend resolves
/// `can(user, action, resource)` against the resource named in the URL, loaded
/// from the database, on every single mutating request
/// (`specs/04-api/conventions.md`). A client that skipped every check here
/// would gain no access it does not already have; a client that *passes* a
/// check here can still be refused with `scope.forbidden`, and the UI has to
/// handle that. Per `specs/README.md`, business logic is never duplicated
/// between mobile and backend — this mirrors the shape of the rules so the UI
/// can anticipate them, and the server remains the only authority.
///
/// The reason it exists at all, rather than the UI branching on roles inline:
/// `specs/05-authorization.md` forbids `if (role == 'educator')` scattered
/// through widgets. Scope in RAEED is never "what role" — it is always "what
/// role, against which child/group/branch relationship". A widget that checks
/// only the role gets that wrong the moment an educator opens a child outside
/// their own group.
library;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'raeed_role.dart';

/// Something a user might do to a resource.
///
/// Mirrors CASL's action vocabulary from `specs/05-authorization.md`.
enum AbilityAction {
  /// View the resource.
  read,

  /// Modify an existing resource.
  update,

  /// Bring a new resource into existence.
  create,

  /// Remove a resource.
  delete,

  /// Answer a presence confirmation (parent).
  answer,

  /// Mark homework done — self-reported by the guardian.
  markDone,

  /// Every action. Held by executives and admins within their scope.
  manage,
}

/// The kind of thing being acted on.
///
/// One value per subject named in the permission matrix of
/// `specs/05-authorization.md`.
enum AbilitySubject {
  /// A child's profile.
  child,

  /// A child's health information — gated more tightly than the profile, and
  /// every executive read of it is audit-logged (`AUD-03`).
  childHealth,

  /// An attendance record.
  attendanceRecord,

  /// A presence confirmation.
  presenceConfirmation,

  /// A session.
  session,

  /// Session materials.
  material,

  /// A homework assignment.
  homework,

  /// A messaging conversation.
  conversation,

  /// An announcement.
  announcement,

  /// A Memories Wall post.
  memoriesPost,

  /// A group.
  group,

  /// A season.
  season,

  /// A category (فئة).
  category,

  /// A role assignment.
  roleAssignment,

  /// The executive dashboard.
  dashboard,

  /// An audit log entry.
  auditLogEntry,
}

/// The type of a conversation, which changes who may read it.
///
/// Mirrors `conversation_type` in `specs/03-domain-model/schema.sql`. Note
/// there is deliberately no private educator–child channel: it is not a
/// representable state (`specs/10-security-and-privacy.md`).
enum ConversationKind {
  /// A thread about one child, between that child's guardians and staff.
  child,

  /// A staff channel for a group. Parents can never read these.
  staff,

  /// An executive channel.
  executive,
}

/// The resource an ability question is asked about.
///
/// Every check carries the relationship identifiers, never just a type —
/// because "can an educator read a child" has no answer without knowing
/// *which* child and whether it sits in one of their groups.
@immutable
class ResourceRef {
  const ResourceRef({
    required this.subject,
    this.childId,
    this.groupId,
    this.branchId,
    this.conversationKind,
    this.isConversationMember = false,
  }) : isTypeQuery = false;

  /// A reference to a subject type with no specific instance.
  ///
  /// Answers "could this user ever do this at all" — used to decide whether a
  /// nav entry or a compose button appears, before any particular resource is
  /// in hand.
  ///
  /// Scoped rules treat this as satisfied when the principal has *any*
  /// reachable child or group of the relevant kind. An educator assigned to at
  /// least one group can reach the announcement composer; the specific group
  /// they may publish to is then checked when they pick one. Answering "no"
  /// here because no group was named would hide the composer from every
  /// educator.
  const ResourceRef.type(this.subject)
    : childId = null,
      groupId = null,
      branchId = null,
      conversationKind = null,
      isConversationMember = false,
      isTypeQuery = true;

  /// What kind of thing this is.
  final AbilitySubject subject;

  /// Whether this asks about the subject type in general rather than one
  /// instance of it.
  final bool isTypeQuery;

  /// The child this resource belongs to, where it has one.
  final String? childId;

  /// The group this resource belongs to, where it has one.
  final String? groupId;

  /// The branch this resource belongs to, where it has one.
  final String? branchId;

  /// For [AbilitySubject.conversation], which kind of thread it is.
  final ConversationKind? conversationKind;

  /// For [AbilitySubject.conversation], whether the user is a participant.
  final bool isConversationMember;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceRef &&
          other.subject == subject &&
          other.childId == childId &&
          other.groupId == groupId &&
          other.branchId == branchId &&
          other.conversationKind == conversationKind &&
          other.isConversationMember == isConversationMember &&
          other.isTypeQuery == isTypeQuery;

  @override
  int get hashCode => Object.hash(
    subject,
    childId,
    groupId,
    branchId,
    conversationKind,
    isConversationMember,
    isTypeQuery,
  );
}

/// Who is asking, and what they can reach.
///
/// Scope is **derived, never stored redundantly**
/// (`specs/05-authorization.md`): the reachable sets come from the server's
/// live `parent_child` / `group_educator` / `child_group` rows, delivered with
/// the session, not from anything the client computes or caches indefinitely.
@immutable
class AbilityPrincipal {
  const AbilityPrincipal({
    required this.userId,
    required this.roles,
    this.reachableChildIds = const {},
    this.reachableGroupIds = const {},
    this.branchId,
  });

  /// A principal with no roles — the signed-out state. Can do nothing.
  const AbilityPrincipal.anonymous()
    : userId = '',
      roles = const {},
      reachableChildIds = const {},
      reachableGroupIds = const {},
      branchId = null;

  /// The authenticated user's id.
  final String userId;

  /// Every role this user holds. A user is frequently both parent and
  /// educator; abilities are the union of all their roles' grants.
  final Set<RaeedRole> roles;

  /// Children reachable as a guardian — `parent_child` rows where
  /// `unlinked_at is null`.
  final Set<String> reachableChildIds;

  /// Groups reachable as an educator — `group_educator` rows where
  /// `unassigned_at is null`.
  final Set<String> reachableGroupIds;

  /// Set when an executive or admin is restricted to a single branch
  /// (`role_assignment.branch_id`, `ACC-08`). Null means association-wide.
  final String? branchId;

  /// Whether this principal holds [role].
  bool hasRole(RaeedRole role) => roles.contains(role);

  /// Whether anyone is signed in.
  bool get isAuthenticated => roles.isNotEmpty;

  /// Whether this principal has association-wide oversight.
  bool get hasOversight => roles.any((role) => role.hasOversight);
}

/// Answers `can(action, resource)` for one principal.
///
/// Build it with [defineAbilityFor] rather than constructing it directly.
@immutable
class Ability {
  const Ability._(this._principal, this._rules);

  final AbilityPrincipal _principal;
  final List<_Rule> _rules;

  /// The principal these abilities were built for.
  AbilityPrincipal get principal => _principal;

  /// Whether [action] is permitted on [resource].
  ///
  /// Rules are evaluated in order; the last matching rule wins, so a `cannot`
  /// declared after a broad `can` correctly carves an exception out of it —
  /// the same precedence CASL uses, which keeps the Dart rules readable
  /// side-by-side with the TypeScript ones in `specs/05-authorization.md`.
  bool can(AbilityAction action, ResourceRef resource) {
    final matched = _rules.lastWhereOrNull(
      (rule) => rule.matches(action, resource, _principal),
    );
    return matched?.allowed ?? false;
  }

  /// The negation of [can], for readability at call sites that guard.
  bool cannot(AbilityAction action, ResourceRef resource) =>
      !can(action, resource);
}

/// One grant or denial.
@immutable
class _Rule {
  const _Rule({
    required this.allowed,
    required this.actions,
    required this.subjects,
    this.condition,
  });

  final bool allowed;
  final Set<AbilityAction> actions;
  final Set<AbilitySubject> subjects;
  final bool Function(ResourceRef resource, AbilityPrincipal principal)?
  condition;

  bool matches(
    AbilityAction action,
    ResourceRef resource,
    AbilityPrincipal principal,
  ) {
    if (!subjects.contains(resource.subject)) return false;
    // `manage` grants every action, matching CASL's semantics.
    if (!actions.contains(action) && !actions.contains(AbilityAction.manage)) {
      return false;
    }
    return condition?.call(resource, principal) ?? true;
  }
}

/// Collects rules while an ability is being defined.
class _AbilityBuilder {
  final List<_Rule> rules = [];

  void can(
    List<AbilityAction> actions,
    List<AbilitySubject> subjects, {
    bool Function(ResourceRef resource, AbilityPrincipal principal)? when,
  }) => rules.add(
    _Rule(
      allowed: true,
      actions: actions.toSet(),
      subjects: subjects.toSet(),
      condition: when,
    ),
  );

  void cannot(
    List<AbilityAction> actions,
    List<AbilitySubject> subjects, {
    bool Function(ResourceRef resource, AbilityPrincipal principal)? when,
  }) => rules.add(
    _Rule(
      allowed: false,
      actions: actions.toSet(),
      subjects: subjects.toSet(),
      condition: when,
    ),
  );
}

/// Builds the ability set for [principal].
///
/// Deliberately structured as one function per the spec's shape, so the Dart
/// rules can be diffed against the TypeScript in `specs/05-authorization.md`
/// when either side changes. A rule added on one side and not the other shows
/// up as the UI offering an action the server then refuses — which the
/// allow/deny tests in `test/core/authorization/` are there to catch.
Ability defineAbilityFor(AbilityPrincipal principal) {
  final builder = _AbilityBuilder();

  if (principal.hasRole(RaeedRole.parent)) {
    _defineParentAbilities(builder);
  }
  if (principal.hasRole(RaeedRole.educator)) {
    _defineEducatorAbilities(builder);
  }
  if (principal.hasOversight) {
    _defineOversightAbilities(builder);
  }
  if (principal.hasRole(RaeedRole.admin)) {
    _defineAdminAbilities(builder);
  }

  return Ability._(principal, builder.rules);
}

/// A parent reaches exactly their own children, and nothing else.
void _defineParentAbilities(_AbilityBuilder builder) {
  bool ownChild(ResourceRef resource, AbilityPrincipal principal) =>
      resource.isTypeQuery
      ? principal.reachableChildIds.isNotEmpty
      : resource.childId != null &&
            principal.reachableChildIds.contains(resource.childId);

  builder
    ..can(
      [AbilityAction.read],
      [
        AbilitySubject.child,
        AbilitySubject.childHealth,
        AbilitySubject.attendanceRecord,
        AbilitySubject.homework,
        AbilitySubject.session,
        AbilitySubject.material,
      ],
      when: ownChild,
    )
    ..can(
      [AbilityAction.answer],
      [AbilitySubject.presenceConfirmation],
      when: ownChild,
    )
    ..can([AbilityAction.markDone], [AbilitySubject.homework], when: ownChild)
    // CHD-04's request-with-approval tier: a parent may *ask* for a profile
    // change. The tiering itself (instant / notify / approval) is a server
    // rule — the app does not decide which tier a field falls into.
    ..can([AbilityAction.create], [AbilitySubject.child], when: ownChild)
    ..can([AbilityAction.read], [AbilitySubject.announcement])
    ..can([AbilityAction.read], [AbilitySubject.memoriesPost])
    ..can(
      [AbilityAction.read, AbilityAction.create],
      [AbilitySubject.conversation],
      when: (resource, principal) =>
          resource.conversationKind != ConversationKind.staff &&
          resource.conversationKind != ConversationKind.executive &&
          (resource.isConversationMember || ownChild(resource, principal)),
    )
    // Explicit, though the grant above already excludes it: parents never see
    // a staff channel. Stated as its own denial so the rule is greppable and
    // has a test of its own.
    ..cannot(
      [AbilityAction.read],
      [AbilitySubject.conversation],
      when: (resource, _) =>
          resource.conversationKind == ConversationKind.staff,
    );
}

/// An educator reaches the children currently in their own groups.
void _defineEducatorAbilities(_AbilityBuilder builder) {
  bool ownGroup(ResourceRef resource, AbilityPrincipal principal) =>
      resource.isTypeQuery
      ? principal.reachableGroupIds.isNotEmpty
      : resource.groupId != null &&
            principal.reachableGroupIds.contains(resource.groupId);

  builder
    ..can(
      [AbilityAction.read],
      [AbilitySubject.child, AbilitySubject.childHealth, AbilitySubject.group],
      when: ownGroup,
    )
    ..can(
      [AbilityAction.read, AbilityAction.create, AbilityAction.update],
      [
        AbilitySubject.session,
        AbilitySubject.material,
        AbilitySubject.homework,
        AbilitySubject.attendanceRecord,
        AbilitySubject.presenceConfirmation,
        AbilitySubject.memoriesPost,
      ],
      when: ownGroup,
    )
    // ANN-03: educators publish to their own groups only, never association-wide.
    ..can(
      [AbilityAction.read, AbilityAction.create],
      [AbilitySubject.announcement],
      when: ownGroup,
    )
    ..can([AbilityAction.read], [AbilitySubject.announcement])
    ..can(
      [AbilityAction.read, AbilityAction.create],
      [AbilitySubject.conversation],
      when: (resource, principal) =>
          ownGroup(resource, principal) || resource.isConversationMember,
    )
    // CHD: an educator may edit staff notes on a child, and nothing else on
    // the profile. The field-level rule lives server-side; the app only knows
    // that a general profile edit is not theirs to offer.
    ..cannot([AbilityAction.update], [AbilitySubject.child]);
}

/// Executives and admins see everything, optionally narrowed to one branch.
///
/// Every read and write they make is audit-logged server-side — the breadth of
/// this grant is exactly why that logging is not optional.
void _defineOversightAbilities(_AbilityBuilder builder) {
  bool inBranchScope(ResourceRef resource, AbilityPrincipal principal) =>
      principal.branchId == null ||
      resource.branchId == null ||
      resource.branchId == principal.branchId;

  builder
    ..can(
      [AbilityAction.manage],
      [
        AbilitySubject.child,
        AbilitySubject.childHealth,
        AbilitySubject.attendanceRecord,
        AbilitySubject.presenceConfirmation,
        AbilitySubject.session,
        AbilitySubject.material,
        AbilitySubject.homework,
        AbilitySubject.announcement,
        AbilitySubject.memoriesPost,
        AbilitySubject.group,
        AbilitySubject.dashboard,
      ],
      when: inBranchScope,
    )
    // MSG-08: oversight reading of any conversation is permitted, logged, and
    // disclosed to the participants.
    ..can(
      [AbilityAction.read],
      [AbilitySubject.conversation],
      when: inBranchScope,
    );
}

/// Admin adds structure and user management, plus the audit log.
void _defineAdminAbilities(_AbilityBuilder builder) {
  builder
    ..can(
      [AbilityAction.manage],
      [
        AbilitySubject.season,
        AbilitySubject.category,
        AbilitySubject.group,
        AbilitySubject.roleAssignment,
      ],
    )
    ..can([AbilityAction.read], [AbilitySubject.auditLogEntry]);
}
