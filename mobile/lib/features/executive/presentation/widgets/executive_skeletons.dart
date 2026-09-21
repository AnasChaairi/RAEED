import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../../shared/widgets/skeleton.dart';

/// Skeleton rows shaped like a list of cards — never a bare spinner.
class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({this.count = 4, this.height = 64, super.key});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(RaeedSpacing.lg),
    itemCount: count,
    separatorBuilder: (_, _) => const SizedBox(height: RaeedSpacing.sm),
    itemBuilder: (_, _) => SkeletonCard(height: height),
  );
}

/// One skeleton card.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({this.height = 64, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: height,
      padding: const EdgeInsets.all(RaeedSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(RaeedRadius.xl),
        border: Border.all(color: palette.border),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 40, height: 40),
          SizedBox(width: RaeedSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(widthFactor: 0.6),
                SizedBox(height: RaeedSpacing.sm),
                SkeletonLine(widthFactor: 0.35, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
