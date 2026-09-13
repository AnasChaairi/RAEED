import 'package:flutter/material.dart';

import 'design_tokens.gen.dart';
import 'raeed_typography.dart';

/// Carries RAEED's own design tokens through the widget tree.
///
/// Material's [ColorScheme] cannot express the palette in
/// `specs/08-design-system/design-tokens.json` without lossy mapping — there is
/// no Material slot for `accentDecorative`, `inkDim`, `surfaceAlt`, or the
/// semantic `success`/`warning`/`danger`/`info` set, and squeezing them into
/// `tertiary`/`outlineVariant` would make call sites unreadable.
///
/// So the tokens travel as a [ThemeExtension] and widgets read
/// `context.palette` / `context.type`. A [ColorScheme] is still derived
/// alongside it so stock Material widgets look right, but it is a projection of
/// this, never the source.
@immutable
class RaeedThemeExtension extends ThemeExtension<RaeedThemeExtension> {
  const RaeedThemeExtension({
    required this.palette,
    required this.typography,
    required this.elevationSm,
  });

  /// Every semantic colour for the current brightness.
  final RaeedPalette palette;

  /// Script-aware text styles for the current locale.
  final RaeedTypography typography;

  /// The one elevation step the design system defines.
  ///
  /// RAEED's surfaces are flat by design: cards are separated by a border and
  /// a background shift, not a stack of shadows. Only genuinely floating
  /// things (bottom sheets, the FAB) take this.
  final List<BoxShadow> elevationSm;

  @override
  RaeedThemeExtension copyWith({
    RaeedPalette? palette,
    RaeedTypography? typography,
    List<BoxShadow>? elevationSm,
  }) => RaeedThemeExtension(
    palette: palette ?? this.palette,
    typography: typography ?? this.typography,
    elevationSm: elevationSm ?? this.elevationSm,
  );

  /// Colours are not lerped between themes.
  ///
  /// A half-way blend of the light and dark palettes hits none of the contrast
  /// ratios that were computed for either, and RAEED's theme changes are
  /// discrete (a settings toggle or a system change), never animated — so the
  /// honest behaviour is to snap at the midpoint rather than render an
  /// inaccessible in-between state.
  @override
  RaeedThemeExtension lerp(
    covariant ThemeExtension<RaeedThemeExtension>? other,
    double t,
  ) {
    if (other is! RaeedThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

/// Reads RAEED's design tokens off a [BuildContext].
extension RaeedThemeContext on BuildContext {
  RaeedThemeExtension get _raeed {
    final extension = Theme.of(this).extension<RaeedThemeExtension>();
    assert(
      extension != null,
      'RaeedThemeExtension is missing. Wrap this subtree in the app theme built '
      'by RaeedTheme.light()/dark() — widgets must not fall back to hardcoded '
      'colours.',
    );
    return extension ??
        RaeedTheme.light(const Locale('ar')).extension<RaeedThemeExtension>()!;
  }

  /// The semantic colour palette for the active theme.
  RaeedPalette get palette => _raeed.palette;

  /// Script-aware text styles for the active locale.
  RaeedTypography get type => _raeed.typography;

  /// The design system's single elevation step.
  List<BoxShadow> get elevationSm => _raeed.elevationSm;

  /// Whether the active theme is the dark one.
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  /// Whether the active locale lays out right-to-left.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}

/// Builds the app's [ThemeData], light and dark, from the generated tokens.
///
/// Both themes take a [Locale] because the type scale is script-dependent —
/// see [RaeedTypography].
abstract final class RaeedTheme {
  /// The light theme.
  static ThemeData light(Locale locale) => _build(
    locale: locale,
    palette: raeedLightPalette,
    brightness: Brightness.light,
  );

  /// The dark theme.
  static ThemeData dark(Locale locale) => _build(
    locale: locale,
    palette: raeedDarkPalette,
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required Locale locale,
    required RaeedPalette palette,
    required Brightness brightness,
  }) {
    final typography = RaeedTypography.forLocale(locale);
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.primaryOn,
      primaryContainer: palette.primarySoft,
      onPrimaryContainer: palette.primary,
      secondary: palette.accent,
      onSecondary: palette.accentOn,
      secondaryContainer: palette.accentSoft,
      onSecondaryContainer: palette.accent,
      error: palette.danger,
      onError: isLight ? palette.surface : palette.bg,
      surface: palette.surface,
      onSurface: palette.ink,
      onSurfaceVariant: palette.inkDim,
      surfaceContainerHighest: palette.surfaceAlt,
      outline: palette.border,
      outlineVariant: palette.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.bg,
      canvasColor: palette.bg,
      dividerColor: palette.border,
      textTheme: typography.materialTextTheme,
      fontFamily: typography.readingFamily,

      extensions: <ThemeExtension<dynamic>>[
        RaeedThemeExtension(
          palette: palette,
          typography: typography,
          elevationSm: isLight ? RaeedElevation.lightSm : RaeedElevation.darkSm,
        ),
      ],

      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: typography.h3.copyWith(color: palette.ink),
      ),

      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.lg),
          side: BorderSide(color: palette.border),
        ),
      ),

      // Every primary action clears the 52px target from
      // `touchTarget.primaryActionsPx`. Educators mark attendance at speed,
      // one-handed, often standing up — an undersized chip costs a mis-tap on
      // a child's attendance record.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.primaryOn,
          disabledBackgroundColor: palette.surfaceAlt,
          disabledForegroundColor: palette.inkDim,
          minimumSize: const Size.fromHeight(RaeedTouchTarget.primaryActionsPx),
          padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xl),
          textStyle: typography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaeedRadius.md),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          minimumSize: const Size.fromHeight(RaeedTouchTarget.primaryActionsPx),
          padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xl),
          textStyle: typography.button,
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaeedRadius.md),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          minimumSize: const Size(
            RaeedTouchTarget.minPx,
            RaeedTouchTarget.minPx,
          ),
          textStyle: typography.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.lg,
          vertical: RaeedSpacing.lg,
        ),
        hintStyle: typography.body.copyWith(color: palette.inkDim),
        labelStyle: typography.label.copyWith(color: palette.inkDim),
        errorStyle: typography.caption.copyWith(color: palette.danger),
        border: _inputBorder(palette.border),
        enabledBorder: _inputBorder(palette.border),
        focusedBorder: _inputBorder(palette.primary, width: 2),
        errorBorder: _inputBorder(palette.danger),
        focusedErrorBorder: _inputBorder(palette.danger, width: 2),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceAlt,
        selectedColor: palette.primarySoft,
        labelStyle: typography.label.copyWith(color: palette.ink),
        side: BorderSide(color: palette.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.md,
          vertical: RaeedSpacing.sm,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: typography.bodySmall.copyWith(color: palette.bg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.md),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.inkDim,
        selectedLabelStyle: typography.caption,
        unselectedLabelStyle: typography.caption,
        type: BottomNavigationBarType.fixed,
      ),

      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.surfaceAlt,
        circularTrackColor: palette.surfaceAlt,
      ),

      listTileTheme: ListTileThemeData(
        titleTextStyle: typography.body.copyWith(color: palette.ink),
        subtitleTextStyle: typography.bodySmall.copyWith(color: palette.inkDim),
        iconColor: palette.inkDim,
        minVerticalPadding: RaeedSpacing.md,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(RaeedRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
}
