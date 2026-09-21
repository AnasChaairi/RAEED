import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../application/announcement_filter.dart';
import '../domain/announcement_draft.dart';
import 'audience_label.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/tone_chip.dart';

/// EXEC-M-02 — the announcements list.
class AnnouncementsTab extends ConsumerStatefulWidget {
  const AnnouncementsTab({this.now, super.key});

  final DateTime? now;

  @override
  ConsumerState<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends ConsumerState<AnnouncementsTab> {
  AnnouncementState _filter = AnnouncementState.published;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final announcements = ref.watch(announcementsControllerProvider);
    final now = widget.now ?? DateTime.now();

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
              RaeedSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.execTabAnnouncements,
                    style: context.type.h1.copyWith(color: palette.ink),
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, RaeedTouchTarget.minPx),
                    padding: const EdgeInsets.symmetric(
                      horizontal: RaeedSpacing.lg,
                    ),
                  ),
                  onPressed: () => context.go(AppRoutes.announcementCompose),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.annNew),
                ),
              ],
            ),
          ),
          _FilterChips(
            counts: announcementStateCounts(
              announcements.value ?? const [],
              now,
            ),
            selected: _filter,
            onSelect: (state) => setState(() => _filter = state),
          ),
          const SizedBox(height: RaeedSpacing.md),
          Expanded(
            child: announcements.when(
              loading: () => const SkeletonCardList(height: 110),
              error: (error, _) => RaeedErrorView(
                error: error,
                onRetry: () => ref
                    .read(announcementsControllerProvider.notifier)
                    .refresh(),
              ),
              data: (all) {
                if (all.isEmpty) {
                  return ExecutiveEmptyState(
                    kind: EmptyStateKind.dataProblem,
                    title: l10n.annEmptyTitle,
                    body: l10n.annEmptyBody,
                  );
                }
                final shown = announcementsInState(all, _filter, now);
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(announcementsControllerProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      RaeedSpacing.lg,
                      0,
                      RaeedSpacing.lg,
                      RaeedSpacing.xl2,
                    ),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: RaeedSpacing.sm + 2),
                    itemBuilder: (_, index) =>
                        _AnnouncementCard(announcement: shown[index], now: now),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.counts,
    required this.selected,
    required this.onSelect,
  });

  final Map<AnnouncementState, int> counts;
  final AnnouncementState selected;
  final ValueChanged<AnnouncementState> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xl),
      child: Row(
        children: [
          for (final state in AnnouncementState.values) ...[
            FilterPill(
              label: (counts[state] ?? 0) > 0
                  ? '${stateLabel(l10n, state)} ${counts[state]}'
                  : stateLabel(l10n, state),
              selected: state == selected,
              onTap: () => onSelect(state),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  static String stateLabel(AppL10n l10n, AnnouncementState state) =>
      switch (state) {
        AnnouncementState.published => l10n.annStatePublished,
        AnnouncementState.scheduled => l10n.annStateScheduled,
        AnnouncementState.draft => l10n.annStateDraft,
        AnnouncementState.expired => l10n.annStateExpired,
      };
}

/// A pill-shaped filter toggle: primary when selected, bordered otherwise.
class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? palette.primary : palette.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? palette.primary : palette.border),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.md + 1,
                vertical: RaeedSpacing.sm - 1,
              ),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: context.type
                        .tabular(context.type.label)
                        .copyWith(
                          color: selected ? palette.primaryOn : palette.inkDim,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement, required this.now});

  final ExecutiveAnnouncement announcement;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final state = announcement.stateAt(now);
    final readRate = announcement.readRate;

    final meta = [
      audienceLabel(l10n, announcement.audience),
      switch (state) {
        AnnouncementState.scheduled => l10n.annMetaScheduled(
          shortDate(locale, announcement.publishAt),
        ),
        AnnouncementState.draft => l10n.annStateDraft,
        _ => l10n.annMetaPublished(
          relativeTime(l10n, locale, announcement.publishAt, now: now),
        ),
      },
      if (announcement.expireAt != null && state == AnnouncementState.published)
        l10n.annMetaExpires(shortDate(locale, announcement.expireAt!)),
      if (announcement.pinned) l10n.annPinned,
    ].join(' · ');

    return ExecutiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  announcement.title,
                  style: context.type.h3.copyWith(color: palette.ink),
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              _stateChip(l10n, state),
            ],
          ),
          const SizedBox(height: RaeedSpacing.xs),
          Text(
            meta,
            style: context.type
                .tabular(context.type.caption)
                .copyWith(color: palette.inkDim),
          ),
          if (readRate != null) ...[
            const SizedBox(height: RaeedSpacing.sm + 2),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: readRate,
                      minHeight: 6,
                      backgroundColor: palette.surfaceAlt,
                      color: palette.primary,
                    ),
                  ),
                ),
                const SizedBox(width: RaeedSpacing.sm + 2),
                Text(
                  l10n.annReadBy((readRate * 100).round()),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(
                        color: palette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stateChip(AppL10n l10n, AnnouncementState state) {
    if (announcement.isUrgent && state == AnnouncementState.published) {
      return ToneChip(label: l10n.annUrgentTag, tone: ChipTone.accent);
    }
    return switch (state) {
      AnnouncementState.published => ToneChip(
        label: l10n.annStatePublished,
        tone: ChipTone.success,
      ),
      AnnouncementState.scheduled => ToneChip(
        label: l10n.annStateScheduled,
        tone: ChipTone.info,
      ),
      AnnouncementState.draft => ToneChip(
        label: l10n.annStateDraft,
        tone: ChipTone.neutral,
      ),
      AnnouncementState.expired => ToneChip(
        label: l10n.annStateExpired,
        tone: ChipTone.neutral,
      ),
    };
  }
}
