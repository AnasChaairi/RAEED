// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The registered screens. Overridden at app composition in `lib/app.dart`.

@ProviderFor(appScreens)
const appScreensProvider = AppScreensProvider._();

/// The registered screens. Overridden at app composition in `lib/app.dart`.

final class AppScreensProvider
    extends $FunctionalProvider<AppScreens, AppScreens, AppScreens>
    with $Provider<AppScreens> {
  /// The registered screens. Overridden at app composition in `lib/app.dart`.
  const AppScreensProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appScreensProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appScreensHash();

  @$internal
  @override
  $ProviderElement<AppScreens> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppScreens create(Ref ref) {
    return appScreens(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppScreens value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppScreens>(value),
    );
  }
}

String _$appScreensHash() => r'93702015f6dbc4ab91320f6683112dfe8f67ab64';

/// The app's [GoRouter].
///
/// `keepAlive` because a router rebuilt mid-navigation loses the navigation
/// stack. It watches session state through a [Listenable] rather than
/// `ref.watch`, so a session change re-runs the *redirects* without disposing
/// and rebuilding the router itself.

@ProviderFor(appRouter)
const appRouterProvider = AppRouterProvider._();

/// The app's [GoRouter].
///
/// `keepAlive` because a router rebuilt mid-navigation loses the navigation
/// stack. It watches session state through a [Listenable] rather than
/// `ref.watch`, so a session change re-runs the *redirects* without disposing
/// and rebuilding the router itself.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter].
  ///
  /// `keepAlive` because a router rebuilt mid-navigation loses the navigation
  /// stack. It watches session state through a [Listenable] rather than
  /// `ref.watch`, so a session change re-runs the *redirects* without disposing
  /// and rebuilding the router itself.
  const AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'7c29ccf72a6c8076a424631026cf07a525a2a7d0';
