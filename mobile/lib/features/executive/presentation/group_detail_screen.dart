import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../children/domain/child.dart';
import '../../children/presentation/widgets/health_alert_badge.dart';
import '../domain/executive_group.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/schedule_sheet.dart';
import 'widgets/tone_chip.dart';

/// EXEC-M-05 — one group: its sessions and its roster (`/groups/:id`).
///
/// A session row opens the attendance review; a roster row opens the
/// child's profile, where health information is revealed deliberately and
/// that reveal is logged (`AUD-03`). The roster shows the health badge as
/// icon only, like every list in the app.
class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({required this.groupId, this.now, super.key});

  final String groupId;
  final DateTime? now;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

enum _Segment { sessions, roster }

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  _Segment _segment = _Segment.sessions;

  Future<void> _editSchedule(ExecutiveGroup group) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final slots = await ScheduleSheet.show(
      context,
      initial: group.weeklySchedule,
    );
    if (slots == null || !mounted) return;
    try {
      await ref.read(groupsRepositoryProvider).updateSchedule(group.id, slots);
      ref.invalidate(executiveGroupProvider(group.id));
      ref.invalidate(groupSessionsProvider(group.id));
      ref.invalidate(executiveGroupsProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.scheduleSavedToast} · ⦿')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final group = ref.watch(executiveGroupProvider(widget.groupId));
    final roster = ref.watch(groupRosterProvider(widget.groupId));

    return Scaffold(
      backgroundColor: palette.bg,
      body: Column(
        children: [
          _GroupHeader(
            group: group.value,
            rosterCount: roster.value?.length,
            segment: _segment,
            onSegment: (segment) => setState(() => _segment = segment),
            onEditSchedule: group.value == null
                ? null
                : () => _editSchedule(group.value!),
            onBack: () => context.canPop()
                ? context.pop()
                : context.go(
                    AppRoutes.dashboardTabPath(ExecutiveTab.groups.slug),
                  ),
          ),
          Expanded(
            child: group.when(
              loading: () => const SkeletonCardList(count: 3),
              error: (error, _) => RaeedErrorView(
                error: error,
                onRetry: () =>
                    ref.invalidate(executiveGroupProvider(widget.groupId)),
              ),
              data: (_) => switch (_segment) {
                _Segment.sessions => _Sessions(
                  groupId: widget.groupId,
                  now: widget.now ?? DateTime.now(),
                ),
                _Segment.roster => _Roster(groupId: widget.groupId),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.group,
    required this.rosterCount,
    required this.segment,
    required this.onSegment,
    required this.onBack,
    required this.onEditSchedule,
  });

  final ExecutiveGroup? group;
  final int? rosterCount;
  final _Segment segment;
  final ValueChanged<_Segment> onSegment;
  final VoidCallback onBack;

  /// Opens the schedule editor; null while the group is still loading.
  final VoidCallback? onEditSchedule;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final on = palette.primaryOn;
    final loaded = group;

    final meta = loaded == null
        ? ''
        : [
            if (loaded.categoryName.isNotEmpty) loaded.categoryName,
            if (loaded.educatorNames.isNotEmpty)
              loaded.educatorNames.join('، '),
            if (loaded.scheduleLabel != null) loaded.scheduleLabel!,
            if (loaded.place != null) loaded.place!,
            if (loaded.capacity != null)
              '${loaded.enrolledCount}/${loaded.capacity}',
          ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: palette.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(RaeedRadius.xl2),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.sm,
            RaeedSpacing.xs,
            RaeedSpacing.lg,
            RaeedSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackButton(color: on, onPressed: onBack),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loaded?.name ?? '',
                          style: context.type.h2.copyWith(color: on),
                        ),
                        Text(
                          meta,
                          style: context.type
                              .tabular(context.type.caption)
                              .copyWith(color: on.withValues(alpha: 0.75)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('edit-schedule'),
                    tooltip: l10n.scheduleEditTitle,
                    color: on,
                    onPressed: onEditSchedule,
                    icon: const Icon(Icons.edit_calendar_outlined),
                  ),
                ],
              ),
              const SizedBox(height: RaeedSpacing.md),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: RaeedSpacing.sm,
                ),
                child: Row(
                  children: [
                    _SegmentPill(
                      label: l10n.grpTabSessions,
                      selected: segment == _Segment.sessions,
                      onTap: () => onSegment(_Segment.sessions),
                    ),
                    const SizedBox(width: 6),
                    _SegmentPill(
                      label: rosterCount == null
                          ? l10n.grpTabRoster
                          : '${l10n.grpTabRoster} $rosterCount',
                      selected: segment == _Segment.roster,
                      onTap: () => onSegment(_Segment.roster),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
    required this.label,
    required this.selected,
    required this.onTap,
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
        color: selected
            ? palette.primaryOn
            : palette.primaryOn.withValues(alpha: 0.16),
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.md),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: context.type
                        .tabular(context.type.label)
                        .copyWith(
                          color: selected ? palette.primary : palette.primaryOn,
                          fontWeight: selected
                              ? FontWeight.w700
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

class _Sessions extends ConsumerWidget {
  const _Sessions({required this.groupId, required this.now});

  final String groupId;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final sessions = ref.watch(groupSessionsProvider(groupId));

    return sessions.when(
      loading: () => const SkeletonCardList(count: 3),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(groupSessionsProvider(groupId)),
      ),
      data: (list) => list.isEmpty
          ? ExecutiveEmptyState(
              kind: EmptyStateKind.dataProblem,
              title: l10n.grpSessionsEmpty,
              body: '',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(RaeedSpacing.lg),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RaeedSpacing.sm),
              itemBuilder: (_, index) =>
                  SessionRow(session: list[index], now: now),
            ),
    );
  }
}

/// One session of the group, with its attendance state.
class SessionRow extends StatelessWidget {
  const SessionRow({required this.session, required this.now, super.key});

  final GroupSession session;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final isToday = _sameDay(session.startsAt.toLocal(), now.toLocal());
    final ended = !now.toUtc().isBefore(session.endsAt);

    final subtitle = [
      isToday ? l10n.sessionToday : dayAndMonth(locale, session.startsAt),
      if (session.status == SessionStatus.cancelled)
        l10n.sessionCancelled
      else if (isToday && ended)
        l10n.sessionEnded,
    ].join(' · ');

    final chip = session.status == SessionStatus.cancelled
        ? ToneChip(label: l10n.sessionCancelled, tone: ChipTone.neutral)
        : session.attendanceRecorded
        ? ToneChip(
            label: session.presentCount != null && session.enrolledCount != null
                ? '${session.presentCount}/${session.enrolledCount}'
                : l10n.sessionAttendanceRecorded,
            tone: ChipTone.success,
            icon: Icons.check_rounded,
          )
        : ended
        ? ToneChip(
            label: l10n.sessionAttendanceNotRecorded,
            tone: ChipTone.danger,
            icon: Icons.priority_high_rounded,
          )
        : ToneChip(
            label: l10n.sessionAttendanceUpcoming,
            tone: ChipTone.neutral,
            icon: Icons.radio_button_unchecked,
          );

    return ExecutiveCard(
      onTap: () => context.go(
        AppRoutes.attendanceReviewPath(session.groupId, session.id),
      ),
      radius: RaeedRadius.lg + 2,
      borderColor: isToday && !ended ? palette.primary : null,
      borderWidth: isToday && !ended ? 1.5 : 1,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              clockTime(locale, session.startsAt),
              style: context.type
                  .tabular(context.type.label)
                  .copyWith(color: palette.inkDim, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title ?? '',
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
          const SizedBox(width: RaeedSpacing.sm),
          chip,
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Roster extends ConsumerWidget {
  const _Roster({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final roster = ref.watch(groupRosterProvider(groupId));

    return roster.when(
      loading: () => const SkeletonCardList(count: 6, height: 56),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(groupRosterProvider(groupId)),
      ),
      data: (children) => children.isEmpty
          ? ExecutiveEmptyState(
              kind: EmptyStateKind.dataProblem,
              title: l10n.grpRosterEmpty,
              body: '',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(RaeedSpacing.lg),
              itemCount: children.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RaeedSpacing.sm),
              itemBuilder: (_, index) {
                final Child child = children[index];
                return ExecutiveCard(
                  onTap: () => context.go(AppRoutes.childPath(child.id)),
                  radius: RaeedRadius.lg + 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: RaeedSpacing.md + 2,
                    vertical: RaeedSpacing.sm + 2,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(RaeedRadius.lg),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: palette.inkDim,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: RaeedSpacing.md),
                      Expanded(
                        child: Text(
                          child.fullName,
                          style: context.type.label.copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (child.healthAlert) const HealthAlertBadge(size: 14),
                      const SizedBox(width: RaeedSpacing.sm),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: palette.inkDim,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
