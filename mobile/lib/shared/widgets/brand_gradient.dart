import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.gen.dart';
import '../../core/theme/raeed_theme.dart';

/// The brand gradient the design uses behind sign-in and the home header.
///
/// Built from the palette rather than from literal hexes, so it moves with the
/// tokens like everything else. The design draws it from the deep end of the
/// logo's blue through to the bright cyan at the other end — which is exactly
/// what `primary` (light) and `primary` (dark) already are, the two ends of the
/// same gradient the logo itself uses.
class BrandGradient extends StatelessWidget {
  const BrandGradient({
    required this.child,
    this.borderRadius,
    this.variant = BrandGradientVariant.header,
    super.key,
  });

  /// Content drawn on top of the gradient.
  final Widget child;

  /// Rounded corners, for the home header's curved bottom edge.
  final BorderRadius? borderRadius;

  /// Which of the design's two gradient treatments to use.
  final BrandGradientVariant variant;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      gradient: gradientFor(context, variant),
    ),
    child: child,
  );

  /// The gradient itself, for callers that need it on their own decoration.
  static LinearGradient gradientFor(
    BuildContext context,
    BrandGradientVariant variant,
  ) {
    final palette = context.palette;

    return switch (variant) {
      // Sign-in: nearly black at the top so the logo's own dark backdrop
      // blends into it, opening up through the brand blue.
      BrandGradientVariant.immersive => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(palette.ink, RaeedLogoColors.blueDark, 0.35)!,
          palette.primary,
          Color.lerp(palette.primary, raeedDarkPalette.primary, 0.45)!,
        ],
        stops: const [0, 0.46, 1],
      ),
      // The home header: a shorter, brighter sweep under the greeting.
      BrandGradientVariant.header => LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          palette.primary,
          Color.lerp(palette.primary, raeedDarkPalette.primary, 0.35)!,
          Color.lerp(palette.primary, raeedDarkPalette.primary, 0.55)!,
        ],
        stops: const [0, 0.6, 1],
      ),
    };
  }
}

/// Which gradient treatment a surface uses.
enum BrandGradientVariant {
  /// Full-screen, dark at the top — sign-in.
  immersive,

  /// A header band under a status bar.
  header,
}

/// The RAEED wordmark, as the design places it on the sign-in gradient.
///
/// The source file has a black backdrop, which the design hides with
/// `mix-blend-mode: screen`. Flutter's equivalent is [BlendMode.screen] on the
/// image itself: on a dark ground the black pixels drop out and only the mark
/// shows. The style guide allows exactly this — the backdrop is "a presentation
/// choice, not a mandate" — while forbidding recolouring the mark, which screen
/// blending does not do.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({this.width = 260, super.key});

  /// Rendered width. The guide sets a 32px floor, below which the Arabic
  /// wordmark's diacritics disappear.
  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'أكاديمية الطفل الرائد',
    image: true,
    child: Image.asset(
      'assets/images/logo.jpeg',
      width: width,
      fit: BoxFit.contain,
      // Only correct on a dark ground; on a light surface use the mark
      // unblended against `surface`.
      colorBlendMode: BlendMode.screen,
      color: const Color(0xFF000000),
      excludeFromSemantics: true,
    ),
  );
}
