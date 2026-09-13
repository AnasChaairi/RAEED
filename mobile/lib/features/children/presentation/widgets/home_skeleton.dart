import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../../shared/widgets/skeleton.dart';

/// Skeleton child cards.
///
/// `specs/06-mobile-app-spec.md` for Parent Home: "Skeleton child cards — never
/// a bare spinner." The skeleton mirrors the real card's layout — avatar, name,
/// subtitle, pill — so the screen does not visibly rearrange itself when the
/// data lands.
///
/// Three cards, because the association's families typically have one to three
/// children enrolled: enough to fill the screen, not so many that the arrival
/// of a single real card looks like a loss.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({this.cardCount = 3, super.key});

  /// How many placeholder cards to show.
  final int cardCount;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(RaeedSpacing.lg),
    itemCount: cardCount,
    separatorBuilder: (_, _) => const SizedBox(height: RaeedSpacing.md),
    itemBuilder: (_, _) => const _SkeletonCard(),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(RaeedRadius.md),
              ),
              const SizedBox(width: RaeedSpacing.lg),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(widthFactor: 0.55, height: 18),
                    SizedBox(height: RaeedSpacing.sm),
                    SkeletonLine(widthFactor: 0.35),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.md),
          SkeletonBox(
            width: 140,
            height: 28,
            borderRadius: BorderRadius.circular(RaeedRadius.pill),
          ),
        ],
      ),
    );
  }
}
