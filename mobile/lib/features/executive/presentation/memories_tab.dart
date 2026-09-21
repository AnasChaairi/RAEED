import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../../shared/widgets/skeleton.dart';
import '../domain/memories_review.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/executive_card.dart';

/// EXEC-M-04 — the Memories review queue and the wall.
///
/// One post at a time, with every tagged child's image-rights level on the
/// photo itself. Hide is never delete. The moderation mode is shown as the
/// server reports it and never toggled here — it is open decision #3.
class MemoriesTab extends ConsumerWidget {
  const MemoriesTab({this.now, super.key});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final queue = ref.watch(reviewQueueControllerProvider);
    final albums = ref.watch(memoriesAlbumsProvider);
    final today = now ?? DateTime.now();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xl,
              RaeedSpacing.md,
              RaeedSpacing.xl,
              RaeedSpacing.sm + 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.memTitle,
                  style: context.type.h1.copyWith(color: palette.ink),
                ),
                if (queue.value case final ReviewQueue loaded)
                  Text(
                    '${l10n.memQueueLeft(loaded.posts.length)} · '
                    '${_modeLabel(l10n, loaded.moderationMode)}',
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                  ),
              ],
            ),
          ),
          Expanded(
            child: queue.when(
              loading: () => const _QueueSkeleton(),
              error: (error, _) => RaeedErrorView(
                error: error,
                onRetry: () =>
                    ref.read(reviewQueueControllerProvider.notifier).refresh(),
              ),
              data: (loaded) => RefreshIndicator(
                onRefresh: () =>
                    ref.read(reviewQueueControllerProvider.notifier).refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    RaeedSpacing.lg,
                    0,
                    RaeedSpacing.lg,
                    RaeedSpacing.xl2,
                  ),
                  children: [
                    if (loaded.head case final ReviewPost post) ...[
                      ReviewCard(
                        post: post,
                        position: 1,
                        total: loaded.posts.length,
                        moderationMode: loaded.moderationMode,
                        now: today,
                        onApprove: () => _act(
                          context,
                          ref,
                          () => ref
                              .read(reviewQueueControllerProvider.notifier)
                              .approve(post),
                          success: l10n.memApprovedToast,
                        ),
                        onHide: () => _act(
                          context,
                          ref,
                          () => ref
                              .read(reviewQueueControllerProvider.notifier)
                              .hide(post),
                          success: l10n.memHiddenToast,
                        ),
                      ),
                      const SizedBox(height: RaeedSpacing.sm),
                      Text(
                        l10n.memHideHint,
                        textAlign: TextAlign.center,
                        style: context.type.caption.copyWith(
                          color: palette.inkDim,
                        ),
                      ),
                    ] else
                      const _AllReviewedCard(),
                    const SizedBox(height: RaeedSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.xs,
                      ),
                      child: Text(
                        l10n.memWall,
                        style: context.type.h3.copyWith(color: palette.ink),
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm),
                    albums.when(
                      loading: () => const SizedBox(
                        height: 140,
                        child: Row(
                          children: [
                            Expanded(
                              child: SkeletonBox(
                                width: double.infinity,
                                height: 140,
                              ),
                            ),
                            SizedBox(width: RaeedSpacing.sm + 2),
                            Expanded(
                              child: SkeletonBox(
                                width: double.infinity,
                                height: 140,
                              ),
                            ),
                          ],
                        ),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (list) => list.isEmpty
                          ? Text(
                              l10n.memNoAlbums,
                              style: context.type.bodySmall.copyWith(
                                color: palette.inkDim,
                              ),
                            )
                          : GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: RaeedSpacing.sm + 2,
                              crossAxisSpacing: RaeedSpacing.sm + 2,
                              childAspectRatio: 1.15,
                              children: [
                                for (final album in list)
                                  _AlbumTile(album: album),
                              ],
                            ),
                    ),
                    const SizedBox(height: RaeedSpacing.md),
                    const _RightsLegend(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _modeLabel(AppL10n l10n, ModerationMode? mode) =>
      switch (mode) {
        ModerationMode.approveBeforePublish => l10n.memModeApproveFirst,
        ModerationMode.publishThenModerate => l10n.memModePublishThenReview,
        null => l10n.memModeUnset,
      };

  static Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action, {
    required String success,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    try {
      await action();
      messenger.showSnackBar(
        SnackBar(content: Text('$success · ${l10n.recordedShort}')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }
}

/// The post under review.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.post,
    required this.position,
    required this.total,
    required this.now,
    this.moderationMode,
    this.onApprove,
    this.onHide,
    super.key,
  });

  final ReviewPost post;
  final int position;
  final int total;
  final DateTime now;
  final ModerationMode? moderationMode;
  final VoidCallback? onApprove;
  final VoidCallback? onHide;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final blocked = post.notAllowedTags;

    final approveLabel = post.isBlocked
        ? l10n.memReapprove
        : moderationMode == ModerationMode.publishThenModerate
        ? l10n.memKeep
        : l10n.memApprove;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(RaeedRadius.xl2),
        border: Border.all(color: palette.border),
        // The one floating thing on this screen: the card under review.
        boxShadow: context.elevationSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (post.thumbnailUrl != null)
                  CachedNetworkImage(
                    imageUrl: post.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        ColoredBox(color: palette.surfaceAlt),
                    errorWidget: (_, _, _) =>
                        ColoredBox(color: palette.surfaceAlt),
                  )
                else
                  ColoredBox(
                    color: palette.surfaceAlt,
                    child: Icon(
                      Icons.photo_outlined,
                      size: 40,
                      color: palette.inkDim,
                    ),
                  ),
                if (post.isBlocked)
                  PositionedDirectional(
                    top: RaeedSpacing.md,
                    start: RaeedSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.sm + 2,
                        vertical: RaeedSpacing.xs + 1,
                      ),
                      decoration: BoxDecoration(
                        color: palette.danger,
                        borderRadius: BorderRadius.circular(RaeedRadius.pill),
                      ),
                      child: Text(
                        l10n.memBlockedBadge,
                        style: context.type.caption.copyWith(
                          color: palette.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                PositionedDirectional(
                  bottom: RaeedSpacing.md,
                  end: RaeedSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RaeedSpacing.sm + 1,
                      vertical: RaeedSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: palette.ink.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(RaeedRadius.pill),
                    ),
                    child: Text(
                      l10n.memCounter(position, post.mediaCount),
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: palette.surface),
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: RaeedSpacing.md,
                  start: RaeedSpacing.md,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.6,
                    ),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in post.tags) ImageRightsTag(tag: tag),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(RaeedSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.albumTitle,
                  style: context.type.h3.copyWith(color: palette.ink),
                ),
                Text(
                  [
                    if (post.groupName != null) post.groupName!,
                    post.authorName,
                    relativeTime(l10n, locale, post.postedAt, now: now),
                  ].join(' · '),
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
                if (blocked.isNotEmpty) ...[
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RaeedSpacing.sm + 2,
                      vertical: RaeedSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: palette.dangerSoft,
                      borderRadius: BorderRadius.circular(RaeedRadius.md),
                    ),
                    child: Text(
                      l10n.memBlockedBody(
                        blocked.map((tag) => tag.name).join('، '),
                      ),
                      style: context.type.caption.copyWith(
                        color: palette.danger,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: RaeedSpacing.md + 2),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.danger,
                          backgroundColor: palette.bg,
                        ),
                        onPressed: onHide,
                        icon: const Icon(
                          Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        label: Text(l10n.memHide),
                      ),
                    ),
                    const SizedBox(width: RaeedSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(approveLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tagged child's name with their image-rights level as a coloured dot
/// and icon — the three-level indicator, legible on a photo.
class ImageRightsTag extends StatelessWidget {
  const ImageRightsTag({required this.tag, super.key});

  final TaggedChild tag;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final (color, icon, level) = switch (tag.imageRights) {
      ImageRightsLevel.allowed => (
        palette.success,
        Icons.circle,
        l10n.imageRightsAllowed,
      ),
      ImageRightsLevel.appOnly => (
        palette.info,
        Icons.contrast_rounded,
        l10n.imageRightsAppOnly,
      ),
      ImageRightsLevel.notAllowed => (
        palette.danger,
        Icons.block_rounded,
        l10n.imageRightsNotAllowed,
      ),
    };

    return Semantics(
      label: '${tag.name} — ${l10n.imageRightsLabel(level)}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 3, 9, 3),
          decoration: BoxDecoration(
            color: raeedLightPalette.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(RaeedRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 10, color: raeedLightPalette.surface),
              ),
              const SizedBox(width: 5),
              Text(
                tag.name,
                style: context.type.caption.copyWith(
                  color: raeedLightPalette.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllReviewedCard extends StatelessWidget {
  const _AllReviewedCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ExecutiveCard(
      radius: RaeedRadius.xl2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.xl2,
        vertical: RaeedSpacing.xl3 + 4,
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: palette.successSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: palette.success),
          ),
          const SizedBox(height: RaeedSpacing.md),
          Text(
            l10n.memAllReviewedTitle,
            style: context.type.h3.copyWith(color: palette.ink),
            textAlign: TextAlign.center,
          ),
          Text(
            l10n.memAllReviewedBody,
            style: context.type.bodySmall.copyWith(color: palette.inkDim),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({required this.album});

  final MemoriesAlbum album;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 88,
            child: album.coverUrl == null
                ? ColoredBox(
                    color: palette.accentSoft,
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: palette.accent,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: album.coverUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.md,
              vertical: RaeedSpacing.sm + 1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    l10n.memAlbumPosts(album.postCount),
                    if (album.groupName != null) album.groupName!,
                  ].join(' · '),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RightsLegend extends StatelessWidget {
  const _RightsLegend();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    Widget item(IconData icon, Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: RaeedSpacing.xs),
        Text(label, style: context.type.caption.copyWith(color: color)),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: RaeedSpacing.md,
      runSpacing: RaeedSpacing.xs,
      children: [
        item(Icons.circle, palette.success, l10n.imageRightsAllowed),
        item(Icons.contrast_rounded, palette.info, l10n.imageRightsAppOnly),
        item(Icons.block_rounded, palette.danger, l10n.imageRightsNotAllowed),
      ],
    );
  }
}

class _QueueSkeleton extends StatelessWidget {
  const _QueueSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(RaeedSpacing.lg),
    children: [
      SkeletonBox(
        width: double.infinity,
        height: 380,
        borderRadius: BorderRadius.circular(RaeedRadius.xl2),
      ),
    ],
  );
}
