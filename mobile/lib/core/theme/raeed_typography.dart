import 'package:flutter/material.dart' show TextTheme;
import 'package:flutter/widgets.dart';

import 'design_tokens.gen.dart';

/// Which script a piece of text is set in.
///
/// The type scale carries two line heights per step because Amiri needs
/// markedly more leading than a Latin face at the same size — its diacritics
/// sit above and below the baseline and collide at Latin leading. Picking the
/// wrong one is not a cosmetic difference in Arabic: it is the difference
/// between readable and cramped.
enum RaeedScript {
  /// Arabic — the primary reading language. Set in Amiri.
  arabic,

  /// French / English. Set in Lora (display) and Public Sans (chrome).
  latin;

  /// The script conventionally used for [locale].
  static RaeedScript forLocale(Locale locale) =>
      locale.languageCode == 'ar' ? RaeedScript.arabic : RaeedScript.latin;
}

/// Builds every [TextStyle] in the app from the generated type scale.
///
/// Three families, each with a job (`specs/08-design-system/style-guide.md`):
///
/// * **Amiri** — Arabic headings and body. A Naskh text face suited to
///   sustained reading of the Quran/hadith-adjacent content RAEED publishes.
/// * **Lora** — Latin display. A serif warm enough that Arabic and Latin read
///   as one typographic identity rather than two unrelated systems.
/// * **Public Sans** — dense UI chrome in both scripts: buttons, tabs, labels,
///   timestamps. It carries the 500/600 weights Amiri does not have.
///
/// Lora and Public Sans ship as variable fonts, so each style sets
/// `fontVariations` as well as `fontWeight`: Flutter selects the asset by
/// weight but does not move the `wght` axis on its own, and without the
/// variation every weight would render at the axis default.
class RaeedTypography {
  const RaeedTypography({required this.script});

  /// Builds the typography for [locale]'s script.
  factory RaeedTypography.forLocale(Locale locale) =>
      RaeedTypography(script: RaeedScript.forLocale(locale));

  /// Which script's line heights and reading face this instance produces.
  final RaeedScript script;

  bool get _isArabic => script == RaeedScript.arabic;

  /// The face used for headings and body copy — the text people *read*.
  String get readingFamily =>
      _isArabic ? RaeedFonts.arabic : RaeedFonts.latinDisplay;

  /// The face used for controls and metadata — the text people *operate*.
  ///
  /// Public Sans in both scripts. Arabic UI chrome in Amiri at 12–14px loses
  /// too much detail, and the weight range needed for a compact hierarchy is
  /// not there.
  String get chromeFamily => RaeedFonts.uiSans;

  /// Amiri Quran, for verse and hadith blocks inside Materials only.
  ///
  /// Never UI chrome — this face is tuned for Uthmanic-style typesetting, not
  /// for buttons.
  String get quranFamily => 'AmiriQuran';

  // --- Reading styles (Amiri / Lora) ---------------------------------------

  /// Largest step. Splash and empty-state headlines.
  TextStyle get display => _reading(RaeedTypeScale.display);

  /// Screen titles.
  TextStyle get h1 => _reading(RaeedTypeScale.h1);

  /// Section headings.
  TextStyle get h2 => _reading(RaeedTypeScale.h2);

  /// Card titles — a child's name, a session title.
  TextStyle get h3 => _reading(RaeedTypeScale.h3);

  /// Body copy: announcements, session content, message bodies.
  TextStyle get body => _reading(RaeedTypeScale.body);

  /// Secondary body copy.
  TextStyle get bodySmall => _reading(RaeedTypeScale.bodySmall);

  /// A Quranic or hadith excerpt, inside Materials content only.
  ///
  /// Falls back to the ordinary reading face in Latin locales, where an
  /// Uthmanic face would be meaningless.
  TextStyle get quranicExcerpt => _isArabic
      ? _reading(RaeedTypeScale.body).copyWith(
          fontFamily: quranFamily,
          fontFamilyFallback: const [RaeedFonts.arabic],
        )
      : body;

  // --- Chrome styles (Public Sans) -----------------------------------------

  /// Button and primary-action labels.
  TextStyle get button => _chrome(RaeedTypeScale.bodySmall, weight: 600);

  /// Form field labels, tab labels.
  TextStyle get label => _chrome(RaeedTypeScale.bodySmall, weight: 500);

  /// Timestamps, counts, helper text.
  TextStyle get caption =>
      _chrome(RaeedTypeScale.caption, weight: RaeedTypeScale.caption.weight);

  /// Digits that line up in a column — attendance counts, dashboard stats,
  /// dates, durations.
  ///
  /// `tabularFigures` keeps a changing count from shifting the layout under
  /// the reader's eye, which on the attendance summary header happens on every
  /// tap.
  TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // --- Construction --------------------------------------------------------

  TextStyle _reading(RaeedTypeStep step) => TextStyle(
    fontFamily: readingFamily,
    fontFamilyFallback: _isArabic
        ? RaeedFonts.arabicFallback
        : RaeedFonts.latinDisplayFallback,
    fontSize: step.size,
    height: _isArabic ? step.lineHeightArabic : step.lineHeightLatin,
    fontWeight: _fontWeight(step.weight),
    fontVariations: _variations(readingFamily, step.weight),
    letterSpacing: step.letterSpacing,
  );

  TextStyle _chrome(RaeedTypeStep step, {required int weight}) => TextStyle(
    fontFamily: chromeFamily,
    fontFamilyFallback: RaeedFonts.uiSansFallback,
    fontSize: step.size,
    // Chrome is single-line far more often than body copy; the Arabic
    // leading that helps a paragraph makes a button needlessly tall.
    height: _isArabic ? step.lineHeightLatin + 0.1 : step.lineHeightLatin,
    fontWeight: _fontWeight(weight),
    fontVariations: _variations(chromeFamily, weight),
    letterSpacing: step.letterSpacing,
  );

  /// Amiri exists only at 400 and 700. Asking for 500 or 600 in Arabic yields
  /// a synthesised weight that looks wrong, so requests are snapped to the
  /// nearest real cut rather than faked.
  FontWeight _fontWeight(int weight) {
    final resolved =
        readingFamily == RaeedFonts.arabic && !_isChromeWeight(weight)
        ? (weight >= 550 ? 700 : 400)
        : weight;
    return FontWeight.values.firstWhere(
      (candidate) => candidate.value == _roundToHundred(resolved),
      orElse: () => FontWeight.w400,
    );
  }

  bool _isChromeWeight(int weight) => weight == 500 || weight == 600;

  int _roundToHundred(int weight) =>
      ((weight / 100).round() * 100).clamp(100, 900);

  /// Variable families need the `wght` axis set explicitly; static ones must
  /// not have it, or the engine logs a mismatch for an axis the font lacks.
  List<FontVariation>? _variations(String family, int weight) =>
      _variableFamilies.contains(family)
      ? [FontVariation('wght', weight.toDouble())]
      : null;

  static const Set<String> _variableFamilies = {
    RaeedFonts.latinDisplay,
    RaeedFonts.uiSans,
  };

  /// Projects this typography onto Material's `TextTheme`, so stock widgets
  /// that read `Theme.of(context).textTheme` are styled correctly too.
  TextTheme get materialTextTheme => TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: h1,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h2,
    titleLarge: h2,
    titleMedium: h3,
    titleSmall: h3,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: button,
    labelMedium: label,
    labelSmall: caption,
  );
}
