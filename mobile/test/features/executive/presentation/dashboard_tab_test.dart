import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/features/executive/domain/dashboard_overview.dart';
import 'package:raeed/features/executive/presentation/dashboard_tab.dart';
import 'package:raeed/features/executive/presentation/executive_providers.dart';
import 'package:raeed/features/executive/presentation/widgets/alert_card.dart';
import 'package:raeed/features/executive/presentation/widgets/stat_tile.dart';
import 'package:raeed/shared/widgets/offline_banner.dart';
import 'package:raeed/shared/widgets/raeed_error_view.dart';
import 'package:raeed/shared/widgets/skeleton.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 20, 11);

  setUp(() => mocks = ExecutiveMocks());

  DashboardOverview overview({
    List<DashboardAlert> alerts = const [],
    List<TodaySession> sessions = const [],
  }) => DashboardOverview(
    alerts: alerts,
    stats: const [
      DashboardStat(kind: StatKind.children, value: 246, delta: 12),
      DashboardStat(kind: StatKind.families, value: 163),
      DashboardStat(kind: StatKind.groups, value: 14),
      DashboardStat(kind: StatKind.educators, value: 18),
    ],
    weeklyAttendance: const WeeklyAttendance(
      presentCount: 412,
      expectedCount: 453,
      weeklyRates: [82, 86, 91],
      deltaPoints: 2,
    ),
    todaySessions: sessions,
    fetchedAt: DateTime.utc(2026, 9, 20, 10, 42),
  );

  testWidgets('loading shows skeletons, never a spinner', (tester) async {
    when(
      () => mocks.dashboard.fetchOverview(),
    ).thenAnswer((_) => Future.delayed(const Duration(seconds: 1), overview));
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, DashboardTab(now: now));
    await tester.pump();

    expect(find.byType(SkeletonBox), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('a failure with no cache shows the error view with retry', (
    tester,
  ) async {
    when(() => mocks.dashboard.fetchOverview())
        .thenThrow(const NetworkException(message: 'down'));
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, DashboardTab(now: now));
    await tester.pumpAndSettle();

    expect(find.byType(RaeedErrorView), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('no alerts renders the reassuring state and zero-valued tiles', (
    tester,
  ) async {
    when(() => mocks.dashboard.fetchOverview())
        .thenAnswer((_) async => overview());
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, DashboardTab(now: now));
    await tester.pumpAndSettle();

    expect(find.text('لا شيء يحتاج انتباهك اليوم'), findsOneWidget);
    expect(find.byType(AlertCard), findsNothing);
    expect(find.byType(StatTile), findsNWidgets(4));
    expect(find.text('246'), findsOneWidget);
    expect(find.text('+12'), findsOneWidget);
    expect(find.text('91%'), findsOneWidget);
    // Said in the header's count and again where the list would be.
    expect(find.text('لا جلسات اليوم'), findsNWidgets(2));
  });

  testWidgets('alerts render danger first and outline the danger card', (
    tester,
  ) async {
    when(() => mocks.dashboard.fetchOverview()).thenAnswer(
      (_) async => overview(
        alerts: [
          alertOf('info', AlertSeverity.info, minutesAgo: 0),
          alertOf('danger', AlertSeverity.danger, minutesAgo: 60),
          alertOf('warning', AlertSeverity.warning, minutesAgo: 1),
        ],
      ),
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, DashboardTab(now: now));
    await tester.pumpAndSettle();

    final cards = tester
        .widgetList<AlertCard>(find.byType(AlertCard))
        .map((card) => card.alert.id)
        .toList();
    expect(cards, ['danger', 'warning', 'info']);
    expect(find.text('لا شيء يحتاج انتباهك اليوم'), findsNothing);
    // The count pill beside the section title.
    expect(find.text('3'), findsOneWidget);
    // Severity is said in words, not only colour.
    expect(find.text('خطر'), findsOneWidget);
    expect(find.text('تنبيه'), findsOneWidget);
    expect(find.text('للعلم'), findsOneWidget);
  });

  testWidgets('tapping an alert selects the tab that resolves it', (
    tester,
  ) async {
    when(() => mocks.dashboard.fetchOverview()).thenAnswer(
      (_) async => overview(
        alerts: [
          alertOf(
            'posts',
            AlertSeverity.info,
            destination: AlertDestination.memories,
          ),
        ],
      ),
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, DashboardTab(now: now));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AlertCard));
    await tester.pump();

    expect(
      container.read(executiveTabControllerProvider),
      ExecutiveTab.memories,
    );
  });

  testWidgets('a failed refresh keeps the last overview with a dated banner', (
    tester,
  ) async {
    when(() => mocks.dashboard.fetchOverview()).thenAnswer(
      (_) async => overview(alerts: [alertOf('a', AlertSeverity.danger)]),
    );
    final container = await executiveContainer(mocks);
    await pumpExecutive(tester, container, DashboardTab(now: now));
    await tester.pumpAndSettle();
    expect(find.byType(OfflineBanner), findsNothing);

    when(() => mocks.dashboard.fetchOverview())
        .thenThrow(const NetworkException(message: 'down'));
    await container.read(dashboardControllerProvider.notifier).refresh();
    await tester.pumpAndSettle();

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.byType(AlertCard), findsOneWidget);
    expect(find.byType(RaeedErrorView), findsNothing);
  });

  testWidgets('today sessions carry the attendance state as a word', (
    tester,
  ) async {
    when(() => mocks.dashboard.fetchOverview()).thenAnswer(
      (_) async => overview(
        sessions: [
          TodaySession(
            id: 's1',
            groupId: 'g1',
            groupName: 'الأشبال 1',
            title: 'حلقة القرآن',
            startsAt: DateTime.utc(2026, 9, 20, 8),
            endsAt: DateTime.utc(2026, 9, 20, 9, 30),
            attendanceRecorded: false,
          ),
          TodaySession(
            id: 's2',
            groupId: 'g2',
            groupName: 'الزهرات 1',
            startsAt: DateTime.utc(2026, 9, 20, 14),
            endsAt: DateTime.utc(2026, 9, 20, 15, 30),
            attendanceRecorded: false,
          ),
        ],
      ),
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, DashboardTab(now: now));
    await tester.pumpAndSettle();

    expect(find.text('غير مسجَّل'), findsOneWidget);
    expect(find.text('قادمة'), findsOneWidget);
    expect(find.text('الأشبال 1 · حلقة القرآن'), findsOneWidget);
  });

  testWidgets('holds up at 130% text scaling without overflow', (tester) async {
    when(() => mocks.dashboard.fetchOverview()).thenAnswer(
      (_) async => overview(
        alerts: [
          alertOf('a', AlertSeverity.danger),
          alertOf('b', AlertSeverity.warning),
        ],
      ),
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(
      tester,
      container,
      DashboardTab(now: now),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(StatTile), findsNWidgets(4));
  });
}
