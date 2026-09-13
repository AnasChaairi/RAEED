// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The build-time environment.
///
/// A provider rather than a global constant so a test can point the app at a
/// stub server without a `--dart-define`.

@ProviderFor(appEnvironment)
const appEnvironmentProvider = AppEnvironmentProvider._();

/// The build-time environment.
///
/// A provider rather than a global constant so a test can point the app at a
/// stub server without a `--dart-define`.

final class AppEnvironmentProvider
    extends $FunctionalProvider<AppEnvironment, AppEnvironment, AppEnvironment>
    with $Provider<AppEnvironment> {
  /// The build-time environment.
  ///
  /// A provider rather than a global constant so a test can point the app at a
  /// stub server without a `--dart-define`.
  const AppEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appEnvironmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appEnvironmentHash();

  @$internal
  @override
  $ProviderElement<AppEnvironment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppEnvironment create(Ref ref) {
    return appEnvironment(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppEnvironment>(value),
    );
  }
}

String _$appEnvironmentHash() => r'e68326545f2c52b5e24a1040210d7658eb2e8fe0';

/// A client with **no** auth interceptor.
///
/// `/auth/otp/request`, `/auth/otp/verify` and `/auth/refresh` are
/// `security: []` in `specs/04-api/openapi.yaml`. Refreshing through the
/// interceptor whose whole job is to trigger refreshes would recurse, so the
/// refresh call in particular must go out on a client that cannot intercept
/// it.

@ProviderFor(anonymousApiClient)
const anonymousApiClientProvider = AnonymousApiClientProvider._();

/// A client with **no** auth interceptor.
///
/// `/auth/otp/request`, `/auth/otp/verify` and `/auth/refresh` are
/// `security: []` in `specs/04-api/openapi.yaml`. Refreshing through the
/// interceptor whose whole job is to trigger refreshes would recurse, so the
/// refresh call in particular must go out on a client that cannot intercept
/// it.

final class AnonymousApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// A client with **no** auth interceptor.
  ///
  /// `/auth/otp/request`, `/auth/otp/verify` and `/auth/refresh` are
  /// `security: []` in `specs/04-api/openapi.yaml`. Refreshing through the
  /// interceptor whose whole job is to trigger refreshes would recurse, so the
  /// refresh call in particular must go out on a client that cannot intercept
  /// it.
  const AnonymousApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anonymousApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anonymousApiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return anonymousApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$anonymousApiClientHash() =>
    r'43980cabd25736c492a40e7227b3cfee6342e689';

/// Rotates refresh tokens.
///
/// Declared here and overridden at app composition with the `auth` feature's
/// implementation, for the same reason as `sessionBootstrapperProvider`: the
/// interceptor is core infrastructure, but rotating a token is an API call
/// that belongs to a feature. The narrow seam keeps the dependency pointing
/// inward.
///
/// The default throws rather than returning a no-op refresher, which would
/// look like a working app that silently signs everyone out after fifteen
/// minutes.

@ProviderFor(authTokenRefresher)
const authTokenRefresherProvider = AuthTokenRefresherProvider._();

/// Rotates refresh tokens.
///
/// Declared here and overridden at app composition with the `auth` feature's
/// implementation, for the same reason as `sessionBootstrapperProvider`: the
/// interceptor is core infrastructure, but rotating a token is an API call
/// that belongs to a feature. The narrow seam keeps the dependency pointing
/// inward.
///
/// The default throws rather than returning a no-op refresher, which would
/// look like a working app that silently signs everyone out after fifteen
/// minutes.

final class AuthTokenRefresherProvider
    extends
        $FunctionalProvider<
          AuthTokenRefresher,
          AuthTokenRefresher,
          AuthTokenRefresher
        >
    with $Provider<AuthTokenRefresher> {
  /// Rotates refresh tokens.
  ///
  /// Declared here and overridden at app composition with the `auth` feature's
  /// implementation, for the same reason as `sessionBootstrapperProvider`: the
  /// interceptor is core infrastructure, but rotating a token is an API call
  /// that belongs to a feature. The narrow seam keeps the dependency pointing
  /// inward.
  ///
  /// The default throws rather than returning a no-op refresher, which would
  /// look like a working app that silently signs everyone out after fifteen
  /// minutes.
  const AuthTokenRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenRefresherHash();

  @$internal
  @override
  $ProviderElement<AuthTokenRefresher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthTokenRefresher create(Ref ref) {
    return authTokenRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenRefresher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenRefresher>(value),
    );
  }
}

String _$authTokenRefresherHash() =>
    r'6c651a4ab2e5288d613f5f29731b0d8cfd626bc7';

/// The app's authenticated [ApiClient] — what every feature outside `auth`
/// should use.
///
/// `keepAlive` because the underlying `dio` instance carries the auth
/// interceptor and its connection pool; rebuilding it per screen would drop
/// warm connections on a network where a warm connection is the difference
/// between a card that loads and one that times out.

@ProviderFor(apiClient)
const apiClientProvider = ApiClientProvider._();

/// The app's authenticated [ApiClient] — what every feature outside `auth`
/// should use.
///
/// `keepAlive` because the underlying `dio` instance carries the auth
/// interceptor and its connection pool; rebuilding it per screen would drop
/// warm connections on a network where a warm connection is the difference
/// between a card that loads and one that times out.

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// The app's authenticated [ApiClient] — what every feature outside `auth`
  /// should use.
  ///
  /// `keepAlive` because the underlying `dio` instance carries the auth
  /// interceptor and its connection pool; rebuilding it per screen would drop
  /// warm connections on a network where a warm connection is the difference
  /// between a card that loads and one that times out.
  const ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'cede417b20b89978e5487c57b36137b35d058201';
