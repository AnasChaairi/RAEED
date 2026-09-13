import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.gen.dart';
import '../../core/theme/raeed_theme.dart';

/// A shimmering placeholder block.
///
/// `specs/06-mobile-app-spec.md` is explicit that loading states are skeletons,
/// "never a bare spinner". The reason is not decoration: a parent opening the
/// app wants to know where their child is, and a skeleton that already has the
/// shape of the answer reads as "almost there" rather than "something is
/// happening somewhere".
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  });

  /// Width in logical pixels. Pass [double.infinity] to fill the parent.
  final double width;

  /// Height in logical pixels.
  final double height;

  /// Corner radius; defaults to [RaeedRadius.sm].
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Respects the platform's reduce-motion setting: a pulsing placeholder is
    // exactly the kind of repetitive animation that setting exists to stop.
    final animate = !MediaQuery.disableAnimationsOf(context);

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              palette.surfaceAlt,
              palette.border,
              animate ? _controller.value : 0.35,
            ),
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(RaeedRadius.sm),
          ),
        ),
      ),
    );
  }
}

/// A skeleton line of text, sized to the line height it stands in for.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({this.widthFactor = 1, this.height = 14, super.key});

  /// Fraction of the available width to occupy. Varying this across lines
  /// keeps a block of skeletons from looking like a solid slab.
  final double widthFactor;

  /// Height of the line.
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: AlignmentDirectional.centerStart,
    widthFactor: widthFactor,
    child: SkeletonBox(width: double.infinity, height: height),
  );
}
