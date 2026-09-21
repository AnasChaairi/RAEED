import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// A flat card on `surface` with a `border` — the design's one card.
///
/// Separation comes from the border and the ground shift, never a shadow
/// (`specs/08-design-system/`). Tappable when [onTap] is set.
class ExecutiveCard extends StatelessWidget {
  const ExecutiveCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RaeedSpacing.lg),
    this.radius = RaeedRadius.xl,
    this.borderColor,
    this.borderWidth = 1,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final card = Material(
      color: color ?? palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: borderColor ?? palette.border,
          width: borderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    if (semanticLabel == null) return card;
    return Semantics(button: onTap != null, label: semanticLabel, child: card);
  }
}
