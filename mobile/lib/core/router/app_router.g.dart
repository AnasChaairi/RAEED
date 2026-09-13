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

/// True while an OTP has been requested and not yet verified.
///
/// Guards `/login/otp`, which without a pending request has no phone number to
/// verify and would be a dead end. Owned by the auth feature, read here.

@ProviderFor(PendingOtpRequest)
const pendingOtpRequestProvider = PendingOtpRequestProvider._();

/// True while an OTP has been requested and not yet verified.
///
/// Guards `/login/otp`, which without a pending request has no phone number to
/// verify and would be a dead end. Owned by the auth feature, read here.
final class PendingOtpRequestProvider
    extends $NotifierProvider<PendingOtpRequest, bool> {
  /// True while an OTP has been requested and not yet verified.
  ///
  /// Guards `/login/otp`, which without a pending request has no phone number to
  /// verify and would be a dead end. Owned by the auth feature, read here.
  const PendingOtpRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingOtpRequestProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingOtpRequestHash();

  @$internal
  @override
  PendingOtpRequest create() => PendingOtpRequest();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pendingOtpRequestHash() => r'e7a3f02d6b5b34bef13db6bde9096f4a6cd40b46';

/// True while an OTP has been requested and not yet verified.
///
/// Guards `/login/otp`, which without a pending request has no phone number to
/// verify and would be a dead end. Owned by the auth feature, read here.

abstract class _$PendingOtpRequest extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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

String _$appRouterHash() => r'fc01301e730229bfaa742898ffbc85e8cfdf90fa';
