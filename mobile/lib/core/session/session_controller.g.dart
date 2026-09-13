// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The token store. Overridden in tests with [InMemoryTokenStore].

@ProviderFor(tokenStore)
const tokenStoreProvider = TokenStoreProvider._();

/// The token store. Overridden in tests with [InMemoryTokenStore].

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  /// The token store. Overridden in tests with [InMemoryTokenStore].
  const TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'e1af499041ec8e3fd653ab4576cba8185f657d98';

/// The session bootstrapper.
///
/// Overridden at app composition with the `auth` feature's implementation; the
/// default throws rather than silently returning "signed out", which would
/// look like a working app that can never sign anyone in.

@ProviderFor(sessionBootstrapper)
const sessionBootstrapperProvider = SessionBootstrapperProvider._();

/// The session bootstrapper.
///
/// Overridden at app composition with the `auth` feature's implementation; the
/// default throws rather than silently returning "signed out", which would
/// look like a working app that can never sign anyone in.

final class SessionBootstrapperProvider
    extends
        $FunctionalProvider<
          SessionBootstrapper,
          SessionBootstrapper,
          SessionBootstrapper
        >
    with $Provider<SessionBootstrapper> {
  /// The session bootstrapper.
  ///
  /// Overridden at app composition with the `auth` feature's implementation; the
  /// default throws rather than silently returning "signed out", which would
  /// look like a working app that can never sign anyone in.
  const SessionBootstrapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionBootstrapperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionBootstrapperHash();

  @$internal
  @override
  $ProviderElement<SessionBootstrapper> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionBootstrapper create(Ref ref) {
    return sessionBootstrapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionBootstrapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionBootstrapper>(value),
    );
  }
}

String _$sessionBootstrapperHash() =>
    r'f09bd5eaa91aaa071e9158941119fdc85e3c046b';

/// Holds the app's session and is the only thing allowed to change it.
///
/// Every screen, the router's guards, and the API client read session state
/// from here, so it is `keepAlive` — a session that could be garbage-collected
/// between screens would sign the user out on a navigation.

@ProviderFor(SessionController)
const sessionControllerProvider = SessionControllerProvider._();

/// Holds the app's session and is the only thing allowed to change it.
///
/// Every screen, the router's guards, and the API client read session state
/// from here, so it is `keepAlive` — a session that could be garbage-collected
/// between screens would sign the user out on a navigation.
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, AppSession> {
  /// Holds the app's session and is the only thing allowed to change it.
  ///
  /// Every screen, the router's guards, and the API client read session state
  /// from here, so it is `keepAlive` — a session that could be garbage-collected
  /// between screens would sign the user out on a navigation.
  const SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSession>(value),
    );
  }
}

String _$sessionControllerHash() => r'7a151dfdb384483ca850ff7415eb9df1b20c4b5b';

/// Holds the app's session and is the only thing allowed to change it.
///
/// Every screen, the router's guards, and the API client read session state
/// from here, so it is `keepAlive` — a session that could be garbage-collected
/// between screens would sign the user out on a navigation.

abstract class _$SessionController extends $Notifier<AppSession> {
  AppSession build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppSession, AppSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSession, AppSession>,
              AppSession,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The current user's abilities.
///
/// Widgets read this rather than inspecting roles — `specs/05-authorization.md`
/// forbids `if (role == 'educator')` in the UI, and a provider makes the right
/// way also the convenient way.

@ProviderFor(ability)
const abilityProvider = AbilityProvider._();

/// The current user's abilities.
///
/// Widgets read this rather than inspecting roles — `specs/05-authorization.md`
/// forbids `if (role == 'educator')` in the UI, and a provider makes the right
/// way also the convenient way.

final class AbilityProvider
    extends $FunctionalProvider<Ability, Ability, Ability>
    with $Provider<Ability> {
  /// The current user's abilities.
  ///
  /// Widgets read this rather than inspecting roles — `specs/05-authorization.md`
  /// forbids `if (role == 'educator')` in the UI, and a provider makes the right
  /// way also the convenient way.
  const AbilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'abilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$abilityHash();

  @$internal
  @override
  $ProviderElement<Ability> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Ability create(Ref ref) {
    return ability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Ability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Ability>(value),
    );
  }
}

String _$abilityHash() => r'2d99f4e75c6805200271729889b8e13e699710c7';
