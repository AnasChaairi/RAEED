import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/domain/executive_group.dart';
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_empty_state.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';

/// EDU-M-06 — the educator's groups.
class EducatorGroupsTab extends ConsumerWidget {
  const EducatorGroupsTab({this.now, super.key});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final groups = ref.watch(executiveGroupsProvider);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eduGroupsTitle,
                  style: context.type.h1.copyWith(color: palette.ink),
                ),
                Text(
                  l10n.eduGroupsSubtitle,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: groups.when(
            loading: () => const SkeletonCardList(count: 2, height: 150),
            error: (error, _) => RaeedErrorView(
              error: error,
              onRetry: () => ref.invalidate(executiveGroupsProvider),
            ),
            data: (list) => list.isEmpty
                ? ExecutiveEmptyState(
                    kind: EmptyStateKind.dataProblem,
                    title: l10n.eduGroupsEmpty,
                    body: l10n.eduGroupsFooter,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      RaeedSpacing.lg,
                      0,
                      RaeedSpacing.lg,
                      RaeedSpacing.xl2,
                    ),
                    children: [
                      for (final group in list) ...[
                        EducatorGroupCard(
                          group: group,
                          now: now ?? DateTime.now(),
                        ),
                        const SizedBox(height: RaeedSpacing.sm + 2),
                      ],
                      Text(
                        l10n.eduGroupsFooter,
                        textAlign: TextAlign.center,
                        style: context.type.caption.copyWith(
                          color: palette.inkDim,
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

class EducatorGroupCard extends StatelessWidget {
  const EducatorGroupCard({required this.group, required this.now, super.key});

  final ExecutiveGroup group;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final stats = group.stats;
    final next = stats?.nextSessionAt;
    final nextLabel = next == null
        ? '—'
        : next.toLocal().day == now.day && next.difference(now).inHours < 24
        ? l10n.sessionToday
        : shortDate(locale, next);

    return ExecutiveCard(
      onTap: () => context.push(AppRoutes.groupPath(group.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: context.type.h2.copyWith(color: palette.ink),
                    ),
                    Text(
                      [
                        if (group.scheduleLabel != null) group.scheduleLabel!,
                        if (group.place != null) group.place!,
                        if (group.educatorNames.length > 1)
                          l10n.sessMetaWith(group.educatorNames.last),
                      ].join(' · '),
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: palette.inkDim),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RaeedSpacing.sm + 2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(RaeedRadius.pill),
                ),
                child: Text(
                  '${group.enrolledCount}',
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(
                        color: palette.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm + 2),
          Row(
            children: [
              _StatTile(
                value: stats?.attendancePercent == null
                    ? '—'
                    : '${stats!.attendancePercent}%',
                label: l10n.statAttendance,
              ),
              const SizedBox(width: 6),
              _StatTile(
                value: stats?.homeworkPercent == null
                    ? '—'
                    : '${stats!.homeworkPercent}%',
                label: l10n.statHomework,
              ),
              const SizedBox(width: 6),
              _StatTile(value: nextLabel, label: l10n.statNext),
            ],
          ),
          for (final flag in stats?.flags ?? const <CareFlag>[]) ...[
            const SizedBox(height: RaeedSpacing.sm + 2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.sm + 2,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: palette.warningSoft,
                borderRadius: BorderRadius.circular(RaeedRadius.md),
              ),
              child: Text(
                l10n.groupFlag(flag.fullName),
                style: context.type.caption.copyWith(color: palette.warning),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: RaeedSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: context.type
                  .tabular(context.type.label)
                  .copyWith(color: palette.ink, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: context.type.caption.copyWith(
                color: palette.inkDim,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
