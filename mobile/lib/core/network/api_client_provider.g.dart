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

/// The app's single [ApiClient].
///
/// `keepAlive` because the underlying `dio` instance carries the auth
/// interceptor and its connection pool; rebuilding it per screen would drop
/// warm connections on a network where warm connections are the difference
/// between a card that loads and one that times out.
///
/// Constructed from configuration rather than thrown-until-overridden, unlike
/// `sessionBootstrapperProvider`: there is exactly one correct client for a
/// given build, so making composition remember to wire it up would be pure
/// ceremony. Tests override it with a client built over a stub adapter.

@ProviderFor(apiClient)
const apiClientProvider = ApiClientProvider._();

/// The app's single [ApiClient].
///
/// `keepAlive` because the underlying `dio` instance carries the auth
/// interceptor and its connection pool; rebuilding it per screen would drop
/// warm connections on a network where warm connections are the difference
/// between a card that loads and one that times out.
///
/// Constructed from configuration rather than thrown-until-overridden, unlike
/// `sessionBootstrapperProvider`: there is exactly one correct client for a
/// given build, so making composition remember to wire it up would be pure
/// ceremony. Tests override it with a client built over a stub adapter.

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// The app's single [ApiClient].
  ///
  /// `keepAlive` because the underlying `dio` instance carries the auth
  /// interceptor and its connection pool; rebuilding it per screen would drop
  /// warm connections on a network where warm connections are the difference
  /// between a card that loads and one that times out.
  ///
  /// Constructed from configuration rather than thrown-until-overridden, unlike
  /// `sessionBootstrapperProvider`: there is exactly one correct client for a
  /// given build, so making composition remember to wire it up would be pure
  /// ceremony. Tests override it with a client built over a stub adapter.
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

String _$apiClientHash() => r'c82ed4eda8e4e554bf44669007b01f40577940ad';
