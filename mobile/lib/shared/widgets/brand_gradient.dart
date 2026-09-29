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
      // Sign-in: the brand blue, opening toward the logo's own blue — never
      // darker than the header, so the mark reads on it instead of under it.
      BrandGradientVariant.signIn => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.primary,
          Color.lerp(palette.primary, RaeedLogoColors.blueAverage, 0.3)!,
        ],
      ),
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

  /// The sign-in band above the form card.
  signIn,
}

/// The RAEED wordmark, as the design places it on the sign-in gradient.
///
/// The source file has a black backdrop, which the design hides with
/// `mix-blend-mode: screen`. `Image.colorBlendMode` cannot do that — it
/// blends a colour *into* the image, so screening with black changes
/// nothing and the backdrop stays. The mark is instead painted straight
/// onto the gradient with [BlendMode.screen], so black pixels drop out and
/// the mark's own colours stay untouched, which is what the style guide
/// allows: the backdrop is "a presentation choice, not a mandate", the mark
/// itself is never recoloured. Only correct on a dark ground.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({this.width = 260, super.key});

  /// Rendered width. The guide sets a 32px floor, below which the Arabic
  /// wordmark's diacritics disappear.
  final double width;

  /// The mark with its black backdrop keyed out, so it sits on any brand
  /// surface with its own colours — the JPEG in `logo/` is the source.
  static const AssetImage asset = AssetImage(
    'assets/images/logo_transparent.png',
  );

  /// The source file's proportions, so the box holds its place before decode.
  static const double _aspectRatio = 666 / 375;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'أكاديمية الطفل الرائد',
    image: true,
    child: SizedBox(
      width: width,
      height: width / _aspectRatio,
      child: const Image(image: asset, fit: BoxFit.contain),
    ),
  );
}
