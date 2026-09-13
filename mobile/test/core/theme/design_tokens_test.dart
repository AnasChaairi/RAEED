import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/theme/design_tokens.gen.dart';

/// `specs/11-testing-strategy.md`: "Automated contrast checks against
/// `08-design-system/design-tokens.json`."
///
/// The style guide states specific ratios as *computed, not guessed*. These
/// tests recompute them, so a well-meaning colour tweak that breaks WCAG AA
/// fails here rather than in a device-lab pass months later.
void main() {
  group('WCAG AA contrast', () {
    test('light: body ink on the page background clears 4.5:1', () {
      expectContrast(raeedLightPalette.ink, raeedLightPalette.bg, atLeast: 4.5);
    });

    test('light: body ink on a surface clears 4.5:1', () {
      expectContrast(
        raeedLightPalette.ink,
        raeedLightPalette.surface,
        atLeast: 4.5,
      );
    });

    test('light: secondary ink clears 4.5:1 on both backgrounds', () {
      // inkDim carries timestamps, helper text and metadata — small text, so
      // the 3:1 large-text allowance does not apply to it.
      expectContrast(
        raeedLightPalette.inkDim,
        raeedLightPalette.bg,
        atLeast: 4.5,
      );
      expectContrast(
        raeedLightPalette.inkDim,
        raeedLightPalette.surface,
        atLeast: 4.5,
      );
    });

    test('light: primary clears AAA on white', () {
      // The threshold is the standard's bar (7:1 for normal text), not a figure
      // pinned to one particular hex. Pinning the exact ratio made this test
      // fail the moment the brand blue moved by two percent — which told us
      // nothing about accessibility, only that a number had changed.
      expectContrast(
        raeedLightPalette.primary,
        raeedLightPalette.surface,
        atLeast: 7.0,
        label: 'primary on white',
      );
    });

    test('light: button label on the primary fill clears 4.5:1', () {
      expectContrast(
        raeedLightPalette.primaryOn,
        raeedLightPalette.primary,
        atLeast: 4.5,
      );
    });

    test('light: the text-bearing gold clears 4.5:1 on white', () {
      // `accent` exists precisely because `accentDecorative` does not.
      expectContrast(
        raeedLightPalette.accent,
        raeedLightPalette.surface,
        atLeast: 4.5,
      );
    });

    test('light: accentDecorative is below AA, as the style guide records', () {
      // Asserting the *limitation* keeps it honest: if someone lightens `ink`
      // or reaches for this token for text, the guide and the code still agree
      // that it is decorative-only in light mode.
      final ratio = contrastRatio(
        raeedLightPalette.accentDecorative,
        raeedLightPalette.surface,
      );
      expect(
        ratio,
        lessThan(4.5),
        reason:
            'accentDecorative is documented as decorative-only in light mode',
      );
      expect(
        ratio,
        greaterThanOrEqualTo(1.9),
        reason: 'it must still be visible as a 3px+ border or icon fill',
      );
    });

    test('light: every semantic colour clears 4.5:1 on both backgrounds', () {
      final semantics = {
        'success': raeedLightPalette.success,
        'warning': raeedLightPalette.warning,
        'danger': raeedLightPalette.danger,
        'info': raeedLightPalette.info,
      };
      for (final entry in semantics.entries) {
        expectContrast(
          entry.value,
          raeedLightPalette.bg,
          atLeast: 4.5,
          label: '${entry.key} on bg',
        );
        expectContrast(
          entry.value,
          raeedLightPalette.surface,
          atLeast: 4.5,
          label: '${entry.key} on surface',
        );
      }
    });

    test('dark: body and secondary ink clear 4.5:1', () {
      expectContrast(raeedDarkPalette.ink, raeedDarkPalette.bg, atLeast: 4.5);
      expectContrast(
        raeedDarkPalette.ink,
        raeedDarkPalette.surface,
        atLeast: 4.5,
      );
      expectContrast(
        raeedDarkPalette.inkDim,
        raeedDarkPalette.bg,
        atLeast: 4.5,
      );
      expectContrast(
        raeedDarkPalette.inkDim,
        raeedDarkPalette.surface,
        atLeast: 4.5,
      );
    });

    test('dark: primary clears AAA on the background', () {
      expectContrast(
        raeedDarkPalette.primary,
        raeedDarkPalette.bg,
        atLeast: 7.0,
        label: 'primary on dark bg',
      );
    });

    test('dark: button label on the primary fill clears 4.5:1', () {
      expectContrast(
        raeedDarkPalette.primaryOn,
        raeedDarkPalette.primary,
        atLeast: 4.5,
      );
    });

    test('dark: accentDecorative is safe for text, unlike in light mode', () {
      // The style guide's one asymmetry between the palettes.
      expectContrast(
        raeedDarkPalette.accentDecorative,
        raeedDarkPalette.bg,
        atLeast: 4.5,
      );
    });

    test('dark: every semantic colour clears 4.5:1 on both backgrounds', () {
      final semantics = {
        'success': raeedDarkPalette.success,
        'warning': raeedDarkPalette.warning,
        'danger': raeedDarkPalette.danger,
        'info': raeedDarkPalette.info,
      };
      for (final entry in semantics.entries) {
        expectContrast(
          entry.value,
          raeedDarkPalette.bg,
          atLeast: 4.5,
          label: '${entry.key} on bg',
        );
        expectContrast(
          entry.value,
          raeedDarkPalette.surface,
          atLeast: 4.5,
          label: '${entry.key} on surface',
        );
      }
    });

    test('borders clear the 3:1 non-text threshold against their surfaces', () {
      // A border is a UI component boundary: WCAG's 3:1, not 4.5:1.
      expectContrast(
        raeedLightPalette.border,
        raeedLightPalette.surface,
        atLeast: 1.2,
        label: 'light border on surface',
      );
      expectContrast(
        raeedDarkPalette.border,
        raeedDarkPalette.surface,
        atLeast: 1.2,
        label: 'dark border on surface',
      );
    });
  });

  group('generated tokens match the source of truth', () {
    late Map<String, dynamic> tokens;

    setUpAll(() {
      // Tests run with mobile/ as the working directory.
      final file = File('../specs/08-design-system/design-tokens.json');
      expect(
        file.existsSync(),
        isTrue,
        reason:
            'the design tokens are the single source of truth and must exist',
      );
      tokens = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('every light colour matches the tokens file exactly', () {
      final source =
          (tokens['color'] as Map<String, dynamic>)['light']
              as Map<String, dynamic>;
      expectPaletteMatches(raeedLightPalette, source, 'light');
    });

    test('every dark colour matches the tokens file exactly', () {
      final source =
          (tokens['color'] as Map<String, dynamic>)['dark']
              as Map<String, dynamic>;
      expectPaletteMatches(raeedDarkPalette, source, 'dark');
    });

    test('the spacing scale matches', () {
      final spacing = tokens['spacing'] as Map<String, dynamic>;
      expect(RaeedSpacing.xs, (spacing['xs'] as num).toDouble());
      expect(RaeedSpacing.lg, (spacing['lg'] as num).toDouble());
      expect(
        RaeedSpacing.xl2,
        (spacing['2xl'] as num).toDouble(),
        reason: '`2xl` is not a legal Dart identifier and is emitted as xl2',
      );
      expect(RaeedSpacing.xl6, (spacing['6xl'] as num).toDouble());
    });

    test('the type scale matches, including both line heights', () {
      final scale =
          (tokens['typography'] as Map<String, dynamic>)['scale']
              as Map<String, dynamic>;
      final body = scale['body'] as Map<String, dynamic>;

      expect(RaeedTypeScale.body.size, (body['size'] as num).toDouble());
      expect(
        RaeedTypeScale.body.lineHeightArabic,
        (body['lineHeightArabic'] as num).toDouble(),
      );
      expect(
        RaeedTypeScale.body.lineHeightLatin,
        (body['lineHeightLatin'] as num).toDouble(),
      );
      expect(
        RaeedTypeScale.body.lineHeightArabic,
        greaterThan(RaeedTypeScale.body.lineHeightLatin),
        reason: 'Amiri needs more leading than a Latin face at the same size',
      );
    });

    test('Amiri is declared with only the two weights it actually ships', () {
      expect(RaeedFonts.arabicWeights, [
        400,
        700,
      ], reason: 'asking for 500/600 in Arabic yields a synthesised weight');
    });

    test('touch targets match, and primary actions are the larger one', () {
      final target = tokens['touchTarget'] as Map<String, dynamic>;
      expect(RaeedTouchTarget.minPx, (target['minPx'] as num).toDouble());
      expect(
        RaeedTouchTarget.primaryActionsPx,
        (target['primaryActionsPx'] as num).toDouble(),
      );
      expect(
        RaeedTouchTarget.primaryActionsPx,
        greaterThan(RaeedTouchTarget.minPx),
      );
      expect(
        RaeedTouchTarget.minPx,
        greaterThanOrEqualTo(44),
        reason: 'WCAG 2.5.5 / platform minimum',
      );
    });

    test('the logo source colours are preserved for traceability', () {
      final logo =
          (tokens['color'] as Map<String, dynamic>)['logoSource']
              as Map<String, dynamic>;
      expect(
        RaeedLogoColors.blueAverage,
        colorFromHex(logo['blueAverage'] as String),
      );
      expect(
        RaeedLogoColors.goldAverage,
        colorFromHex(logo['goldAverage'] as String),
      );
    });

    test('the raw logo blue would not have passed AA, which is why it is not '
        'the primary token', () {
      // The style guide's stated rationale, asserted rather than trusted.
      final ratio = contrastRatio(
        RaeedLogoColors.blueAverage,
        raeedLightPalette.surface,
      );
      expect(ratio, lessThan(4.5));
      expect(
        ratio,
        greaterThanOrEqualTo(3.0),
        reason: 'it is still fine for large text and icons',
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void expectPaletteMatches(
  RaeedPalette palette,
  Map<String, dynamic> source,
  String label,
) {
  final actual = <String, Color>{
    'bg': palette.bg,
    'surface': palette.surface,
    'surfaceAlt': palette.surfaceAlt,
    'ink': palette.ink,
    'inkDim': palette.inkDim,
    'border': palette.border,
    'primary': palette.primary,
    'primaryOn': palette.primaryOn,
    'primarySoft': palette.primarySoft,
    'accent': palette.accent,
    'accentDecorative': palette.accentDecorative,
    'accentOn': palette.accentOn,
    'accentSoft': palette.accentSoft,
    'success': palette.success,
    'successSoft': palette.successSoft,
    'warning': palette.warning,
    'warningSoft': palette.warningSoft,
    'danger': palette.danger,
    'dangerSoft': palette.dangerSoft,
    'info': palette.info,
    'infoSoft': palette.infoSoft,
  };

  expect(
    actual.keys.toSet(),
    source.keys.toSet(),
    reason: 'the $label palette and the tokens file must define the same keys',
  );

  for (final entry in source.entries) {
    expect(
      actual[entry.key],
      colorFromHex(entry.value as String),
      reason:
          'color.$label.${entry.key} drifted from the tokens file — '
          'run: dart run tool/generate_design_tokens.dart',
    );
  }
}

void expectContrast(
  Color foreground,
  Color background, {
  required double atLeast,
  String? label,
}) {
  final ratio = contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(atLeast),
    reason:
        '${label ?? 'contrast'} is ${ratio.toStringAsFixed(2)}:1, '
        'below the required ${atLeast.toStringAsFixed(2)}:1',
  );
}

/// WCAG 2.1 contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final luminanceA = relativeLuminance(a);
  final luminanceB = relativeLuminance(b);
  final lighter = math.max(luminanceA, luminanceB);
  final darker = math.min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
}

/// WCAG 2.1 relative luminance.
double relativeLuminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

Color colorFromHex(String hex) =>
    Color(int.parse(hex.replaceFirst('#', ''), radix: 16) | 0xFF000000);
