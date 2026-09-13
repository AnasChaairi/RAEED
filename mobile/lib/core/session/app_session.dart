import 'package:meta/meta.dart';

import '../authorization/ability.dart';
import '../authorization/raeed_role.dart';

/// Where the user stands with respect to signing in and consenting.
///
/// The router's redirect logic is a pure function of this — see
/// `lib/core/router/app_router.dart`. Modelling it as a closed set rather than
/// a pile of booleans means "authenticated but not consented" cannot be
/// confused with "not authenticated", which is the bug that would let someone
/// past `/consent` and into children's data before agreeing to anything.
enum SessionStatus {
  /// Tokens have not been read from secure storage yet. The app shows a splash
  /// and makes no routing decision — redirecting on an unknown session is how
  /// a returning user gets bounced to `/login` on every cold start.
  unknown,

  /// No valid session. Only `/login` and `/login/otp` are reachable.
  signedOut,

  /// Signed in, but the privacy policy and per-child image-rights levels are
  /// not yet recorded. Only `/consent` is reachable (`ACC-06`).
  awaitingConsent,

  /// Signed in and consented. The app is fully reachable, subject to the
  /// ability model.
  active,
}

/// The signed-in user, as far as the app needs to know them.
///
/// Contains no phone number: `MSG-06` forbids rendering `app_user.phone` to a
/// non-executive role in any payload, and the surest way to honour that on the
/// client is not to hold it in session state at all. The login screen has the
/// number the user just typed; nothing after that needs it.
@immutable
class SessionUser {
  const SessionUser({
    required this.id,
    required this.roles,
    required this.displayName,
    this.preferredLocale = 'ar',
    this.reachableChildIds = const {},
    this.reachableGroupIds = const {},
    this.branchId,
  });

  /// `app_user.id`.
  final String id;

  /// Every role held. A user is often both parent and educator.
  final Set<RaeedRole> roles;

  /// The name to greet them by.
  final String displayName;

  /// `app_user.preferred_locale` — `ar`, `fr` or `en`.
  final String preferredLocale;

  /// Children reachable as a guardian, resolved server-side from live
  /// `parent_child` rows.
  final Set<String> reachableChildIds;

  /// Groups reachable as an educator, resolved server-side from live
  /// `group_educator` rows.
  final Set<String> reachableGroupIds;

  /// Set when an executive or admin is restricted to one branch.
  final String? branchId;

  /// This user as an ability principal.
  AbilityPrincipal get principal => AbilityPrincipal(
    userId: id,
    roles: roles,
    reachableChildIds: reachableChildIds,
    reachableGroupIds: reachableGroupIds,
    branchId: branchId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUser &&
          other.id == id &&
          other.displayName == displayName &&
          other.preferredLocale == preferredLocale &&
          other.branchId == branchId &&
          _setEquals(other.roles, roles) &&
          _setEquals(other.reachableChildIds, reachableChildIds) &&
          _setEquals(other.reachableGroupIds, reachableGroupIds);

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    preferredLocale,
    branchId,
    Object.hashAllUnordered(roles),
    Object.hashAllUnordered(reachableChildIds),
    Object.hashAllUnordered(reachableGroupIds),
  );
}

/// The whole of the app's session state.
@immutable
class AppSession {
  const AppSession({required this.status, this.user, this.activeRole});

  /// The state before secure storage has been read.
  const AppSession.unknown()
    : status = SessionStatus.unknown,
      user = null,
      activeRole = null;

  /// The signed-out state.
  const AppSession.signedOut()
    : status = SessionStatus.signedOut,
      user = null,
      activeRole = null;

  /// Where the user stands.
  final SessionStatus status;

  /// The signed-in user, or null when signed out.
  final SessionUser? user;

  /// Which of the user's roles the UI is currently presenting.
  ///
  /// A user holding several roles sees one surface at a time — a parent home
  /// or an educator home, not a merged one. Switching is explicit
  /// (`roleSwitchTitle`), because a screen that silently blends both is how an
  /// educator ends up looking at their own child's record in a staff context.
  ///
  /// Note this narrows *presentation* only: it never widens permissions, and
  /// the ability model is always built from the full [SessionUser.roles] set.
  final RaeedRole? activeRole;

  /// Whether a user is signed in, regardless of consent.
  bool get isAuthenticated =>
      status == SessionStatus.awaitingConsent || status == SessionStatus.active;

  /// Whether the app is fully usable.
  bool get isActive => status == SessionStatus.active;

  /// The ability set for the current user, or an anonymous one when signed out.
  Ability get ability =>
      defineAbilityFor(user?.principal ?? const AbilityPrincipal.anonymous());

  /// The role whose surface should be shown: the explicit choice if there is
  /// one, else the most privileged role held.
  ///
  /// Falling back to the most privileged role means an executive who is also a
  /// parent lands on the dashboard by default, which is the surface they opened
  /// the app for.
  RaeedRole? get effectiveRole {
    if (activeRole != null && (user?.roles.contains(activeRole) ?? false)) {
      return activeRole;
    }
    final roles = user?.roles;
    if (roles == null || roles.isEmpty) return null;
    for (final candidate in const [
      RaeedRole.admin,
      RaeedRole.executive,
      RaeedRole.educator,
      RaeedRole.parent,
    ]) {
      if (roles.contains(candidate)) return candidate;
    }
    return roles.first;
  }

  /// Returns a copy with the presented role changed.
  AppSession withActiveRole(RaeedRole role) =>
      AppSession(status: status, user: user, activeRole: role);

  /// Returns a copy with consent recorded, unlocking the rest of the app.
  AppSession consented() => AppSession(
    status: SessionStatus.active,
    user: user,
    activeRole: activeRole,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSession &&
          other.status == status &&
          other.user == user &&
          other.activeRole == activeRole;

  @override
  int get hashCode => Object.hash(status, user, activeRole);
}

bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
