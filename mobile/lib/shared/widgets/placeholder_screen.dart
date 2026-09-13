import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.gen.dart';
import '../../core/theme/raeed_theme.dart';

/// A stand-in for a route whose feature has not shipped yet.
///
/// The app shell (`RAEED-6`) wires every route in the routing table so that
/// deep links, guards and navigation can be tested end to end before the
/// screens exist. This makes the gap explicit rather than leaving a blank
/// page: an unimplemented screen should look unimplemented, not broken.
///
/// Each one is replaced by the real screen as its ticket lands.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.ticket,
    super.key,
  });

  /// The screen's name, for the app bar.
  final String title;

  /// The `RAEED-N` ticket that will replace this.
  final String ticket;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(RaeedSpacing.xl2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded, size: 36, color: palette.inkDim),
              const SizedBox(height: RaeedSpacing.lg),
              Text(
                title,
                style: context.type.h3.copyWith(color: palette.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: RaeedSpacing.sm),
              Text(
                ticket,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
