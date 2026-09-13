import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/announcement.dart';
import 'home_providers.dart';
import 'widgets/child_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/presence_prompt_card.dart';

/// The role-scoped home (`RAEED-12`).
///
/// From the screen spec: "Answer 'where is my child and what's next' in one
/// glance, for every enrolled child."
///
/// All four states are implemented as the spec describes them, and the error
/// state in particular is not a generic failure screen — it keeps the cached
/// cards and adds a quiet banner, because a parent on a weak connection wants
/// yesterday's answer rather than a retry button.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final displayName = ref.watch(
      sessionControllerProvider.select((s) => s.user?.displayName ?? ''),
    );

    return Scaffold(
      backgroundColor: context.palette.bg,
      body: Column(
        children: [
          HomeHeader(
            greetingName: displayName,
            today: DateTime.now(),
            unreadCount: home.value?.announcements.length ?? 0,
          ),
          Expanded(
            child: home.when(
              // Skeleton child cards — never a bare spinner. A shape that
              // already looks like the answer reads as "almost there".
              loading: () => const HomeSkeleton(),
              error: (error, _) => RaeedErrorView(
                error: error,
                onRetry: () =>
                    ref.read(homeControllerProvider.notifier).refresh(),
              ),
              data: (state) => _HomeBody(state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        // Always scrollable, so pull-to-refresh works even when the list is
        // short or empty — on the empty state that is the only way back.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (state.staleness != null)
            SliverToBoxAdapter(
              child: OfflineBanner(
                reason: state.staleness == HomeStaleness.offline
                    ? StaleDataReason.offline
                    : StaleDataReason.refreshFailed,
              ),
            ),
          // Above the announcements: an announcement is something to read, a
          // pending confirmation is something to do.
          const SliverToBoxAdapter(child: PresencePromptCard()),
          if (state.announcements.isNotEmpty)
            SliverToBoxAdapter(
              child: _AnnouncementsStrip(announcements: state.announcements),
            ),
          if (state.children.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _HomeEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(RaeedSpacing.lg),
              sliver: SliverList.separated(
                itemCount: state.children.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: RaeedSpacing.md),
                itemBuilder: (context, index) {
                  final child = state.children[index];
                  return ChildCard(
                    child: child,
                    now: now,
                    onTap: () => context.go(AppRoutes.childPath(child.id)),
                    onStatusTap: () => context.go(
                      AppRoutes.childTabPath(
                        child.id,
                        AppRoutes.childAttendance,
                      ),
                    ),
                    onHealthTap: () =>
                        context.go(AppRoutes.childPath(child.id)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// The pinned/active announcements strip.
class _AnnouncementsStrip extends StatelessWidget {
  const _AnnouncementsStrip({required this.announcements});

  final List<Announcement> announcements;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: RaeedSpacing.lg,
        start: RaeedSpacing.lg,
        end: RaeedSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.announcementsStripTitle,
            style: context.type.label.copyWith(color: palette.inkDim),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          for (final announcement in announcements)
            Padding(
              padding: const EdgeInsets.only(bottom: RaeedSpacing.sm),
              child: _AnnouncementTile(announcement: announcement),
            ),
        ],
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final isUrgent = announcement.priority == AnnouncementPriority.urgent;

    return Container(
      padding: const EdgeInsets.all(RaeedSpacing.md),
      decoration: BoxDecoration(
        color: isUrgent ? palette.surface : palette.surfaceAlt,
        borderRadius: BorderRadius.circular(RaeedRadius.md),
        border: Border.all(
          color: isUrgent ? palette.danger : palette.border,
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          if (announcement.pinned)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: RaeedSpacing.sm),
              child: Icon(
                Icons.push_pin_outlined,
                size: 14,
                color: palette.inkDim,
              ),
            ),
          Expanded(
            child: Text(
              announcement.title,
              style: context.type.bodySmall.copyWith(color: palette.ink),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (isUrgent) ...[
            const SizedBox(width: RaeedSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: palette.danger,
                borderRadius: BorderRadius.circular(RaeedRadius.pill),
              ),
              child: Text(
                l10n.announcementUrgent,
                style: context.type.caption.copyWith(color: palette.surface),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Should not occur post-onboarding.
///
/// The spec calls an empty home "a data problem", so the copy points at the
/// association rather than at the user — there is nothing they can do in the
/// app to fix it, and a cheerful "add your first child" would be a lie: a
/// parent cannot enrol a child themselves (`ACC-02`).
class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RaeedSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.family_restroom_outlined,
              size: 40,
              color: palette.inkDim,
            ),
            const SizedBox(height: RaeedSpacing.lg),
            Text(
              l10n.homeEmptyTitle,
              style: context.type.h3.copyWith(color: palette.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RaeedSpacing.sm),
            Text(
              l10n.homeEmptyBody,
              style: context.type.body.copyWith(color: palette.inkDim),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
