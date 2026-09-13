import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client_provider.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/session_controller.dart';
import '../application/capture_consent.dart';
import '../application/refresh_tokens.dart';
import '../application/request_otp.dart';
import '../application/sign_out.dart';
import '../application/verify_otp.dart';
import '../data/auth_repository_impl.dart';
import '../data/auth_session_bootstrapper.dart';
import '../data/consent_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/consent.dart';
import '../domain/consent_repository.dart';
import '../domain/otp_policy.dart';

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

/// Sends a one-time code.
@riverpod
RequestOtp requestOtp(Ref ref) => RequestOtp(ref.watch(authRepositoryProvider));

/// Exchanges a code for a session.
@riverpod
VerifyOtp verifyOtp(Ref ref) => VerifyOtp(
  repository: ref.watch(authRepositoryProvider),
  session: ref.read(sessionControllerProvider.notifier),
);

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

/// The receipt for the OTP currently awaiting verification.
///
/// Carries the phone number from the login screen to the OTP screen, and the
/// request count across resends so the hourly budget is tracked. Null when no
/// code is outstanding.
///
/// Held in memory only, never persisted: an unverified phone number sitting in
/// storage would outlive the sixty seconds it is useful for, and
/// `specs/10-security-and-privacy.md` keeps raw numbers out of everything but
/// the request body.
@Riverpod(keepAlive: true)
class PendingOtp extends _$PendingOtp {
  @override
  OtpRequestReceipt? build() => null;

  /// Records a freshly requested code and unlocks `/login/otp`.
  void begin(OtpRequestReceipt receipt) {
    state = receipt;
    ref.read(pendingOtpRequestProvider.notifier).begin();
  }

  /// Clears the outstanding code — on success, or on going back to change the
  /// number.
  void clear() {
    state = null;
    ref.read(pendingOtpRequestProvider.notifier).clear();
  }
}
