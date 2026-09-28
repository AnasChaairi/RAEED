import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client_provider.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/session/session_controller.dart';
import '../application/capture_consent.dart';
import '../application/change_password.dart';
import '../application/refresh_tokens.dart';
import '../application/sign_in.dart';
import '../application/sign_out.dart';
import '../data/auth_repository_impl.dart';
import '../data/auth_session_bootstrapper.dart';
import '../data/consent_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/consent.dart';
import '../domain/consent_repository.dart';

part 'auth_providers.g.dart';

/// Rotates refresh tokens, for the core interceptor.
///
/// Built on the *anonymous* client so a 401-triggered refresh cannot itself be
/// intercepted.
@Riverpod(keepAlive: true)
AuthTokenRefresher apiAuthTokenRefresher(Ref ref) => ApiAuthTokenRefresher(
  client: ref.watch(anonymousApiClientProvider),
  tokenStore: ref.watch(tokenStoreProvider),
);

/// The auth repository.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => ApiAuthRepository(
  anonymous: ref.watch(anonymousApiClientProvider),
  authenticated: ref.watch(apiClientProvider),
  tokenStore: ref.watch(tokenStoreProvider),
  refresher: ref.watch(apiAuthTokenRefresherProvider),
);

/// The consent repository.
@Riverpod(keepAlive: true)
ConsentRepository consentRepository(Ref ref) =>
    ApiConsentRepository(ref.watch(apiClientProvider));

/// Restores a returning user's session on cold start.
///
/// Overrides `sessionBootstrapperProvider` at app composition, replacing the
/// shell's `UnauthenticatedSessionBootstrapper`.
@Riverpod(keepAlive: true)
AuthSessionBootstrapper authSessionBootstrapper(Ref ref) =>
    AuthSessionBootstrapper(
      auth: ref.watch(authRepositoryProvider),
      consent: ref.watch(consentRepositoryProvider),
    );

// --- Use cases -------------------------------------------------------------

/// Exchanges a phone number and password for a session.
@riverpod
SignIn signIn(Ref ref) => SignIn(
  repository: ref.watch(authRepositoryProvider),
  session: ref.read(sessionControllerProvider.notifier),
);

/// Replaces the signed-in user's password.
@riverpod
ChangePassword changePassword(Ref ref) =>
    ChangePassword(ref.watch(authRepositoryProvider));

/// Rotates the stored token pair.
@Riverpod(keepAlive: true)
RefreshTokens refreshTokens(Ref ref) =>
    RefreshTokens(ref.watch(authRepositoryProvider));

/// Records the privacy-policy and image-rights consents.
@riverpod
CaptureConsent captureConsent(Ref ref) => CaptureConsent(
  repository: ref.watch(consentRepositoryProvider),
  session: ref.read(sessionControllerProvider.notifier),
);

/// Ends the session on this device.
@riverpod
SignOut signOut(Ref ref) => SignOut(
  repository: ref.watch(authRepositoryProvider),
  session: ref.read(sessionControllerProvider.notifier),
);

/// What the consent screen must collect, loaded from the server.
///
/// Never cached: `consent_record` is append-only, two guardians of the same
/// child can disagree, and most-restrictive-wins is resolved in the backend.
@riverpod
Future<ConsentRequirement> consentRequirement(Ref ref) =>
    ref.watch(consentRepositoryProvider).loadRequirement();
