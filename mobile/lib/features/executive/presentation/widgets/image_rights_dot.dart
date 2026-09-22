import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/executive_child.dart' show ImageRightsLevel;

/// The three-level image-rights indicator as a small dot: colour, icon and
/// a spoken label, never colour alone.
class ImageRightsDot extends StatelessWidget {
  const ImageRightsDot({required this.level, this.size = 22, super.key});

  final ImageRightsLevel level;
  final double size;

  static String label(AppL10n l10n, ImageRightsLevel level) => switch (level) {
    ImageRightsLevel.allowed => l10n.imageRightsAllowed,
    ImageRightsLevel.appOnly => l10n.imageRightsAppOnly,
    ImageRightsLevel.notAllowed => l10n.imageRightsNotAllowed,
  };

  static IconData icon(ImageRightsLevel level) => switch (level) {
    ImageRightsLevel.allowed => Icons.circle,
    ImageRightsLevel.appOnly => Icons.contrast_rounded,
    ImageRightsLevel.notAllowed => Icons.block_rounded,
  };

  static Color color(BuildContext context, ImageRightsLevel level) =>
      switch (level) {
        ImageRightsLevel.allowed => context.palette.success,
        ImageRightsLevel.appOnly => context.palette.info,
        ImageRightsLevel.notAllowed => context.palette.danger,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Semantics(
      label: l10n.imageRightsLabel(label(l10n, level)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color(context, level),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon(level),
          size: size * 0.5,
          color: context.palette.surface,
        ),
      ),
    );
  }
}

/// The legend under a list carrying dots.
class ImageRightsLegend extends StatelessWidget {
  const ImageRightsLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    Widget item(ImageRightsLevel level) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ImageRightsDot.icon(level),
          size: 12,
          color: ImageRightsDot.color(context, level),
        ),
        const SizedBox(width: 4),
        Text(
          ImageRightsDot.label(l10n, level),
          style: context.type.caption.copyWith(
            color: ImageRightsDot.color(context, level),
          ),
        ),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(
          l10n.imageRightsLegend,
          style: context.type.caption.copyWith(color: palette.inkDim),
        ),
        item(ImageRightsLevel.allowed),
        item(ImageRightsLevel.appOnly),
        item(ImageRightsLevel.notAllowed),
      ],
    );
  }
}
