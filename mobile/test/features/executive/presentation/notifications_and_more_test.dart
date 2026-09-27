import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/session/session_controller.dart';
import 'package:raeed/core/theme/theme_mode_controller.dart';
import 'package:raeed/features/executive/domain/notification_item.dart';
import 'package:raeed/features/executive/presentation/more_screen.dart';
import 'package:raeed/features/executive/presentation/notifications_screen.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 20, 11);

  setUp(() => mocks = ExecutiveMocks());

  group('notifications', () {
    final items = [
      NotificationItem(
        id: 'n1',
        kind: NotificationKind.critical,
        title: 'غياب دون إشعار — سلمى القادري',
        sentAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: 'n2',
        kind: NotificationKind.request,
        title: 'طلب تغيير معلق',
        sentAt: now.subtract(const Duration(minutes: 40)),
        isRead: true,
      ),
    ];

    testWidgets('filters by kind and marks all read', (tester) async {
      when(() => mocks.notifications.fetchNotifications())
          .thenAnswer((_) async => items);
      when(() => mocks.notifications.markAllRead()).thenAnswer((_) async {});
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, NotificationsScreen(now: now));
      await tester.pumpAndSettle();

      expect(find.text('غياب دون إشعار — سلمى القادري'), findsOneWidget);
      expect(find.text('قبل ساعة'), findsOneWidget);

      await tester.tap(find.text('طلبات'));
      await tester.pumpAndSettle();
      expect(find.text('غياب دون إشعار — سلمى القادري'), findsNothing);
      expect(find.text('طلب تغيير معلق'), findsOneWidget);

      await tester.tap(find.text('تعليم الكل كمقروء'));
      await tester.pumpAndSettle();
      verify(() => mocks.notifications.markAllRead()).called(1);
      expect(find.text('تعليم الكل كمقروء'), findsNothing);
    });

    testWidgets('an empty centre is the reassuring kind', (tester) async {
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, NotificationsScreen(now: now));
      await tester.pumpAndSettle();

      expect(find.text('لا جديد'), findsOneWidget);
    });
  });

  group('more', () {
    testWidgets('switching role narrows presentation only', (tester) async {
      final container = await executiveContainer(
        mocks,
        roles: {RaeedRole.executive, RaeedRole.educator},
      );

      await pumpExecutive(
        tester,
        container,
        const MoreScreen(),
        routes: {'/home': const Text('home'), '/dashboard': const Text('dash')},
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('لديك دوران'), findsOneWidget);
      await tester.tap(find.text('مؤطِّر'));
      await tester.pumpAndSettle();

      final session = container.read(sessionControllerProvider);
      expect(session.effectiveRole, RaeedRole.educator);
      // The full role set is untouched — abilities stay the union.
      expect(session.user!.roles, {RaeedRole.executive, RaeedRole.educator});
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('a single role is shown but not switchable', (tester) async {
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const MoreScreen());
      await tester.pumpAndSettle();

      expect(find.text('إداري'), findsOneWidget);
      expect(tester.widget<RoleChoice>(find.byType(RoleChoice)).onTap, isNull);
    });

    testWidgets('the dark toggle drives the theme mode', (tester) async {
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const MoreScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(container.read(themeModeControllerProvider), ThemeMode.dark);
    });

    testWidgets('the critical channel is shown locked', (tester) async {
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const MoreScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('مقفلة'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });
  });
}
