import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../authorization/ability.dart';
import '../authorization/raeed_role.dart';
import 'app_session.dart';
import 'token_store.dart';

part 'session_controller.g.dart';

/// Loads the signed-in user's profile and scope from a stored token.
///
/// Declared in `core` and implemented in the `auth` feature's data layer, for
/// the same reason as `AuthTokenRefresher`: the session is a cross-cutting
/// concern that the router, the API client and every screen read, so it cannot
/// depend on a feature — but restoring it needs an API call that belongs to
/// one. The narrow interface keeps the dependency pointing inward.
abstract interface class SessionBootstrapper {
  /// Fetches the current user for an existing access token.
  ///
  /// Returns null when the token is no longer valid.
  Future<SessionUser?> loadCurrentUser();

  /// Whether [user] has recorded the privacy-policy consent and an
  /// image-rights level for every child they guard (`ACC-06`).
  ///
  /// Resolved server-side from `consent_record`, never inferred on the client:
  /// consent is append-only and two guardians can disagree, and the
  /// most-restrictive-wins resolution lives in the backend's `children`
  /// service (`specs/03-domain-model/entities.md`).
  Future<bool> hasCompletedConsent(SessionUser user);
}

/// The token store. Overridden in tests with [InMemoryTokenStore].
@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => SecureTokenStore();

/// The session bootstrapper.
///
/// Overridden at app composition with the `auth` feature's implementation; the
/// default throws rather than silently returning "signed out", which would
/// look like a working app that can never sign anyone in.
@Riverpod(keepAlive: true)
SessionBootstrapper sessionBootstrapper(Ref ref) => throw UnimplementedError(
  'sessionBootstrapperProvider must be overridden at app composition with '
  'the auth feature implementation. See lib/app.dart.',
);

/// Holds the app's session and is the only thing allowed to change it.
///
/// Every screen, the router's guards, and the API client read session state
/// from here, so it is `keepAlive` — a session that could be garbage-collected
/// between screens would sign the user out on a navigation.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  AppSession build() {
    // Start unknown, never signed-out: the router must not redirect to /login
    // before secure storage has actually been read.
    unawaited(restore());
    return const AppSession.unknown();
  }

  /// Restores a session from secure storage on cold start.
  ///
  /// Any failure resolves to signed-out rather than propagating: an
  /// unreadable keystore or an unreachable server at launch should land the
  /// user on the login screen, not on a crash or an indefinite splash.
  Future<void> restore() async {
    try {
      final tokens = await ref.read(tokenStoreProvider).read();
      if (tokens == null) {
        state = const AppSession.signedOut();
        return;
      }

      final bootstrapper = ref.read(sessionBootstrapperProvider);
      final user = await bootstrapper.loadCurrentUser();
      if (user == null) {
        await ref.read(tokenStoreProvider).clear();
        state = const AppSession.signedOut();
        return;
      }

      await _activate(user);
    } on Object {
      state = const AppSession.signedOut();
    }
  }

  /// Called by the auth feature once tokens have been issued and stored.
  Future<void> onSignedIn(SessionUser user) => _activate(user);

  /// Records that consent has been captured, unlocking the rest of the app.
  void onConsentCompleted() {
    final current = state;
    if (current.status != SessionStatus.awaitingConsent) return;
    state = current.consented();
  }

  /// Switches which role's surface is presented.
  ///
  /// Narrows presentation only — abilities are always the union of every role
  /// the user actually holds.
  void switchRole(RaeedRole role) {
    final user = state.user;
    if (user == null || !user.roles.contains(role)) return;
    state = state.withActiveRole(role);
  }

  /// Ends the session and clears stored tokens.
  Future<void> signOut() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AppSession.signedOut();
  }

  /// Ends the session because the server rejected it — a revoked device
  /// (`ACC-07`), a deactivated account, or an unrecoverable 401.
  Future<void> onSessionExpired() => signOut();

  Future<void> _activate(SessionUser user) async {
    final consented = await ref
        .read(sessionBootstrapperProvider)
        .hasCompletedConsent(user);
    state = AppSession(
      status: consented ? SessionStatus.active : SessionStatus.awaitingConsent,
      user: user,
    );
  }
}

/// The current user's abilities.
///
/// Widgets read this rather than inspecting roles — `specs/05-authorization.md`
/// forbids `if (role == 'educator')` in the UI, and a provider makes the right
/// way also the convenient way.
@Riverpod(keepAlive: true)
Ability ability(Ref ref) => ref.watch(sessionControllerProvider).ability;
