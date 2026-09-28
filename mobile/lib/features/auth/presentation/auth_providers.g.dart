// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Rotates refresh tokens, for the core interceptor.
///
/// Built on the *anonymous* client so a 401-triggered refresh cannot itself be
/// intercepted.

@ProviderFor(apiAuthTokenRefresher)
const apiAuthTokenRefresherProvider = ApiAuthTokenRefresherProvider._();

/// Rotates refresh tokens, for the core interceptor.
///
/// Built on the *anonymous* client so a 401-triggered refresh cannot itself be
/// intercepted.

final class ApiAuthTokenRefresherProvider
    extends
        $FunctionalProvider<
          AuthTokenRefresher,
          AuthTokenRefresher,
          AuthTokenRefresher
        >
    with $Provider<AuthTokenRefresher> {
  /// Rotates refresh tokens, for the core interceptor.
  ///
  /// Built on the *anonymous* client so a 401-triggered refresh cannot itself be
  /// intercepted.
  const ApiAuthTokenRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiAuthTokenRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiAuthTokenRefresherHash();

  @$internal
  @override
  $ProviderElement<AuthTokenRefresher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthTokenRefresher create(Ref ref) {
    return apiAuthTokenRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenRefresher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenRefresher>(value),
    );
  }
}

String _$apiAuthTokenRefresherHash() =>
    r'591ab8209789d02effe6db875f9c255ac1b908b4';

/// The auth repository.

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// The auth repository.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// The auth repository.
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'29c6a66056c99a4c7cc21442e906d1f8741a0f21';

/// The consent repository.

@ProviderFor(consentRepository)
const consentRepositoryProvider = ConsentRepositoryProvider._();

/// The consent repository.

final class ConsentRepositoryProvider
    extends
        $FunctionalProvider<
          ConsentRepository,
          ConsentRepository,
          ConsentRepository
        >
    with $Provider<ConsentRepository> {
  /// The consent repository.
  const ConsentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConsentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConsentRepository create(Ref ref) {
    return consentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsentRepository>(value),
    );
  }
}

String _$consentRepositoryHash() => r'8fab3271fc67244520b1f359ac7503cc478d41cf';

/// Restores a returning user's session on cold start.
///
/// Overrides `sessionBootstrapperProvider` at app composition, replacing the
/// shell's `UnauthenticatedSessionBootstrapper`.

@ProviderFor(authSessionBootstrapper)
const authSessionBootstrapperProvider = AuthSessionBootstrapperProvider._();

/// Restores a returning user's session on cold start.
///
/// Overrides `sessionBootstrapperProvider` at app composition, replacing the
/// shell's `UnauthenticatedSessionBootstrapper`.

final class AuthSessionBootstrapperProvider
    extends
        $FunctionalProvider<
          AuthSessionBootstrapper,
          AuthSessionBootstrapper,
          AuthSessionBootstrapper
        >
    with $Provider<AuthSessionBootstrapper> {
  /// Restores a returning user's session on cold start.
  ///
  /// Overrides `sessionBootstrapperProvider` at app composition, replacing the
  /// shell's `UnauthenticatedSessionBootstrapper`.
  const AuthSessionBootstrapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionBootstrapperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionBootstrapperHash();

  @$internal
  @override
  $ProviderElement<AuthSessionBootstrapper> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthSessionBootstrapper create(Ref ref) {
    return authSessionBootstrapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSessionBootstrapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSessionBootstrapper>(value),
    );
  }
}

String _$authSessionBootstrapperHash() =>
    r'597fc5aade50c530d37db945c01d7d9da44f7fa7';

/// Exchanges a phone number and password for a session.

@ProviderFor(signIn)
const signInProvider = SignInProvider._();

/// Exchanges a phone number and password for a session.

final class SignInProvider extends $FunctionalProvider<SignIn, SignIn, SignIn>
    with $Provider<SignIn> {
  /// Exchanges a phone number and password for a session.
  const SignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInHash();

  @$internal
  @override
  $ProviderElement<SignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignIn create(Ref ref) {
    return signIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignIn>(value),
    );
  }
}

String _$signInHash() => r'dd636b6a3f41bd2db2b7142c3e0315b78631d6e9';

/// Replaces the signed-in user's password.

@ProviderFor(changePassword)
const changePasswordProvider = ChangePasswordProvider._();

/// Replaces the signed-in user's password.

final class ChangePasswordProvider
    extends $FunctionalProvider<ChangePassword, ChangePassword, ChangePassword>
    with $Provider<ChangePassword> {
  /// Replaces the signed-in user's password.
  const ChangePasswordProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordHash();

  @$internal
  @override
  $ProviderElement<ChangePassword> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChangePassword create(Ref ref) {
    return changePassword(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePassword value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePassword>(value),
    );
  }
}

String _$changePasswordHash() => r'2301cc896d84655eaba31b8019ebfc84cd41ca8f';

/// Rotates the stored token pair.

@ProviderFor(refreshTokens)
const refreshTokensProvider = RefreshTokensProvider._();

/// Rotates the stored token pair.

final class RefreshTokensProvider
    extends $FunctionalProvider<RefreshTokens, RefreshTokens, RefreshTokens>
    with $Provider<RefreshTokens> {
  /// Rotates the stored token pair.
  const RefreshTokensProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshTokensProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshTokensHash();

  @$internal
  @override
  $ProviderElement<RefreshTokens> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RefreshTokens create(Ref ref) {
    return refreshTokens(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshTokens value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshTokens>(value),
    );
  }
}

String _$refreshTokensHash() => r'71cc04aac2f0b2f1ce5a47be1df629d509e4c15a';

/// Records the privacy-policy and image-rights consents.

@ProviderFor(captureConsent)
const captureConsentProvider = CaptureConsentProvider._();

/// Records the privacy-policy and image-rights consents.

final class CaptureConsentProvider
    extends $FunctionalProvider<CaptureConsent, CaptureConsent, CaptureConsent>
    with $Provider<CaptureConsent> {
  /// Records the privacy-policy and image-rights consents.
  const CaptureConsentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureConsentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureConsentHash();

  @$internal
  @override
  $ProviderElement<CaptureConsent> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaptureConsent create(Ref ref) {
    return captureConsent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureConsent value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureConsent>(value),
    );
  }
}

String _$captureConsentHash() => r'd7aef734f66332d9c42107d08e0b970c0e323ed3';

/// Ends the session on this device.

@ProviderFor(signOut)
const signOutProvider = SignOutProvider._();

/// Ends the session on this device.

final class SignOutProvider
    extends $FunctionalProvider<SignOut, SignOut, SignOut>
    with $Provider<SignOut> {
  /// Ends the session on this device.
  const SignOutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutHash();

  @$internal
  @override
  $ProviderElement<SignOut> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOut create(Ref ref) {
    return signOut(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOut value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOut>(value),
    );
  }
}

String _$signOutHash() => r'3b98da68dec567988d13d7c29795835c0a1a74b6';

/// What the consent screen must collect, loaded from the server.
///
/// Never cached: `consent_record` is append-only, two guardians of the same
/// child can disagree, and most-restrictive-wins is resolved in the backend.

@ProviderFor(consentRequirement)
const consentRequirementProvider = ConsentRequirementProvider._();

/// What the consent screen must collect, loaded from the server.
///
/// Never cached: `consent_record` is append-only, two guardians of the same
/// child can disagree, and most-restrictive-wins is resolved in the backend.

final class ConsentRequirementProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConsentRequirement>,
          ConsentRequirement,
          FutureOr<ConsentRequirement>
        >
    with
        $FutureModifier<ConsentRequirement>,
        $FutureProvider<ConsentRequirement> {
  /// What the consent screen must collect, loaded from the server.
  ///
  /// Never cached: `consent_record` is append-only, two guardians of the same
  /// child can disagree, and most-restrictive-wins is resolved in the backend.
  const ConsentRequirementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentRequirementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentRequirementHash();

  @$internal
  @override
  $FutureProviderElement<ConsentRequirement> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConsentRequirement> create(Ref ref) {
    return consentRequirement(ref);
  }
}

String _$consentRequirementHash() =>
    r'f470b1ae1131dc4f4dcc0496d8bb6f344ae8bbf3';
