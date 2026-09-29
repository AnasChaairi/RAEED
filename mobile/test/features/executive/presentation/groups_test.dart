import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/network/api_envelope.dart';
import 'package:raeed/features/children/domain/child.dart';
import 'package:raeed/features/children/presentation/widgets/health_alert_badge.dart';
import 'package:raeed/features/executive/domain/executive_group.dart';
import 'package:raeed/features/executive/presentation/group_detail_screen.dart';
import 'package:raeed/features/executive/presentation/groups_tab.dart';
import 'package:raeed/features/executive/presentation/widgets/schedule_sheet.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 20, 11);

  const ashbal = ExecutiveGroup(
    id: 'g1',
    name: 'الأشبال 1',
    categoryName: 'الأشبال',
    enrolledCount: 20,
    capacity: 20,
    educatorNames: ['عبد الله المرابط'],
    scheduleLabel: 'السبت 10:00',
  );
  const zahrat = ExecutiveGroup(
    id: 'g3',
    name: 'الزهرات 1',
    categoryName: 'الزهرات',
    enrolledCount: 26,
    capacity: 24,
    educatorNames: ['خديجة بنجلون'],
  );

  setUp(() => mocks = ExecutiveMocks());

  testWidgets('the list marks a group over capacity in words', (tester) async {
    when(() => mocks.groups.fetchGroups())
        .thenAnswer((_) async => [ashbal, zahrat]);
    final container = await executiveContainer(mocks);

    await pumpExecutive(tester, container, const GroupsTab());
    await tester.pumpAndSettle();

    expect(find.text('20/20'), findsOneWidget);
    expect(find.text('26/24'), findsOneWidget);
    expect(findSemanticsLabel('فوق السعة 26/24'), findsOneWidget);
    expect(find.textContaining('كل الفروع'), findsOneWidget);
  });

  testWidgets('a branch-restricted executive is told so', (tester) async {
    when(() => mocks.groups.fetchGroups()).thenAnswer((_) async => [ashbal]);
    final container = await executiveContainer(mocks, branchId: 'branch-1');

    await pumpExecutive(tester, container, const GroupsTab());
    await tester.pumpAndSettle();

    expect(find.textContaining('مقيَّد'), findsOneWidget);
  });

  testWidgets('the group page edits the weekly schedule and refreshes', (
    tester,
  ) async {
    when(() => mocks.groups.fetchGroup('g1')).thenAnswer((_) async => ashbal);
    when(() => mocks.groups.fetchSessions('g1')).thenAnswer((_) async => []);
    when(() => mocks.groups.updateSchedule('g1', any())).thenAnswer(
      (_) async => const ExecutiveGroup(
        id: 'g1',
        name: 'الأشبال 1',
        categoryName: 'الأشبال',
        enrolledCount: 20,
        scheduleLabel: 'الجمعة 16:00',
      ),
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(
      tester,
      container,
      GroupDetailScreen(groupId: 'g1', now: now),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-schedule')));
    await tester.pumpAndSettle();
    // No slots yet: the hint says why it matters, and there is nothing to save.
    expect(find.textContaining('لا تُنشأ جلسات'), findsOneWidget);
    final save = find.byKey(const Key('sheet-save'));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.tap(find.byKey(const Key('slot-add')));
    await tester.pumpAndSettle();
    expect(find.text('الجمعة'), findsOneWidget);
    await tester.tap(save);
    await tester.pumpAndSettle();

    final slots =
        verify(() => mocks.groups.updateSchedule('g1', captureAny()))
                .captured
                .single
            as List<ScheduleSlot>;
    expect(slots, [ScheduleSheet.defaultSlot]);
    expect(find.textContaining('حُفظ الجدول'), findsOneWidget);
  });

  testWidgets('group detail lists sessions with their attendance state', (
    tester,
  ) async {
    when(() => mocks.groups.fetchGroup('g1')).thenAnswer((_) async => ashbal);
    when(() => mocks.groups.fetchSessions('g1')).thenAnswer(
      (_) async => [
        GroupSession(
          id: 's1',
          groupId: 'g1',
          title: 'حلقة القرآن',
          startsAt: DateTime.utc(2026, 9, 20, 8),
          endsAt: DateTime.utc(2026, 9, 20, 9, 30),
          status: SessionStatus.delivered,
          attendanceRecorded: true,
          presentCount: 17,
          enrolledCount: 20,
        ),
        GroupSession(
          id: 's2',
          groupId: 'g1',
          title: 'حديث الأسبوع',
          startsAt: DateTime.utc(2026, 9, 13, 8),
          endsAt: DateTime.utc(2026, 9, 13, 9, 30),
          status: SessionStatus.delivered,
          attendanceRecorded: false,
        ),
      ],
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(
      tester,
      container,
      GroupDetailScreen(groupId: 'g1', now: now),
    );
    await tester.pumpAndSettle();

    expect(find.text('الأشبال 1'), findsOneWidget);
    expect(find.text('17/20'), findsOneWidget);
    expect(find.text('غير مسجَّل'), findsOneWidget);
  });

  testWidgets('the roster shows the health badge as icon only', (tester) async {
    when(() => mocks.groups.fetchGroup('g1')).thenAnswer((_) async => ashbal);
    when(() => mocks.groups.fetchSessions('g1'))
        .thenAnswer((_) async => const []);
    when(
      () => mocks.children.fetchChildren(
        cursor: any(named: 'cursor'),
        groupId: 'g1',
      ),
    ).thenAnswer(
      (_) async => Paginated(
        items: [
          Child(
            id: 'c1',
            fullName: 'سلمى القادري',
            healthAlert: true,
            dateOfBirth: DateTime(2018, 5, 2),
          ),
        ],
        page: const PageInfo.end(),
      ),
    );
    final container = await executiveContainer(mocks);

    await pumpExecutive(
      tester,
      container,
      GroupDetailScreen(groupId: 'g1', now: now),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('القائمة'));
    await tester.pumpAndSettle();

    expect(find.text('سلمى القادري'), findsOneWidget);
    expect(find.byType(HealthAlertBadge), findsOneWidget);
    expect(
      find.byType(Text).evaluate().where((e) {
        final text = (e.widget as Text).data ?? '';
        return text.contains('حساسية');
      }),
      isEmpty,
    );
  });
}
