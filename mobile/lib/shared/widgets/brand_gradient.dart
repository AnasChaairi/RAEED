import 'dart:ui' as ui;

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
/// `mix-blend-mode: screen`. `Image.colorBlendMode` cannot do that — it
/// blends a colour *into* the image, so screening with black changes
/// nothing and the backdrop stays. The mark is instead painted straight
/// onto the gradient with [BlendMode.screen], so black pixels drop out and
/// the mark's own colours stay untouched, which is what the style guide
/// allows: the backdrop is "a presentation choice, not a mandate", the mark
/// itself is never recoloured. Only correct on a dark ground.
class BrandWordmark extends StatefulWidget {
  const BrandWordmark({this.width = 260, super.key});

  /// Rendered width. The guide sets a 32px floor, below which the Arabic
  /// wordmark's diacritics disappear.
  final double width;

  @override
  State<BrandWordmark> createState() => _BrandWordmarkState();
}

class _BrandWordmarkState extends State<BrandWordmark> {
  static const AssetImage _asset = AssetImage('assets/images/logo.jpeg');

  /// The source file's proportions, so the box holds its place before decode.
  static const double _aspectRatio = 666 / 375;

  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = _asset.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _detach();
    _stream = stream;
    _listener = ImageStreamListener((info, _) {
      if (mounted) setState(() => _image = info.image);
    });
    stream.addListener(_listener!);
  }

  void _detach() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'أكاديمية الطفل الرائد',
    image: true,
    child: SizedBox(
      width: widget.width,
      height: widget.width / _aspectRatio,
      child: _image == null
          ? null
          : CustomPaint(painter: _ScreenBlendPainter(_image!)),
    ),
  );
}

class _ScreenBlendPainter extends CustomPainter {
  const _ScreenBlendPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final paint = Paint()
      ..blendMode = BlendMode.screen
      ..filterQuality = FilterQuality.medium;
    canvas.drawImageRect(image, source, Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_ScreenBlendPainter oldDelegate) =>
      oldDelegate.image != image;
}
