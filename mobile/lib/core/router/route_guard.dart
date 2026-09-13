/// The app's routing guards, as pure functions.
///
/// `specs/06-mobile-app-spec.md` gives every route a guard. Those guards decide
/// whether a screen holding children's data is reachable, so they are written
/// as pure functions of session state and target location — no `BuildContext`,
/// no provider reads, no navigator side effects — and tested directly. A guard
/// that can only be exercised by driving the UI is a guard that will be tested
/// shallowly, if at all.
///
/// The client-side guard is a UX measure, not a security boundary: it keeps a
/// user out of a screen that would fail anyway. Every request the screen would
/// make is independently authorised server-side.
library;

import '../authorization/ability.dart';
import '../session/app_session.dart';
import 'app_routes.dart';

/// Routes reachable while signed out.
const Set<String> _publicRoutes = {AppRoutes.login, AppRoutes.otp};

/// Decides where a navigation to [location] should actually land.
///
/// Returns null to allow the navigation, or the path to redirect to.
///
/// The ordering matters and is deliberate:
///
/// 1. An unknown session never redirects — the app is still reading secure
///    storage, and bouncing to `/login` here is what makes a returning user
///    see the login screen flash on every cold start.
/// 2. Authentication, before anything else.
/// 3. Consent, before any screen that could show a child's data (`ACC-06`).
/// 4. Ability, last — by which point there is a user to ask about.
String? resolveRedirect({
  required AppSession session,
  required String location,
  bool hasPendingOtpRequest = false,
}) {
  final path = _normalise(location);

  // 1. Still resolving.
  if (session.status == SessionStatus.unknown) return null;

  // 2. Authentication.
  if (!session.isAuthenticated) {
    if (!_publicRoutes.contains(path)) return AppRoutes.login;
    // The OTP screen without a pending request has no phone number to verify
    // against, so it would be a dead end.
    if (path == AppRoutes.otp && !hasPendingOtpRequest) return AppRoutes.login;
    return null;
  }

  // A signed-in user has no business on the login screens.
  if (_publicRoutes.contains(path)) {
    return session.status == SessionStatus.awaitingConsent
        ? AppRoutes.consent
        : AppRoutes.home;
  }

  // 3. Consent gate.
  if (session.status == SessionStatus.awaitingConsent) {
    return path == AppRoutes.consent ? null : AppRoutes.consent;
  }
  if (path == AppRoutes.consent) return AppRoutes.home;

  // 4. Ability.
  return _abilityRedirect(session: session, path: path);
}

/// Redirects away from a route the user's abilities do not permit.
///
/// Only routes whose *entire purpose* is gated appear here — a composer, the
/// dashboard. Routes that render a specific resource (a child, a group, a
/// conversation) are not guarded by path, because the guard would have to
/// guess the resource's relationships before loading it. Those screens ask the
/// ability model once the resource is in hand, and render a
/// "not available to you" state otherwise — which is also what happens when
/// the server answers `scope.forbidden`.
String? _abilityRedirect({required AppSession session, required String path}) {
  final ability = session.ability;

  final requirement = switch (path) {
    AppRoutes.dashboard => (
      AbilityAction.read,
      const ResourceRef.type(AbilitySubject.dashboard),
    ),
    AppRoutes.memoriesCompose => (
      AbilityAction.create,
      const ResourceRef.type(AbilitySubject.memoriesPost),
    ),
    AppRoutes.announcementCompose => (
      AbilityAction.create,
      const ResourceRef.type(AbilitySubject.announcement),
    ),
    _ => null,
  };

  if (requirement == null) return null;
  return ability.can(requirement.$1, requirement.$2) ? null : AppRoutes.home;
}

/// Strips the query string and any trailing slash so guards compare paths, not
/// URLs — `/home?tab=1` and `/home/` are both `/home`.
String _normalise(String location) {
  final withoutQuery = location.split('?').first;
  if (withoutQuery.length > 1 && withoutQuery.endsWith('/')) {
    return withoutQuery.substring(0, withoutQuery.length - 1);
  }
  return withoutQuery;
}
