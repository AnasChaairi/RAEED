import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// A thumbnail fetched through the authenticated client: media is never a
/// public URL, so `Image.network` would get a 401.
class MediaThumbnail extends ConsumerWidget {
  const MediaThumbnail({
    required this.url,
    this.size = 60,
    this.onRemove,
    super.key,
  });

  /// The `/api/v1/media/…` path the server returned.
  final String url;
  final double size;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
      ),
      child: Icon(Icons.image_outlined, color: palette.inkDim),
    );
    final path = url.startsWith('/api/v1')
        ? url.substring('/api/v1'.length)
        : url;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FutureBuilder<List<int>>(
          future: ref.read(apiClientProvider).getBytes(path),
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (bytes == null || bytes.isEmpty) return placeholder;
            return ClipRRect(
              borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
              child: Image.memory(
                Uint8List.fromList(bytes),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
            );
          },
        ),
        if (onRemove != null)
          PositionedDirectional(
            top: -6,
            end: -6,
            child: Material(
              color: palette.ink,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: palette.surface,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
