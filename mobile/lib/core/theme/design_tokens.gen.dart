// GENERATED — DO NOT EDIT BY HAND.
//
// Source: specs/08-design-system/design-tokens.json
// Regenerate: dart run tool/generate_design_tokens.dart
//
// Rationale for every value here lives in specs/08-design-system/style-guide.md —
// notably why the logo's raw blue is not the `primary` token (it only reaches
// 3.97:1 on white, short of WCAG AA for body text).

import 'package:flutter/painting.dart';

/// A semantic colour palette, one instance per theme brightness.
///
/// Widgets never reference these directly — they read them through the
/// `RaeedTheme` extension on `BuildContext`, so a widget cannot accidentally
/// hardcode the light palette into a dark-mode screen.
class RaeedPalette {
  const RaeedPalette({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkDim,
    required this.border,
    required this.primary,
    required this.primaryOn,
    required this.primarySoft,
    required this.accent,
    required this.accentDecorative,
    required this.accentOn,
    required this.accentSoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  /// `color.<brightness>.bg`
  final Color bg;

  /// `color.<brightness>.surface`
  final Color surface;

  /// `color.<brightness>.surfaceAlt`
  final Color surfaceAlt;

  /// `color.<brightness>.ink`
  final Color ink;

  /// `color.<brightness>.inkDim`
  final Color inkDim;

  /// `color.<brightness>.border`
  final Color border;

  /// `color.<brightness>.primary`
  final Color primary;

  /// `color.<brightness>.primaryOn`
  final Color primaryOn;

  /// `color.<brightness>.primarySoft`
  final Color primarySoft;

  /// `color.<brightness>.accent`
  final Color accent;

  /// `color.<brightness>.accentDecorative`
  final Color accentDecorative;

  /// `color.<brightness>.accentOn`
  final Color accentOn;

  /// `color.<brightness>.accentSoft`
  final Color accentSoft;

  /// `color.<brightness>.success`
  final Color success;

  /// `color.<brightness>.warning`
  final Color warning;

  /// `color.<brightness>.danger`
  final Color danger;

  /// `color.<brightness>.info`
  final Color info;
}

/// The light-mode palette.
const RaeedPalette raeedLightPalette = RaeedPalette(
  bg: Color(0xFFF7F9FB),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFEEF3F8),
  ink: Color(0xFF10161C),
  inkDim: Color(0xFF4C5A66),
  border: Color(0xFFDCE4EC),
  primary: Color(0xFF0A4A8C),
  primaryOn: Color(0xFFFFFFFF),
  primarySoft: Color(0xFFE2EEFA),
  accent: Color(0xFF9C6900),
  accentDecorative: Color(0xFFF2A900),
  accentOn: Color(0xFFFFFFFF),
  accentSoft: Color(0xFFFBEDD2),
  success: Color(0xFF1A7A44),
  warning: Color(0xFFA85A0A),
  danger: Color(0xFFB02A22),
  info: Color(0xFF0A70B6),
);

/// The dark-mode palette.
const RaeedPalette raeedDarkPalette = RaeedPalette(
  bg: Color(0xFF0B0F14),
  surface: Color(0xFF121820),
  surfaceAlt: Color(0xFF1A222C),
  ink: Color(0xFFE8EEF3),
  inkDim: Color(0xFF9FB0BE),
  border: Color(0xFF28323D),
  primary: Color(0xFF29C4EF),
  primaryOn: Color(0xFF06222E),
  primarySoft: Color(0xFF113240),
  accent: Color(0xFFF2A900),
  accentDecorative: Color(0xFFF2A900),
  accentOn: Color(0xFF2B1C00),
  accentSoft: Color(0xFF33290F),
  success: Color(0xFF34C185),
  warning: Color(0xFFE0A544),
  danger: Color(0xFFE2685A),
  info: Color(0xFF29C4EF),
);

/// Raw colours sampled from `logo/logo.jpeg`.
///
/// extracted directly from logo/logo.jpeg — kept for traceability, not for direct app use except in logo lockups
///
/// Use these only inside logo lockups and the brand gradient. For anything
/// bearing text, reach for [RaeedPalette] instead — these raw values do not
/// all meet WCAG AA.
abstract final class RaeedLogoColors {
  static const Color blueAverage = Color(0xFF0A82DA);
  static const Color blueDark = Color(0xFF06336A);
  static const Color blueLight = Color(0xFF14E9FF);
  static const Color goldAverage = Color(0xFFEFA80E);
  static const Color goldDark = Color(0xFF9A5F19);
  static const Color goldLight = Color(0xFFE4E74E);
  static const Color backdropBlack = Color(0xFF000000);
}

/// Font families, with their fallback chains.
///
/// Amiri ships Regular (400) and Bold (700) only — no 500/600. Build Arabic hierarchy with size, color, and spacing, not intermediate weights. uiSans (Public Sans) carries the fuller weight range (400/500/600/700) for compact UI chrome (buttons, tabs, form labels) in both RTL and LTR layouts, and for French/English body text.
abstract final class RaeedFonts {
  /// `typography.fontFamily.arabic`
  static const String arabic = 'Amiri';
  static const List<String> arabicFallback = <String>[
    'Traditional Arabic',
    'serif',
  ];

  /// `typography.fontFamily.latinDisplay`
  static const String latinDisplay = 'Lora';
  static const List<String> latinDisplayFallback = <String>[
    'Georgia',
    'Times New Roman',
    'serif',
  ];

  /// `typography.fontFamily.uiSans`
  static const String uiSans = 'Public Sans';
  static const List<String> uiSansFallback = <String>[
    '-apple-system',
    'Segoe UI',
    'Tahoma',
    'sans-serif',
  ];

  /// `typography.fontFamily.mono`
  static const String mono = 'IBM Plex Mono';
  static const List<String> monoFallback = <String>[
    'SFMono-Regular',
    'Consolas',
    'monospace',
  ];

  /// Amiri ships only these weights — build Arabic hierarchy with size,
  /// colour and spacing, never an intermediate weight that does not exist.
  static const List<int> arabicWeights = <int>[400, 700];
}

/// One step of the type scale.
///
/// Arabic and Latin carry different line heights on purpose: Amiri needs
/// markedly more leading than a Latin face at the same size for its
/// diacritics to breathe.
class RaeedTypeStep {
  const RaeedTypeStep({
    required this.size,
    required this.lineHeightArabic,
    required this.lineHeightLatin,
    required this.weight,
    this.letterSpacingEm,
  });

  /// Font size in logical pixels, before text scaling.
  final double size;

  /// Line height multiple used when the script is Arabic.
  final double lineHeightArabic;

  /// Line height multiple used when the script is Latin.
  final double lineHeightLatin;

  /// CSS-style numeric weight (400/500/700).
  final int weight;

  /// Letter spacing expressed in em, as the tokens file records it.
  final double? letterSpacingEm;

  /// Letter spacing in logical pixels at [size].
  double? get letterSpacing =>
      letterSpacingEm == null ? null : letterSpacingEm! * size;
}

/// `typography.scale` — the only sanctioned font sizes.
abstract final class RaeedTypeScale {
  static const RaeedTypeStep display = RaeedTypeStep(
    size: 32.0,
    lineHeightArabic: 1.5,
    lineHeightLatin: 1.25,
    weight: 700,
  );
  static const RaeedTypeStep h1 = RaeedTypeStep(
    size: 26.0,
    lineHeightArabic: 1.55,
    lineHeightLatin: 1.3,
    weight: 700,
  );
  static const RaeedTypeStep h2 = RaeedTypeStep(
    size: 21.0,
    lineHeightArabic: 1.6,
    lineHeightLatin: 1.3,
    weight: 700,
  );
  static const RaeedTypeStep h3 = RaeedTypeStep(
    size: 18.0,
    lineHeightArabic: 1.65,
    lineHeightLatin: 1.35,
    weight: 700,
  );
  static const RaeedTypeStep body = RaeedTypeStep(
    size: 16.0,
    lineHeightArabic: 1.8,
    lineHeightLatin: 1.5,
    weight: 400,
  );
  static const RaeedTypeStep bodySmall = RaeedTypeStep(
    size: 14.0,
    lineHeightArabic: 1.8,
    lineHeightLatin: 1.5,
    weight: 400,
  );
  static const RaeedTypeStep caption = RaeedTypeStep(
    size: 12.0,
    lineHeightArabic: 1.7,
    lineHeightLatin: 1.4,
    weight: 500,
    letterSpacingEm: 0.02,
  );
}

/// `spacing` — the 4pt scale every gap and padding comes from.
abstract final class RaeedSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
  static const double xl6 = 64.0;
}

/// `radius` — corner radii. [pill] is an arbitrary large value that
/// reads as fully rounded at any realistic control height.
abstract final class RaeedRadius {
  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double pill = 999.0;
}

/// `elevation` — shadows, translated from the tokens file's CSS notation.
abstract final class RaeedElevation {
  static const List<BoxShadow> lightSm = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F10161C),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
    ),
    BoxShadow(
      color: Color(0x1F10161C),
      offset: Offset(0.0, 4.0),
      blurRadius: 12.0,
      spreadRadius: -6.0,
    ),
  ];
  static const List<BoxShadow> darkSm = <BoxShadow>[
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
    ),
    BoxShadow(
      color: Color(0x99000000),
      offset: Offset(0.0, 8.0),
      blurRadius: 20.0,
      spreadRadius: -10.0,
    ),
  ];
}

/// `touchTarget` — minimum hit areas.
///
/// [minPx] is the floor for any tappable control; [primaryActionsPx] applies
/// to primary actions, which on the attendance screen are tapped repeatedly,
/// at speed, often one-handed.
abstract final class RaeedTouchTarget {
  static const double minPx = 44.0;
  static const double primaryActionsPx = 52.0;
}
