// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves which locale the UI runs in.
///
/// Precedence: an explicit in-app choice, then the signed-in user's
/// `app_user.preferred_locale`, then Arabic. The device locale is deliberately
/// not consulted — see [supportedLocales].

@ProviderFor(LocaleController)
const localeControllerProvider = LocaleControllerProvider._();

/// Resolves which locale the UI runs in.
///
/// Precedence: an explicit in-app choice, then the signed-in user's
/// `app_user.preferred_locale`, then Arabic. The device locale is deliberately
/// not consulted — see [supportedLocales].
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, Locale> {
  /// Resolves which locale the UI runs in.
  ///
  /// Precedence: an explicit in-app choice, then the signed-in user's
  /// `app_user.preferred_locale`, then Arabic. The device locale is deliberately
  /// not consulted — see [supportedLocales].
  const LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$localeControllerHash() => r'e779e2f10a1c140b89085ff04dc65e021a6f1e45';

/// Resolves which locale the UI runs in.
///
/// Precedence: an explicit in-app choice, then the signed-in user's
/// `app_user.preferred_locale`, then Arabic. The device locale is deliberately
/// not consulted — see [supportedLocales].

abstract class _$LocaleController extends $Notifier<Locale> {
  Locale build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Locale, Locale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale, Locale>,
              Locale,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
