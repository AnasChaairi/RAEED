import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/features/educator/domain/availability.dart';
import 'package:raeed/features/educator/domain/educator_child.dart';
import 'package:raeed/features/educator/domain/educator_group.dart';
import 'package:raeed/features/educator/domain/educator_session.dart';
import 'package:raeed/features/educator/domain/memory_post.dart';
import 'package:raeed/features/educator/presentation/educator_announcement_screen.dart';
import 'package:raeed/features/educator/presentation/educator_child_screen.dart';
import 'package:raeed/features/educator/presentation/educator_more_screen.dart';
import 'package:raeed/features/educator/presentation/homework_new_screen.dart';
import 'package:raeed/features/educator/presentation/memory_compose_screen.dart';
import 'package:raeed/features/educator/presentation/presence_overview_screen.dart';
import 'package:raeed/features/educator/presentation/session_detail_screen.dart';
import 'package:raeed/features/educator/presentation/sessions_tab.dart';
import 'package:raeed/features/educator/presentation/today_tab.dart';
import 'package:raeed/features/executive/domain/announcement_draft.dart';
import 'package:raeed/features/executive/domain/executive_group.dart';
import 'package:raeed/features/executive/domain/memories_review.dart';

import '../../executive/presentation/executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 26, 9, 40);
  const educatorRoles = {RaeedRole.educator};

  SessionItem session({
    String id = 's1',
    String? title = 'حلقة القرآن — سورة الملك',
    DateTime? startsAt,
    bool hasContent = true,
    SessionStatus status = SessionStatus.planned,
    bool attendanceRecorded = false,
  }) => SessionItem(
    id: id,
    group: const SessionGroupRef(id: 'g1', name: 'الأشبال 1'),
    title: title,
    startsAt: startsAt ?? now.add(const Duration(minutes: 20)),
    endsAt: (startsAt ?? now.add(const Duration(minutes: 20))).add(
      const Duration(hours: 1, minutes: 30),
    ),
    place: 'القاعة 2',
    status: status,
    isCustomized: hasContent,
    hasContent: hasContent,
    materialCount: 3,
    homeworkCount: 1,
    attendanceRecorded: attendanceRecorded,
    summarySent: false,
  );

  SessionDetail detail({SessionItem? item}) => SessionDetail(
    item: item ?? session(),
    objectives: 'حفظ الآيات 6–10',
    enrolledCount: 20,
    guardianCount: 32,
    familyCount: 18,
    materials: const [],
    homework: const [],
    attendance: SessionAttendanceCounts.none,
    presence: const PresenceTallies(yes: 15, late: 1, no: 2, none: 2),
  );

  const roster = [
    RosterChild(
      id: 'c1',
      fullName: 'يوسف الإدريسي',
      hasHealthAlert: true,
      imageRights: ImageRightsLevel.appOnly,
      present: 18,
      expected: 20,
      consecutiveAbsences: 0,
      isNew: false,
    ),
    RosterChild(
      id: 'c2',
      fullName: 'عمر الشرقاوي',
      hasHealthAlert: false,
      imageRights: ImageRightsLevel.notAllowed,
      present: 17,
      expected: 20,
      consecutiveAbsences: 0,
      isNew: false,
    ),
  ];

  setUp(() => mocks = ExecutiveMocks());

  group('Today', () {
    testWidgets(
      'shows the tallies, the way to attendance, and the acknowledgement',
      (tester) async {
        when(() => mocks.educator.fetchToday()).thenAnswer(
          (_) async => TodayView(
            date: now,
            nextSession: NextSession(
              item: session(),
              enrolledCount: 20,
              presence: const PresenceTallies(yes: 15, late: 1, no: 2, none: 2),
              attendance: SessionAttendanceCounts.none,
            ),
            todaySessions: [
              session(),
              session(
                id: 's2',
                title: null,
                hasContent: false,
                startsAt: now.add(const Duration(hours: 6)),
              ),
            ],
            sessionsWithoutContent: [
              session(id: 's2', title: null, hasContent: false),
            ],
            pinnedNotice: const PinnedNotice(
              id: 'a1',
              title: 'يوم مفتوح للأولياء',
              body: 'من 09:30',
              ackRequired: true,
              confirmed: false,
            ),
          ),
        );
        when(() => mocks.educator.confirmRead('a1')).thenAnswer((_) async {});
        final container = await executiveContainer(mocks, roles: educatorRoles);

        await pumpExecutive(tester, container, TodayTab(now: now));
        await tester.pumpAndSettle();

        expect(find.text('15'), findsOneWidget); // confirmed
        expect(find.text('تسجيل الحضور'), findsOneWidget);
        expect(find.textContaining('لم تُضف محتوى'), findsOneWidget);
        expect(find.text('بلا محتوى'), findsOneWidget);

        await tester.tap(find.text('قرأتُ'));
        await tester.pumpAndSettle();
        verify(() => mocks.educator.confirmRead('a1')).called(1);
        expect(find.text('✓ أكّدت القراءة'), findsOneWidget);
      },
    );

    testWidgets('once attendance is recorded the card becomes the summary', (
      tester,
    ) async {
      when(() => mocks.educator.fetchToday()).thenAnswer(
        (_) async => TodayView(
          date: now,
          nextSession: NextSession(
            item: session(attendanceRecorded: true),
            enrolledCount: 20,
            attendance: const SessionAttendanceCounts(
              recorded: true,
              present: 17,
              late: 1,
              excused: 2,
              absent: 0,
            ),
          ),
          todaySessions: const [],
          sessionsWithoutContent: const [],
        ),
      );
      final container = await executiveContainer(mocks, roles: educatorRoles);
      await pumpExecutive(tester, container, TodayTab(now: now));
      await tester.pumpAndSettle();
      expect(find.text('سُجّل حضور الأشبال 1'), findsOneWidget);
      expect(find.text('تسجيل الحضور'), findsNothing);
    });
  });

  group('presence overview', () {
    testWidgets('the reminder goes out once', (tester) async {
      when(() => mocks.sessions.fetchSession('s1'))
          .thenAnswer((_) async => detail());
      when(() => mocks.sessions.fetchPresence('s1')).thenAnswer(
        (_) async => PresenceOverview(
          sessionId: 's1',
          sentAt: now.subtract(const Duration(hours: 14)),
          deadlineAt: now.subtract(const Duration(minutes: 10)),
          enrolledCount: 20,
          tallies: const PresenceTallies(yes: 15, late: 1, no: 2, none: 2),
          groups: const [
            PresenceGroup(
              answer: PresenceAnswerKind.none,
              children: [
                PresenceChild(id: 'c3', fullName: 'سلمى القادري'),
                PresenceChild(id: 'c4', fullName: 'طه الزاوي'),
              ],
            ),
            PresenceGroup(
              answer: PresenceAnswerKind.no,
              children: [
                PresenceChild(
                  id: 'c5',
                  fullName: 'أيوب بناني',
                  reason: 'travel',
                ),
              ],
            ),
          ],
        ),
      );
      when(() => mocks.sessions.remindUnanswered('s1'))
          .thenAnswer((_) async => 2);
      final container = await executiveContainer(mocks, roles: educatorRoles);

      await pumpExecutive(
        tester,
        container,
        const PresenceOverviewScreen(sessionId: 's1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('سلمى القادري'), findsOneWidget);
      expect(find.text('سفر'), findsOneWidget);
      await tester.tap(find.text('تذكير من لم يردّ (2)'));
      await tester.pumpAndSettle();
      verify(() => mocks.sessions.remindUnanswered('s1')).called(1);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '✓ أُرسل التذكير'),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('sessions', () {
    testWidgets('the week lists generated sessions with their state', (
      tester,
    ) async {
      when(
        () => mocks.sessions.fetchSessions(
          from: any(named: 'from'),
          to: any(named: 'to'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) async => [
          session(),
          session(
            id: 's2',
            title: null,
            hasContent: false,
            startsAt: now.add(const Duration(days: 2)),
          ),
        ],
      );
      final container = await executiveContainer(mocks, roles: educatorRoles);
      await pumpExecutive(tester, container, SessionsTab(now: now));
      await tester.pumpAndSettle();
      expect(find.text('حلقة القرآن — سورة الملك'), findsOneWidget);
      expect(find.text('بلا محتوى'), findsOneWidget);
      expect(find.textContaining('أُنشئت من الجدول'), findsOneWidget);
    });

    testWidgets('cancelling asks for a reason and tells everyone', (
      tester,
    ) async {
      when(() => mocks.sessions.fetchSession('s1'))
          .thenAnswer((_) async => detail());
      when(() => mocks.sessions.changeSession('s1', any()))
          .thenAnswer((_) async => (notifiedCount: 35, guardianCount: 32));
      final container = await executiveContainer(mocks, roles: educatorRoles);
      await pumpExecutive(
        tester,
        container,
        SessionDetailScreen(sessionId: 's1', now: now),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('إلغاء أو تأجيل الجلسة'));
      await tester.pumpAndSettle();
      final cta = find.widgetWithText(FilledButton, 'إلغاء وإبلاغ الجميع');
      expect(tester.widget<FilledButton>(cta).onPressed, isNull);
      expect(find.textContaining('32'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'غياب اضطراري');
      await tester.pumpAndSettle();
      await tester.tap(cta);
      await tester.pumpAndSettle();
      final draft =
          verify(() => mocks.sessions.changeSession('s1', captureAny()))
                  .captured
                  .single
              as CancelDraft;
      expect(draft.mode, CancelMode.cancel);
      expect(draft.reason, 'غياب اضطراري');
      expect(find.textContaining('35'), findsOneWidget);
    });
  });

  group('homework', () {
    testWidgets(
      'specific children need at least one; the whole group sends null targets',
      (tester) async {
        when(() => mocks.sessions.fetchSession('s1'))
            .thenAnswer((_) async => detail());
        when(() => mocks.sessions.fetchRoster('g1'))
            .thenAnswer((_) async => roster);
        when(() => mocks.sessions.createHomework('s1', any())).thenAnswer(
          (_) async => HomeworkItem(
            id: 'h1',
            sessionId: 's1',
            instructions: 'x',
            dueAt: now,
            targetCount: 20,
            doneCount: 0,
            createdAt: now,
          ),
        );
        final container = await executiveContainer(mocks, roles: educatorRoles);
        await pumpExecutive(
          tester,
          container,
          HomeworkNewScreen(sessionId: 's1', now: now),
          routes: {'/sessions/s1': const Text('session')},
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).at(1),
          'اقرأ الآيات مرتين',
        );
        await tester.tap(find.byType(FilledButton).last);
        await tester.pumpAndSettle();
        // The due date was not picked yet: nothing sent.
        verifyNever(() => mocks.sessions.createHomework(any(), any()));

        await tester.tap(find.text('أطفال محددون'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FilledButton).last);
        await tester.pumpAndSettle();
        expect(find.text('اختر طفلًا واحدًا على الأقل'), findsOneWidget);
        verifyNever(() => mocks.sessions.createHomework(any(), any()));
      },
    );
  });

  group('memories', () {
    testWidgets(
      'a not_allowed child cannot be tagged, and the post carries the tags',
      (tester) async {
        when(() => mocks.memories.fetchAlbums()).thenAnswer(
          (_) async => const [
            MemoriesAlbum(
              id: 'al1',
              title: 'حلقات القرآن',
              postCount: 9,
              groupName: 'الأشبال 1',
              moderationMode: ModerationMode.approveBeforePublish,
            ),
          ],
        );
        when(() => mocks.groups.fetchGroups()).thenAnswer(
          (_) async => const [
            ExecutiveGroup(
              id: 'g1',
              name: 'الأشبال 1',
              categoryName: 'الأشبال',
              enrolledCount: 20,
            ),
          ],
        );
        when(() => mocks.sessions.fetchRoster('g1'))
            .thenAnswer((_) async => roster);
        when(() => mocks.educatorMemories.createPost(any())).thenAnswer(
          (_) async => MyPost(
            id: 'p1',
            albumTitle: 'x',
            mediaCount: 1,
            tagCount: 1,
            createdAt: now,
            state: PostState.pending,
          ),
        );
        final container = await executiveContainer(mocks, roles: educatorRoles);
        await pumpExecutive(
          tester,
          container,
          const MemoryComposeScreen(),
          routes: {'/home': const Text('home')},
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('حلقات القرآن').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('عمر الشرقاوي'));
        await tester.pumpAndSettle();
        expect(find.textContaining('لا يمكن وسم عمر الشرقاوي'), findsOneWidget);
        await tester.tap(find.text('يوسف الإدريسي'));
        await tester.pumpAndSettle();
        expect(find.text('1 موسوم'), findsOneWidget);

        // No photo yet: refused in place.
        await tester.tap(find.text('إرسال للاعتماد'));
        await tester.pumpAndSettle();
        expect(find.text('أضف صورة واحدة على الأقل'), findsOneWidget);
        verifyNever(() => mocks.educatorMemories.createPost(any()));
      },
    );
  });

  group('announcement', () {
    testWidgets('needs a group and publishes to it with the read request', (
      tester,
    ) async {
      when(() => mocks.announcements.fetchReach()).thenAnswer(
        (_) async => const AudienceReach(
          allCount: 61,
          parentsCount: 61,
          educatorsCount: 2,
          categories: [],
          groups: [
            AudienceCategory(id: 'g1', name: 'الأشبال 1', guardianCount: 32),
            AudienceCategory(id: 'g2', name: 'الصغار 1', guardianCount: 29),
          ],
        ),
      );
      when(() => mocks.announcements.publish(any()))
          .thenAnswer((_) async => 'a1');
      final container = await executiveContainer(mocks, roles: educatorRoles);
      await pumpExecutive(
        tester,
        container,
        const EducatorAnnouncementScreen(),
        routes: {'/home': const Text('home')},
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('32'), findsOneWidget);
      await tester.tap(find.text('الأشبال 1'));
      await tester.pumpAndSettle();
      expect(find.text('اختر مجموعة واحدة على الأقل'), findsOneWidget);
      await tester.tap(find.text('الصغار 1'));
      await tester.enterText(
        find.byType(TextField).first,
        'ملابس رياضية يوم السبت',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('نشر'));
      await tester.pumpAndSettle();
      final draft =
          verify(() => mocks.announcements.publish(captureAny()))
                  .captured
                  .single
              as AnnouncementDraft;
      expect(draft.audience.mode, AudienceMode.groups);
      expect(draft.audience.groupIds, {'g2'});
      expect(draft.ackRequired, isTrue);
    });
  });

  group('child', () {
    testWidgets('the emergency call is recorded and the number never renders', (
      tester,
    ) async {
      when(() => mocks.educatorChildren.fetchProfile('c1')).thenAnswer(
        (_) async => const EducatorChildProfile(
          id: 'c1',
          fullName: 'يوسف الإدريسي',
          hasHealthAlert: true,
          imageRights: ImageRightsLevel.appOnly,
          homeworkDone: 7,
          homeworkTotal: 8,
          seasonAttendance: AttendanceRatio(present: 18, expected: 20),
          guardians: [
            EducatorGuardian(
              id: 'p1',
              displayName: 'سعاد الإدريسي',
              relationship: 'mother',
              account: AccountStatus.active,
              isEmergencyContact: false,
            ),
            EducatorGuardian(
              id: 'p2',
              displayName: 'نادية الإدريسي',
              relationship: 'emergency',
              account: AccountStatus.pending,
              isEmergencyContact: true,
            ),
          ],
          conversationId: 'conv-1',
        ),
      );
      when(() => mocks.educatorChildren.emergencyCall('c1')).thenAnswer(
        (_) async => EmergencyCall(
          guardianName: 'نادية الإدريسي',
          phone: '+212600000009',
          recordedAt: now,
        ),
      );
      String? dialled;
      final container = await executiveContainer(mocks, roles: educatorRoles);
      await pumpExecutive(
        tester,
        container,
        EducatorChildScreen(
          childId: 'c1',
          now: now,
          dial: (phone) async => dialled = phone,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('18/20'), findsOneWidget);
      expect(find.text('7/8'), findsOneWidget);
      await tester.tap(find.text('☏ اتصال'));
      await tester.pumpAndSettle();
      verify(() => mocks.educatorChildren.emergencyCall('c1')).called(1);
      expect(dialled, '+212600000009');
      expect(find.textContaining('600000009'), findsNothing);
    });
  });

  group('More', () {
    testWidgets('an availability preset is saved', (tester) async {
      when(() => mocks.educator.fetchAvailability()).thenAnswer(
        (_) async => const AvailabilityWindow(start: '09:00', end: '20:00'),
      );
      when(() => mocks.educator.setAvailability(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as AvailabilityWindow,
      );
      final container = await executiveContainer(mocks, roles: educatorRoles);
      await pumpExecutive(tester, container, const EducatorMoreScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('14:00–21:00'));
      await tester.pumpAndSettle();
      verify(
        () => mocks.educator.setAvailability(
          const AvailabilityWindow(start: '14:00', end: '21:00'),
        ),
      ).called(1);
      expect(find.text('حُفظت ساعات التواجد'), findsOneWidget);
    });
  });
}
