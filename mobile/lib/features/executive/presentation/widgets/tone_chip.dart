import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// The colour role a chip takes. Names the meaning, never the colour.
enum ChipTone { success, danger, warning, info, accent, neutral, primary }

/// Icon + word on a `*Soft` ground — the status and severity chip the brief
/// specifies once and reuses everywhere.
///
/// Never colour alone: every chip carries an icon or a word as well, so it
/// survives a colour-blind reader and a greyscale printout.
class ToneChip extends StatelessWidget {
  const ToneChip({
    required this.label,
    required this.tone,
    this.icon,
    this.outlined = false,
    this.onSurface = false,
    super.key,
  });

  final String label;
  final ChipTone tone;
  final IconData? icon;

  /// Outlines the chip in its foreground colour — the escalated form.
  final bool outlined;

  /// Puts the chip on `surface` rather than the soft tint, for chips that sit
  /// on an already-tinted card.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    final colors = colorsFor(context, tone);

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.sm + 1,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: onSurface ? context.palette.surface : colors.background,
          borderRadius: BorderRadius.circular(RaeedRadius.pill),
          border: outlined ? Border.all(color: colors.foreground) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: colors.foreground),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The pair of colours [tone] maps to on the current palette.
  static ToneColors colorsFor(BuildContext context, ChipTone tone) {
    final palette = context.palette;
    return switch (tone) {
      ChipTone.success => ToneColors(palette.successSoft, palette.success),
      ChipTone.danger => ToneColors(palette.dangerSoft, palette.danger),
      ChipTone.warning => ToneColors(palette.warningSoft, palette.warning),
      ChipTone.info => ToneColors(palette.infoSoft, palette.info),
      ChipTone.accent => ToneColors(palette.accentSoft, palette.accent),
      ChipTone.primary => ToneColors(palette.primarySoft, palette.primary),
      ChipTone.neutral => ToneColors(palette.surfaceAlt, palette.inkDim),
    };
  }
}

/// A soft ground and the foreground that reads on it.
class ToneColors {
  const ToneColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}
