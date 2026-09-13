// Generates `lib/core/theme/design_tokens.gen.dart` from the single source of
// truth for every colour, type and spacing value in RAEED:
// `specs/08-design-system/design-tokens.json`.
//
// The specs are explicit that hex codes and font names are never hand-copied
// into app code (`specs/README.md`, "Ground rules while building from these
// specs"). Run this after editing the tokens file:
//
//     dart run tool/generate_design_tokens.dart
//
// The generated file is committed so a plain `flutter test` needs no codegen
// step; CI re-runs this and fails if the output drifts from the tokens.
import 'dart:convert';
import 'dart:io';

const _tokensPath = '../specs/08-design-system/design-tokens.json';
const _outputPath = 'lib/core/theme/design_tokens.gen.dart';

void main(List<String> args) {
  final tokensFile = File(_tokensPath);
  if (!tokensFile.existsSync()) {
    stderr.writeln(
      'Design tokens not found at $_tokensPath — run this from mobile/.',
    );
    exitCode = 2;
    return;
  }

  final tokens =
      jsonDecode(tokensFile.readAsStringSync()) as Map<String, dynamic>;
  final generated = _Generator(tokens).build();

  final outFile = File(_outputPath);
  final isCheck = args.contains('--check');
  if (isCheck) {
    final current = outFile.existsSync() ? outFile.readAsStringSync() : '';
    if (current != generated) {
      stderr.writeln(
        '$_outputPath is stale. Run: dart run tool/generate_design_tokens.dart',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln('$_outputPath is up to date.');
    return;
  }

  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(generated);
  stdout.writeln('Wrote $_outputPath');
}

class _Generator {
  _Generator(this.tokens);

  final Map<String, dynamic> tokens;
  final StringBuffer _out = StringBuffer();

  Map<String, dynamic> get _color => tokens['color'] as Map<String, dynamic>;
  Map<String, dynamic> get _typography =>
      tokens['typography'] as Map<String, dynamic>;

  String build() {
    _writeHeader();
    _writeColorPalette();
    _writeLogoSource();
    _writeFontFamilies();
    _writeTypeScale();
    _writeSpacing();
    _writeRadius();
    _writeElevation();
    _writeTouchTarget();
    return _out.toString();
  }

  void _writeHeader() {
    _out
      ..writeln('// GENERATED — DO NOT EDIT BY HAND.')
      ..writeln('//')
      ..writeln('// Source: specs/08-design-system/design-tokens.json')
      ..writeln('// Regenerate: dart run tool/generate_design_tokens.dart')
      ..writeln('//')
      ..writeln(
        '// Rationale for every value here lives in'
        ' specs/08-design-system/style-guide.md —',
      )
      ..writeln(
        '// notably why the logo\'s raw blue is not the `primary` token'
        ' (it only reaches',
      )
      ..writeln('// 3.97:1 on white, short of WCAG AA for body text).')
      ..writeln()
      // painting, not dart:ui — dart:ui has Shadow but not BoxShadow, and the
      // elevation tokens are box shadows.
      ..writeln('import \'package:flutter/painting.dart\';')
      ..writeln()
      ..writeln(
        '/// A semantic colour palette, one instance per theme'
        ' brightness.',
      )
      ..writeln('///')
      ..writeln(
        '/// Widgets never reference these directly — they read them'
        ' through the',
      )
      ..writeln(
        '/// `RaeedTheme` extension on `BuildContext`, so a widget'
        ' cannot accidentally',
      )
      ..writeln('/// hardcode the light palette into a dark-mode screen.')
      ..writeln('class RaeedPalette {')
      ..writeln('  const RaeedPalette({');
    for (final name in _paletteKeys) {
      _out.writeln('    required this.$name,');
    }
    _out.writeln('  });');
    _out.writeln();
    for (final name in _paletteKeys) {
      _out.writeln('  /// `color.<brightness>.$name`');
      _out.writeln('  final Color $name;');
    }
    _out
      ..writeln('}')
      ..writeln();
  }

  List<String> get _paletteKeys =>
      (_color['light'] as Map<String, dynamic>).keys.toList();

  void _writeColorPalette() {
    for (final brightness in const ['light', 'dark']) {
      final values = _color[brightness] as Map<String, dynamic>;
      _out
        ..writeln('/// The $brightness-mode palette.')
        ..writeln(
          'const RaeedPalette raeed${_capitalize(brightness)}Palette ='
          ' RaeedPalette(',
        );
      for (final entry in values.entries) {
        _out.writeln('  ${entry.key}: ${_color32(entry.value as String)},');
      }
      _out
        ..writeln(');')
        ..writeln();
    }
  }

  void _writeLogoSource() {
    final logo = _color['logoSource'] as Map<String, dynamic>;
    _out
      ..writeln('/// Raw colours sampled from `logo/logo.jpeg`.')
      ..writeln('///')
      ..writeln('/// ${logo['note']}')
      ..writeln('///')
      ..writeln(
        '/// Use these only inside logo lockups and the brand gradient.'
        ' For anything',
      )
      ..writeln(
        '/// bearing text, reach for [RaeedPalette] instead — these raw'
        ' values do not',
      )
      ..writeln('/// all meet WCAG AA.')
      ..writeln('abstract final class RaeedLogoColors {');
    for (final entry in logo.entries) {
      if (entry.key == 'note') continue;
      _out.writeln(
        '  static const Color ${entry.key} = ${_color32(entry.value as String)};',
      );
    }
    _out
      ..writeln('}')
      ..writeln();
  }

  void _writeFontFamilies() {
    final families = _typography['fontFamily'] as Map<String, dynamic>;
    _out
      ..writeln('/// Font families, with their fallback chains.')
      ..writeln('///')
      ..writeln('/// ${_typography['note']}')
      ..writeln('abstract final class RaeedFonts {');
    for (final entry in families.entries) {
      final chain = _parseFontChain(entry.value as String);
      _out
        ..writeln('  /// `typography.fontFamily.${entry.key}`')
        ..writeln("  static const String ${entry.key} = '${chain.first}';")
        ..writeln(
          '  static const List<String> ${entry.key}Fallback = '
          '<String>[${chain.skip(1).map((f) => "'$f'").join(', ')}];',
        );
    }
    final weights = (_typography['arabicWeights'] as List<dynamic>).cast<int>();
    _out
      ..writeln()
      ..writeln(
        '  /// Amiri ships only these weights — build Arabic hierarchy'
        ' with size,',
      )
      ..writeln(
        '  /// colour and spacing, never an intermediate weight that'
        ' does not exist.',
      )
      ..writeln(
        '  static const List<int> arabicWeights = '
        '<int>[${weights.join(', ')}];',
      )
      ..writeln('}')
      ..writeln();
  }

  void _writeTypeScale() {
    final scale = _typography['scale'] as Map<String, dynamic>;
    _out
      ..writeln('/// One step of the type scale.')
      ..writeln('///')
      ..writeln(
        '/// Arabic and Latin carry different line heights on purpose:'
        ' Amiri needs',
      )
      ..writeln(
        '/// markedly more leading than a Latin face at the same size'
        ' for its',
      )
      ..writeln('/// diacritics to breathe.')
      ..writeln('class RaeedTypeStep {')
      ..writeln('  const RaeedTypeStep({')
      ..writeln('    required this.size,')
      ..writeln('    required this.lineHeightArabic,')
      ..writeln('    required this.lineHeightLatin,')
      ..writeln('    required this.weight,')
      ..writeln('    this.letterSpacingEm,')
      ..writeln('  });')
      ..writeln()
      ..writeln('  /// Font size in logical pixels, before text scaling.')
      ..writeln('  final double size;')
      ..writeln()
      ..writeln('  /// Line height multiple used when the script is Arabic.')
      ..writeln('  final double lineHeightArabic;')
      ..writeln()
      ..writeln('  /// Line height multiple used when the script is Latin.')
      ..writeln('  final double lineHeightLatin;')
      ..writeln()
      ..writeln('  /// CSS-style numeric weight (400/500/700).')
      ..writeln('  final int weight;')
      ..writeln()
      ..writeln(
        '  /// Letter spacing expressed in em, as the tokens file'
        ' records it.',
      )
      ..writeln('  final double? letterSpacingEm;')
      ..writeln()
      ..writeln('  /// Letter spacing in logical pixels at [size].')
      ..writeln('  double? get letterSpacing =>')
      ..writeln(
        '      letterSpacingEm == null ? null : letterSpacingEm! *'
        ' size;',
      )
      ..writeln('}')
      ..writeln()
      ..writeln('/// `typography.scale` — the only sanctioned font sizes.')
      ..writeln('abstract final class RaeedTypeScale {');
    for (final entry in scale.entries) {
      final step = entry.value as Map<String, dynamic>;
      _out
        ..writeln('  static const RaeedTypeStep ${entry.key} = RaeedTypeStep(')
        ..writeln('    size: ${_double(step['size'])},')
        ..writeln('    lineHeightArabic: ${_double(step['lineHeightArabic'])},')
        ..writeln('    lineHeightLatin: ${_double(step['lineHeightLatin'])},')
        ..writeln('    weight: ${step['weight']},');
      if (step.containsKey('letterSpacing')) {
        _out.writeln('    letterSpacingEm: ${_double(step['letterSpacing'])},');
      }
      _out.writeln('  );');
    }
    _out
      ..writeln('}')
      ..writeln();
  }

  void _writeSpacing() {
    final spacing = tokens['spacing'] as Map<String, dynamic>;
    _out
      ..writeln(
        '/// `spacing` — the 4pt scale every gap and padding comes'
        ' from.',
      )
      ..writeln('abstract final class RaeedSpacing {');
    for (final entry in spacing.entries) {
      _out.writeln(
        '  static const double ${_dartIdentifier(entry.key)} = '
        '${_double(entry.value)};',
      );
    }
    _out
      ..writeln('}')
      ..writeln();
  }

  void _writeRadius() {
    final radius = tokens['radius'] as Map<String, dynamic>;
    _out
      ..writeln(
        '/// `radius` — corner radii. [pill] is an arbitrary large'
        ' value that',
      )
      ..writeln('/// reads as fully rounded at any realistic control height.')
      ..writeln('abstract final class RaeedRadius {');
    for (final entry in radius.entries) {
      _out.writeln(
        '  static const double ${_dartIdentifier(entry.key)} = '
        '${_double(entry.value)};',
      );
    }
    _out
      ..writeln('}')
      ..writeln();
  }

  void _writeElevation() {
    final elevation = tokens['elevation'] as Map<String, dynamic>;
    _out
      ..writeln(
        '/// `elevation` — shadows, translated from the tokens file\'s'
        ' CSS notation.',
      )
      ..writeln('abstract final class RaeedElevation {');
    for (final brightness in elevation.keys) {
      final steps = elevation[brightness] as Map<String, dynamic>;
      for (final step in steps.entries) {
        final name = '$brightness${_capitalize(step.key)}';
        final shadows = _parseBoxShadows(step.value as String);
        _out
          ..writeln('  static const List<BoxShadow> $name = <BoxShadow>[')
          ..writeln(shadows.map((s) => '    $s,').join('\n'))
          ..writeln('  ];');
      }
    }
    _out
      ..writeln('}')
      ..writeln();
  }

  void _writeTouchTarget() {
    final target = tokens['touchTarget'] as Map<String, dynamic>;
    _out
      ..writeln('/// `touchTarget` — minimum hit areas.')
      ..writeln('///')
      ..writeln(
        '/// [minPx] is the floor for any tappable control;'
        ' [primaryActionsPx] applies',
      )
      ..writeln(
        '/// to primary actions, which on the attendance screen are'
        ' tapped repeatedly,',
      )
      ..writeln('/// at speed, often one-handed.')
      ..writeln('abstract final class RaeedTouchTarget {');
    for (final entry in target.entries) {
      _out.writeln(
        '  static const double ${entry.key} = ${_double(entry.value)};',
      );
    }
    _out.writeln('}');
  }
}

// ---------------------------------------------------------------------------
// Parsing helpers
// ---------------------------------------------------------------------------

/// `#RRGGBB` -> a `Color(0xAARRGGBB)` literal.
String _color32(String hex) {
  final cleaned = hex.replaceFirst('#', '').toUpperCase();
  if (cleaned.length != 6) {
    throw FormatException('Expected a 6-digit hex colour, got "$hex"');
  }
  return 'Color(0xFF$cleaned)';
}

/// Splits a CSS font stack into its individual family names.
List<String> _parseFontChain(String value) => value
    .split(',')
    .map((part) => part.trim().replaceAll("'", '').replaceAll('"', ''))
    .where((part) => part.isNotEmpty)
    .toList();

/// Renders an int or double token as a Dart double literal.
String _double(Object? value) {
  final number = (value as num).toDouble();
  return number == number.roundToDouble()
      ? number.toStringAsFixed(1)
      : '$number';
}

/// Maps a token key that is not a valid Dart identifier (`2xl`) onto one
/// (`xl2`), leaving valid keys untouched.
String _dartIdentifier(String key) {
  if (!RegExp(r'^[0-9]').hasMatch(key)) return key;
  final match = RegExp(r'^([0-9]+)(.*)$').firstMatch(key)!;
  return '${match.group(2)}${match.group(1)}';
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

/// Translates a CSS `box-shadow` list into Dart `BoxShadow` constructor calls.
///
/// Handles the `<x> <y> <blur> [<spread>] rgba(r,g,b,a)` form the tokens file
/// uses. Anything else throws rather than silently producing a wrong shadow.
List<String> _parseBoxShadows(String css) {
  final shadows = <String>[];
  for (final raw in _splitTopLevel(css)) {
    final rgbaMatch = RegExp(
      r'rgba\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]*)\s*\)',
    ).firstMatch(raw);
    if (rgbaMatch == null) {
      throw FormatException('Unsupported shadow colour in "$raw"');
    }
    final r = int.parse(rgbaMatch.group(1)!);
    final g = int.parse(rgbaMatch.group(2)!);
    final b = int.parse(rgbaMatch.group(3)!);
    final alphaText = rgbaMatch.group(4)!;
    final alpha = double.parse(
      alphaText.startsWith('.') ? '0$alphaText' : alphaText,
    );

    final lengths = raw
        .substring(0, rgbaMatch.start)
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => double.parse(part.replaceAll('px', '')))
        .toList();
    if (lengths.length < 3 || lengths.length > 4) {
      throw FormatException('Expected 3 or 4 lengths in shadow "$raw"');
    }

    final spread = lengths.length == 4 ? lengths[3] : 0.0;
    final color =
        'Color(0x${_alphaHex(alpha)}'
        '${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()})';
    shadows.add(
      'BoxShadow('
      'color: $color, '
      'offset: Offset(${_double(lengths[0])}, ${_double(lengths[1])}), '
      'blurRadius: ${_double(lengths[2])}, '
      'spreadRadius: ${_double(spread)})',
    );
  }
  return shadows;
}

String _alphaHex(double alpha) => (alpha * 255)
    .round()
    .clamp(0, 255)
    .toRadixString(16)
    .padLeft(2, '0')
    .toUpperCase();

/// Splits a comma-separated CSS value, ignoring commas inside `rgba(...)`.
List<String> _splitTopLevel(String value) {
  final parts = <String>[];
  final buffer = StringBuffer();
  var depth = 0;
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    if (char == '(') depth++;
    if (char == ')') depth--;
    if (char == ',' && depth == 0) {
      parts.add(buffer.toString().trim());
      buffer.clear();
      continue;
    }
    buffer.write(char);
  }
  if (buffer.isNotEmpty) parts.add(buffer.toString().trim());
  return parts;
}
