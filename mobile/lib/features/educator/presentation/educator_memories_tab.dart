import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../../executive/presentation/widgets/tone_chip.dart';
import '../domain/memory_post.dart';
import 'educator_providers.dart';
import 'widgets/media_thumbnail.dart';

/// EDU-M-08 — my posts and the season's albums.
class EducatorMemoriesTab extends ConsumerWidget {
  const EducatorMemoriesTab({this.now, super.key});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final posts = ref.watch(myPostsProvider);
    final albums = ref.watch(memoriesAlbumsProvider);
    final at = now ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xl,
              RaeedSpacing.sm,
              RaeedSpacing.xl,
              RaeedSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.eduTabMemories,
                        style: context.type.h1.copyWith(color: palette.ink),
                      ),
                      Text(
                        l10n.eduMemSubtitle,
                        style: context.type.caption.copyWith(
                          color: palette.inkDim,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, RaeedTouchTarget.minPx),
                  ),
                  onPressed: () => context.push(AppRoutes.memoriesCompose),
                  child: Text(l10n.memNewPost),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: posts.when(
            loading: () => const SkeletonCardList(count: 3, height: 84),
            error: (error, _) => RaeedErrorView(
              error: error,
              onRetry: () => ref.invalidate(myPostsProvider),
            ),
            data: (list) => ListView(
              padding: const EdgeInsets.fromLTRB(
                RaeedSpacing.lg,
                0,
                RaeedSpacing.lg,
                RaeedSpacing.xl2,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RaeedSpacing.xs,
                  ),
                  child: Text(
                    l10n.memMyPosts,
                    style: context.type.caption.copyWith(
                      color: palette.inkDim,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: RaeedSpacing.sm),
                if (list.isEmpty)
                  Text(
                    l10n.memMyPostsEmpty,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                for (final post in list) ...[
                  _PostRow(post: post, now: at, locale: locale),
                  const SizedBox(height: RaeedSpacing.sm),
                ],
                const SizedBox(height: RaeedSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RaeedSpacing.xs,
                  ),
                  child: Text(
                    l10n.memAlbumsTitle,
                    style: context.type.caption.copyWith(
                      color: palette.inkDim,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: RaeedSpacing.sm),
                albums.when(
                  loading: () => const SkeletonCardList(count: 1, height: 120),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (albums) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: RaeedSpacing.sm + 2,
                    crossAxisSpacing: RaeedSpacing.sm + 2,
                    childAspectRatio: 1.15,
                    children: [
                      for (final album in albums)
                        ExecutiveCard(
                          padding: EdgeInsets.zero,
                          radius: RaeedRadius.lg + 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: palette.accentSoft,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(RaeedRadius.lg + 2),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.photo_library_outlined,
                                    color: palette.accent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: RaeedSpacing.md,
                                  vertical: RaeedSpacing.sm,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      album.title,
                                      style: context.type.caption.copyWith(
                                        color: palette.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      l10n.memPostsInAlbum(album.postCount),
                                      style: context.type
                                          .tabular(context.type.caption)
                                          .copyWith(
                                            color: palette.inkDim,
                                            fontSize: 10.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post, required this.now, required this.locale});

  final MyPost post;
  final DateTime now;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final (label, tone) = switch (post.state) {
      PostState.pending => (l10n.memStatePending, ChipTone.warning),
      PostState.published => (l10n.memStatePublished, ChipTone.success),
      PostState.editRequested => (l10n.memStateEdit, ChipTone.info),
    };
    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.all(RaeedSpacing.sm + 2),
      child: Row(
        children: [
          if (post.thumbnailUrl != null)
            MediaThumbnail(url: post.thumbnailUrl!)
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
              ),
              child: Icon(Icons.image_outlined, color: palette.inkDim),
            ),
          const SizedBox(width: RaeedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.caption ?? post.albumTitle,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.memMediaCount(post.mediaCount)} · ${relativeTime(l10n, locale, post.createdAt, now: now)} · ${l10n.memTaggedCount(post.tagCount)}',
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                ),
                const SizedBox(height: 3),
                ToneChip(label: label, tone: tone),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
