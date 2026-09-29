import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/l10n/hijri_date.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/presentation/announcements_tab.dart' show FilterPill;
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_empty_state.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../domain/educator_session.dart';
import 'educator_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-04 — a week of sessions, generated from the group schedule.
class SessionsTab extends ConsumerStatefulWidget {
  const SessionsTab({this.now, super.key});

  final DateTime? now;

  @override
  ConsumerState<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends ConsumerState<SessionsTab> {
  late DateTime _weekStart = _startOfWeek(widget.now ?? DateTime.now());
  String? _groupId;

  /// Weeks start on Saturday, as the association's do.
  static DateTime _startOfWeek(DateTime day) {
    final local = DateTime(day.year, day.month, day.day);
    final daysSinceSaturday = (local.weekday - DateTime.saturday + 7) % 7;
    return local.subtract(Duration(days: daysSinceSaturday));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final now = widget.now ?? DateTime.now();
    final weekEnd = _weekStart.add(const Duration(days: 7));
    final sessions = ref.watch(
      weekSessionsProvider(from: _weekStart, to: weekEnd, groupId: _groupId),
    );
    final groups = ref.watch(executiveGroupsProvider).value ?? const [];

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
              RaeedSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sessTitle,
                        style: context.type.h1.copyWith(color: palette.ink),
                      ),
                      Text(
                        l10n.sessWeekRange(
                          shortDate(locale, _weekStart),
                          shortDate(
                            locale,
                            weekEnd.subtract(const Duration(days: 1)),
                          ),
                        ),
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  key: const Key('activity-new'),
                  tooltip: l10n.activityNewTitle,
                  onPressed: () => context.push(
                    _groupId == null
                        ? AppRoutes.sessionNew
                        : '${AppRoutes.sessionNew}?group=$_groupId',
                  ),
                  icon: const Icon(Icons.add_rounded),
                ),
                const SizedBox(width: 6),
                _WeekButton(
                  label: l10n.sessPrevWeek,
                  icon: Icons.arrow_forward_rounded,
                  onTap: () => setState(
                    () => _weekStart = _weekStart.subtract(
                      const Duration(days: 7),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _WeekButton(
                  label: l10n.sessNextWeek,
                  icon: Icons.arrow_back_rounded,
                  onTap: () => setState(() => _weekStart = weekEnd),
                ),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.lg),
          child: Row(
            children: [
              FilterPill(
                label: l10n.sessAllGroups,
                selected: _groupId == null,
                onTap: () => setState(() => _groupId = null),
              ),
              for (final group in groups) ...[
                const SizedBox(width: 6),
                FilterPill(
                  label: group.name,
                  selected: _groupId == group.id,
                  onTap: () => setState(() => _groupId = group.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: RaeedSpacing.sm + 2),
        Expanded(
          child: sessions.when(
            loading: () => const SkeletonCardList(count: 5),
            error: (error, _) => RaeedErrorView(
              error: error,
              onRetry: () => ref.invalidate(weekSessionsProvider),
            ),
            data: (list) => list.isEmpty
                ? ExecutiveEmptyState(
                    kind: EmptyStateKind.reassuring,
                    title: l10n.sessEmptyWeek,
                    body: l10n.sessFooter,
                  )
                : _WeekList(sessions: list, now: now),
          ),
        ),
      ],
    );
  }
}

class _WeekButton extends StatelessWidget {
  const _WeekButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: palette.ink),
          ),
        ),
      ),
    );
  }
}

class _WeekList extends StatelessWidget {
  const _WeekList({required this.sessions, required this.now});

  final List<SessionItem> sessions;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final days = <DateTime, List<SessionItem>>{};
    for (final item in sessions) {
      final local = item.startsAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      days.putIfAbsent(day, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        0,
        RaeedSpacing.lg,
        RaeedSpacing.xl2,
      ),
      children: [
        for (final entry in days.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xs,
              RaeedSpacing.sm,
              RaeedSpacing.xs,
              RaeedSpacing.xs,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: dayAndMonth(locale, entry.key),
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(
                          color: palette.inkDim,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextSpan(
                    text:
                        ' · ${HijriDate.fromGregorian(entry.key).format(locale.languageCode)}',
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                  ),
                ],
              ),
            ),
          ),
          for (final item in entry.value) ...[
            SessionRow(
              item: item,
              now: now,
              meta: [
                if (item.kind != SessionKind.session)
                  _ActivityNewScreenLabels.kind(l10n, item.kind),
                item.group.name,
                if (item.materialCount > 0)
                  l10n.sessMetaMaterials(item.materialCount),
                if (item.homeworkCount > 0) l10n.sessMetaHomework,
                if (!item.hasContent && !item.isCancelled)
                  l10n.sessMetaGenerated,
                if (item.coEducatorNames.length > 1)
                  l10n.sessMetaWith(item.coEducatorNames.last),
              ].join(' · '),
            ),
            const SizedBox(height: RaeedSpacing.sm),
          ],
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: RaeedSpacing.sm),
          child: Text(
            l10n.sessFooter,
            textAlign: TextAlign.center,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        ),
      ],
    );
  }
}

/// The kind word for a row; the screen that creates them owns the mapping.
abstract final class _ActivityNewScreenLabels {
  static String kind(AppL10n l10n, SessionKind kind) => switch (kind) {
    SessionKind.session => l10n.activityKindSession,
    SessionKind.sport => l10n.activityKindSport,
    SessionKind.workshop => l10n.activityKindWorkshop,
  };
}
