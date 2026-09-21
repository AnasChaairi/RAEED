import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/authorization/raeed_role.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../../shared/widgets/skeleton.dart';
import '../application/notification_filter.dart';
import '../application/session_attendance_state.dart';
import '../domain/dashboard_overview.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/alert_card.dart';
import 'widgets/executive_header.dart';
import 'widgets/stat_tile.dart';
import 'widgets/today_session_tile.dart';
import 'widgets/weekly_attendance_card.dart';

/// EXEC-M-01 — the dashboard.
///
/// Scanned standing up: alerts first, then numbers, then today's sessions.
/// Nothing below the fold is needed to answer "is anything wrong?".
class DashboardTab extends ConsumerWidget {
  const DashboardTab({this.now, super.key});

  /// Injected by tests; the clock otherwise.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final dashboard = ref.watch(dashboardControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final unread = ref.watch(notificationsControllerProvider).value;
    final today = now ?? DateTime.now();
    final overview = dashboard.value?.overview;

    final roleLabel = session.effectiveRole == RaeedRole.admin
        ? l10n.roleAdmin
        : l10n.roleExecutive;

    return Column(
      children: [
        ExecutiveHeader(
          displayName: session.user?.displayName ?? '',
          roleLabel: roleLabel,
          today: today,
          sessionsToday: overview?.todaySessions.length,
          liveCount: overview == null
              ? 0
              : _count(overview, today, SessionAttendanceState.live),
          upcomingCount: overview == null
              ? 0
              : _count(overview, today, SessionAttendanceState.upcoming),
          hasUnread: unread != null && unreadCount(unread) > 0,
          onNotificationsTap: () => context.go(AppRoutes.notifications),
          onMoreTap: () => context.go(AppRoutes.more),
        ),
        Expanded(
          child: dashboard.when(
            loading: () => const _DashboardSkeleton(),
            error: (error, _) => RaeedErrorView(
              error: error,
              onRetry: () =>
                  ref.read(dashboardControllerProvider.notifier).refresh(),
            ),
            data: (state) => _DashboardBody(state: state, now: today),
          ),
        ),
      ],
    );
  }

  static int _count(
    DashboardOverview overview,
    DateTime now,
    SessionAttendanceState wanted,
  ) => overview.todaySessions
      .where((session) => sessionAttendanceStateAt(session, now) == wanted)
      .length;
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.state, required this.now});

  final DashboardState state;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final alerts = state.alerts;
    final overview = state.overview;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          RaeedSpacing.md,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          if (state.staleness != null) ...[
            OfflineBanner(
              reason: state.staleness == DashboardStaleness.offline
                  ? StaleDataReason.offline
                  : StaleDataReason.refreshFailed,
              messageOverride: state.staleness == DashboardStaleness.offline
                  ? l10n.execStaleOffline(clockTime(locale, overview.fetchedAt))
                  : l10n.execStaleRefreshFailed(
                      clockTime(locale, overview.fetchedAt),
                    ),
            ),
            const SizedBox(height: RaeedSpacing.md),
          ],
          _SectionTitle(title: l10n.dashNeedsAttention, count: alerts.length),
          const SizedBox(height: RaeedSpacing.sm),
          if (alerts.isEmpty)
            const _NoAlertsCard()
          else
            for (final alert in alerts)
              Padding(
                padding: const EdgeInsets.only(bottom: RaeedSpacing.sm),
                child: AlertCard(
                  alert: alert,
                  onTap: () => _openAlert(context, ref, alert),
                ),
              ),
          const SizedBox(height: RaeedSpacing.sm),
          if (overview.stats.isNotEmpty) ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: RaeedSpacing.sm + 2,
              crossAxisSpacing: RaeedSpacing.sm + 2,
              childAspectRatio: 2.1,
              children: [
                for (final stat in overview.stats) StatTile(stat: stat),
              ],
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
          ],
          if (overview.weeklyAttendance != null) ...[
            WeeklyAttendanceCard(attendance: overview.weeklyAttendance!),
            const SizedBox(height: RaeedSpacing.md),
          ],
          _SectionTitle(title: l10n.dashTodaySessions),
          const SizedBox(height: RaeedSpacing.sm),
          if (overview.todaySessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: RaeedSpacing.sm),
              child: Text(
                l10n.dashNoSessionsToday,
                style: context.type.bodySmall.copyWith(color: palette.inkDim),
              ),
            )
          else
            for (final session in overview.todaySessions)
              Padding(
                padding: const EdgeInsets.only(bottom: RaeedSpacing.sm),
                child: TodaySessionTile(
                  session: session,
                  now: now,
                  onTap: () => context.go(AppRoutes.groupPath(session.groupId)),
                ),
              ),
        ],
      ),
    );
  }

  /// An alert opens the tab that resolves it, or the notification centre
  /// when it points nowhere in particular.
  void _openAlert(BuildContext context, WidgetRef ref, DashboardAlert alert) {
    final tab = ExecutiveTab.forDestination(alert.destination);
    if (tab == null) {
      context.go(AppRoutes.notifications);
      return;
    }
    ref.read(executiveTabControllerProvider.notifier).select(tab);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xs),
      child: Row(
        children: [
          Text(title, style: context.type.h3.copyWith(color: palette.ink)),
          if (count != null && count! > 0) ...[
            const SizedBox(width: RaeedSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.sm),
              decoration: BoxDecoration(
                color: palette.dangerSoft,
                borderRadius: BorderRadius.circular(RaeedRadius.pill),
              ),
              child: Text(
                '$count',
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(color: palette.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The reassuring empty state: nothing needs you.
class _NoAlertsCard extends StatelessWidget {
  const _NoAlertsCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      decoration: BoxDecoration(
        color: palette.successSoft,
        borderRadius: BorderRadius.circular(RaeedRadius.lg + 2),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: palette.success),
          ),
          const SizedBox(width: RaeedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashNoAlertsTitle,
                  style: context.type.label.copyWith(
                    color: palette.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.dashNoAlertsBody,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton alert rows and stat tiles, in the layout the data will take.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget box(double height, {double radius = RaeedRadius.lg + 2}) =>
        SkeletonBox(
          width: double.infinity,
          height: height,
          borderRadius: BorderRadius.circular(radius),
        );

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      children: [
        const SkeletonLine(widthFactor: 0.4, height: 18),
        const SizedBox(height: RaeedSpacing.md),
        box(56),
        const SizedBox(height: RaeedSpacing.sm),
        box(56),
        const SizedBox(height: RaeedSpacing.md),
        Row(
          children: [
            Expanded(child: box(72)),
            const SizedBox(width: RaeedSpacing.sm + 2),
            Expanded(child: box(72)),
          ],
        ),
        const SizedBox(height: RaeedSpacing.sm + 2),
        Row(
          children: [
            Expanded(child: box(72)),
            const SizedBox(width: RaeedSpacing.sm + 2),
            Expanded(child: box(72)),
          ],
        ),
        const SizedBox(height: RaeedSpacing.md),
        box(120, radius: RaeedRadius.xl),
        const SizedBox(height: RaeedSpacing.md),
        Divider(color: palette.border),
      ],
    );
  }
}
