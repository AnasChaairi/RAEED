import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/features/executive/domain/conversation.dart';
import 'package:raeed/features/executive/domain/dashboard_overview.dart';
import 'package:raeed/features/executive/domain/memories_review.dart';
import 'package:raeed/features/executive/presentation/announcements_tab.dart';
import 'package:raeed/features/executive/presentation/dashboard_tab.dart';
import 'package:raeed/features/executive/presentation/executive_providers.dart';
import 'package:raeed/features/executive/presentation/executive_shell.dart';
import 'package:raeed/features/executive/presentation/groups_tab.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;

  setUp(() => mocks = ExecutiveMocks());

  testWidgets('shows five tabs and starts on the dashboard', (tester) async {
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, const ExecutiveShell());
    await tester.pumpAndSettle();

    for (final label in [
      'اللوحة',
      'الإعلانات',
      'الرسائل',
      'الذكريات',
      'المجموعات',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(
      container.read(executiveTabControllerProvider),
      ExecutiveTab.dashboard,
    );
    expect(find.byType(DashboardTab), findsOneWidget);
  });

  testWidgets('tapping a tab switches the visible screen', (tester) async {
    final container = await executiveContainer(mocks);
    await pumpExecutive(tester, container, const ExecutiveShell());
    await tester.pumpAndSettle();

    await tester.tap(find.text('المجموعات').last);
    await tester.pumpAndSettle();

    expect(container.read(executiveTabControllerProvider), ExecutiveTab.groups);
    // The groups tab now has a visible title.
    expect(find.byType(GroupsTab), findsOneWidget);
  });

  testWidgets('a deep link opens the requested tab', (tester) async {
    final container = await executiveContainer(mocks);

    await pumpExecutive(
      tester,
      container,
      const ExecutiveShell(initialTab: ExecutiveTab.announcements),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(executiveTabControllerProvider),
      ExecutiveTab.announcements,
    );
    expect(find.byType(AnnouncementsTab), findsOneWidget);
  });

  testWidgets('badges count what is waiting on each tab', (tester) async {
    when(() => mocks.dashboard.fetchOverview()).thenAnswer(
      (_) async => DashboardOverview(
        alerts: [
          alertOf('a', AlertSeverity.danger),
          alertOf('b', AlertSeverity.danger),
          alertOf(
            'c',
            AlertSeverity.danger,
            destination: AlertDestination.messages,
          ),
        ],
        stats: const [],
        weeklyAttendance: null,
        todaySessions: const [],
        fetchedAt: DateTime.utc(2026, 9, 20),
      ),
    );
    when(() => mocks.memories.fetchQueue()).thenAnswer(
      (_) async => ReviewQueue(
        posts: [
          ReviewPost(
            id: 'p1',
            albumTitle: 'x',
            authorName: 'y',
            postedAt: DateTime.utc(2026, 9, 20),
            mediaCount: 1,
            tags: const [],
          ),
        ],
      ),
    );
    when(() => mocks.messages.fetchConversations()).thenAnswer(
      (_) async => const [
        ConversationSummary(
          id: 'c1',
          kind: ConversationKind.child,
          title: 't',
          isMember: false,
          unreadCount: 4,
        ),
      ],
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, const ExecutiveShell());
    await tester.pumpAndSettle();

    final badges = container.read(executiveTabBadgesProvider);
    expect(badges.groups, 2);
    expect(badges.memories, 1);
    expect(badges.messages, 1);
    expect(findSemanticsLabel('المجموعات (2)'), findsOneWidget);
  });
}
