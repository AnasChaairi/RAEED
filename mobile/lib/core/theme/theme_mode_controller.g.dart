// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which brightness the app renders in.
///
/// Follows the system by default. The More screen offers an explicit dark
/// toggle for the executive who reads the dashboard in a dim hall and wants
/// it dark regardless of what the phone thinks — a *presentation* choice
/// that never touches the palette itself, which stays the generated tokens
/// for whichever brightness is active.
///
/// In memory only for now: persisting it is a small follow-up once a
/// preferences store exists, and a toggle that resets on restart is a
/// nuisance, not a safeguarding risk.

@ProviderFor(ThemeModeController)
const themeModeControllerProvider = ThemeModeControllerProvider._();

/// Which brightness the app renders in.
///
/// Follows the system by default. The More screen offers an explicit dark
/// toggle for the executive who reads the dashboard in a dim hall and wants
/// it dark regardless of what the phone thinks — a *presentation* choice
/// that never touches the palette itself, which stays the generated tokens
/// for whichever brightness is active.
///
/// In memory only for now: persisting it is a small follow-up once a
/// preferences store exists, and a toggle that resets on restart is a
/// nuisance, not a safeguarding risk.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// Which brightness the app renders in.
  ///
  /// Follows the system by default. The More screen offers an explicit dark
  /// toggle for the executive who reads the dashboard in a dim hall and wants
  /// it dark regardless of what the phone thinks — a *presentation* choice
  /// that never touches the palette itself, which stays the generated tokens
  /// for whichever brightness is active.
  ///
  /// In memory only for now: persisting it is a small follow-up once a
  /// preferences store exists, and a toggle that resets on restart is a
  /// nuisance, not a safeguarding risk.
  const ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'20406f825f98425869cfbc5bf91f2f33901fa0ec';

/// Which brightness the app renders in.
///
/// Follows the system by default. The More screen offers an explicit dark
/// toggle for the executive who reads the dashboard in a dim hall and wants
/// it dark regardless of what the phone thinks — a *presentation* choice
/// that never touches the palette itself, which stays the generated tokens
/// for whichever brightness is active.
///
/// In memory only for now: persisting it is a small follow-up once a
/// preferences store exists, and a toggle that resets on restart is a
/// nuisance, not a safeguarding risk.

abstract class _$ThemeModeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
