import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/theme/design_tokens.gen.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/attendance/domain/attendance_repository.dart';
import 'package:raeed/features/attendance/domain/attendance_sheet.dart';
import 'package:raeed/features/attendance/domain/attendance_status.dart';
import 'package:raeed/features/attendance/domain/presence_answer.dart';
import 'package:raeed/features/attendance/presentation/attendance_providers.dart';
import 'package:raeed/features/attendance/presentation/attendance_screen.dart';
import 'package:raeed/features/attendance/presentation/widgets/status_selector.dart';
import 'package:raeed/features/children/presentation/widgets/health_alert_badge.dart';
import 'package:raeed/shared/widgets/offline_banner.dart';
import 'package:raeed/shared/widgets/skeleton.dart';

class _MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  late _MockAttendanceRepository repository;

  const sessionId = 'session-1';
  const groupId = 'group-1';

  AttendanceEntry entry(
    String id,
    String name, {
    AttendanceStatus? serverStatus,
    AttendanceStatus? pendingStatus,
    AttendanceConflict? conflict,
    bool hasHealthAlert = false,
    PresenceAnswerValue? presenceAnswer,
  }) => AttendanceEntry(
    childId: id,
    childName: name,
    hasHealthAlert: hasHealthAlert,
    presenceAnswer: presenceAnswer,
    serverStatus: serverStatus,
    pendingStatus: pendingStatus,
    pendingRecordedAtClient: pendingStatus == null
        ? null
        : DateTime.utc(2026, 9, 13, 9, 5),
    conflict: conflict,
  );

  AttendanceSheet sheetOf(
    List<AttendanceEntry> entries, {
    bool isFromCache = false,
  }) => AttendanceSheet(
    sessionId: sessionId,
    groupId: groupId,
    groupName: 'الأشبال',
    entries: entries,
    isFromCache: isFromCache,
  );

  /// One status button, by its glyph — the row draws no text, so the icon is
  /// what a reader of this screen actually distinguishes them by.
  Finder segmentFor(WidgetTester tester, AttendanceStatus status) =>
      find.ancestor(
        of: find.byIcon(iconForStatus(status)),
        matching: find.byType(InkWell),
      );

  setUpAll(() {
    registerFallbackValue(AttendanceStatus.present);
    registerFallbackValue(DateTime.utc(2026));
  });

  setUp(() {
    repository = _MockAttendanceRepository();
    when(repository.watchQueueDepth).thenAnswer((_) => Stream.value(0));
    when(
      () => repository.mark(
        sessionId: any(named: 'sessionId'),
        childId: any(named: 'childId'),
        status: any(named: 'status'),
        recordedAtClient: any(named: 'recordedAtClient'),
      ),
    ).thenAnswer((_) async {});
    when(() => repository.sync(sessionId: any(named: 'sessionId')))
        .thenAnswer((_) async => SyncOutcome.idle);
  });

  /// Stubs the sheet the screen will show.
  void stubSheet(AttendanceSheet sheet) {
    when(
      () => repository.loadSheet(
        sessionId: any(named: 'sessionId'),
        groupId: any(named: 'groupId'),
      ),
    ).thenAnswer((_) async => sheet);
    when(
      () => repository.watchSheet(
        sessionId: any(named: 'sessionId'),
        groupId: any(named: 'groupId'),
      ),
    ).thenAnswer((_) => const Stream.empty());
  }

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    int queueDepth = 0,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    when(repository.watchQueueDepth)
        .thenAnswer((_) => Stream.value(queueDepth));

    final container = ProviderContainer(
      overrides: [attendanceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: AppL10n.localizationsDelegates,
            theme: RaeedTheme.light(const Locale('ar')),
            home: const AttendanceScreen(
              sessionId: sessionId,
              groupId: groupId,
            ),
          ),
        ),
      ),
    );
    return container;
  }

  group('loading', () {
    testWidgets('shows skeleton rows, never a bare spinner', (tester) async {
      when(
        () => repository.loadSheet(
          sessionId: any(named: 'sessionId'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => sheetOf([entry('child-1', 'آدم')]),
        ),
      );
      when(
        () => repository.watchSheet(
          sessionId: any(named: 'sessionId'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      await pumpScreen(tester);
      await tester.pump();

      expect(find.byType(SkeletonBox), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();
    });
  });

  group('empty group', () {
    testWidgets('says so plainly', (tester) async {
      stubSheet(sheetOf(const []));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(AttendanceScreen)));
      expect(find.text(l10n.attendanceEmptyGroup), findsOneWidget);
      expect(find.byType(AttendanceStatusSelector), findsNothing);
    });
  });

  group('marking', () {
    testWidgets('renders one selector per child', (tester) async {
      stubSheet(sheetOf([entry('child-1', 'آدم'), entry('child-2', 'مريم')]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceStatusSelector), findsNWidgets(2));
    });

    testWidgets('one tap marks that status and records the tap time', (
      tester,
    ) async {
      stubSheet(sheetOf([entry('child-1', 'آدم')]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(segmentFor(tester, AttendanceStatus.present));
      await tester.pumpAndSettle();

      final captured = verify(
        () => repository.mark(
          sessionId: sessionId,
          childId: 'child-1',
          status: captureAny(named: 'status'),
          recordedAtClient: captureAny(named: 'recordedAtClient'),
        ),
      ).captured;

      expect(captured[0], AttendanceStatus.present);
      expect(
        captured[1],
        isA<DateTime>().having((d) => d.isUtc, 'isUtc', isTrue),
        reason:
            'recorded_at_client is the moment of the tap, in UTC — the '
            'conflict rule compares it against the server',
      );
    });

    testWidgets('any status is one tap from any other', (tester) async {
      // The point of discrete buttons over a cycling chip: correcting a
      // present mark to absent costs one tap, not three.
      stubSheet(
        sheetOf([
          entry('child-1', 'آدم', serverStatus: AttendanceStatus.present),
        ]),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.tap(segmentFor(tester, AttendanceStatus.absent));
      await tester.pumpAndSettle();

      final captured = verify(
        () => repository.mark(
          sessionId: any(named: 'sessionId'),
          childId: any(named: 'childId'),
          status: captureAny(named: 'status'),
          recordedAtClient: any(named: 'recordedAtClient'),
        ),
      ).captured;
      expect(captured.single, AttendanceStatus.absent);
    });

    testWidgets('"mark remaining present" leaves deliberate marks alone', (
      tester,
    ) async {
      // The one way this button could lose data is by overwriting a mark
      // someone made on purpose.
      stubSheet(
        sheetOf([
          entry('child-1', 'آدم', serverStatus: AttendanceStatus.absent),
          entry('child-2', 'مريم'),
          entry('child-3', 'يوسف'),
        ]),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(AttendanceScreen)));
      await tester.tap(find.text(l10n.attendanceMarkRemainingPresent));
      await tester.pumpAndSettle();

      final markedChildren = verify(
        () => repository.mark(
          sessionId: any(named: 'sessionId'),
          childId: captureAny(named: 'childId'),
          status: any(named: 'status'),
          recordedAtClient: any(named: 'recordedAtClient'),
        ),
      ).captured;

      expect(markedChildren, containsAll(['child-2', 'child-3']));
      expect(
        markedChildren,
        isNot(contains('child-1')),
        reason: 'the absent child was marked deliberately',
      );
    });
  });

  group('offline', () {
    testWidgets('shows reassurance, and submission stays enabled', (
      tester,
    ) async {
      // The spec: the offline state "never blocks submission".
      stubSheet(sheetOf([entry('child-1', 'آدم')], isFromCache: true));

      await pumpScreen(tester, queueDepth: 2);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(AttendanceScreen)));
      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text(l10n.attendanceOfflineSaved), findsWidgets);

      final submit = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, l10n.attendanceSubmit),
      );
      expect(
        submit.onPressed,
        isNotNull,
        reason: 'being offline must never disable submit',
      );
    });

    testWidgets('a queued mark shows as pending, not as an error', (
      tester,
    ) async {
      stubSheet(
        sheetOf([
          entry('child-1', 'آدم', pendingStatus: AttendanceStatus.absent),
        ]),
      );

      await pumpScreen(tester, queueDepth: 1);
      await tester.pumpAndSettle();

      final selector = tester.widget<AttendanceStatusSelector>(
        find.byType(AttendanceStatusSelector),
      );
      expect(selector.isPending, isTrue);
      expect(selector.status, AttendanceStatus.absent);
    });
  });

  group('conflict', () {
    testWidgets('stays on the row rather than passing in a snackbar', (
      tester,
    ) async {
      stubSheet(
        sheetOf([
          entry(
            'child-1',
            'آدم',
            conflict: AttendanceConflict(
              childId: 'child-1',
              attemptedStatus: AttendanceStatus.absent,
              attemptedRecordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
              serverStatus: AttendanceStatus.present,
              serverRecordedAt: DateTime.utc(2026, 9, 13, 9, 7),
            ),
          ),
        ]),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(AttendanceScreen)));
      expect(find.text(l10n.attendanceConflictTitle), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('offers both sides, and keeping mine re-queues a correction', (
      tester,
    ) async {
      when(
        () => repository.keepLocalMark(
          sessionId: any(named: 'sessionId'),
          childId: any(named: 'childId'),
          correctedAt: any(named: 'correctedAt'),
        ),
      ).thenAnswer((_) async {});

      stubSheet(
        sheetOf([
          entry(
            'child-1',
            'آدم',
            conflict: AttendanceConflict(
              childId: 'child-1',
              attemptedStatus: AttendanceStatus.absent,
              attemptedRecordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
              serverStatus: AttendanceStatus.present,
              serverRecordedAt: DateTime.utc(2026, 9, 13, 9, 7),
            ),
          ),
        ]),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(AttendanceScreen)));
      await tester.tap(find.text(l10n.attendanceConflictTitle));
      await tester.pumpAndSettle();

      // Both sides are named, so the educator is choosing, not guessing.
      expect(find.text(l10n.attendanceConflictKeepMine), findsOneWidget);
      expect(find.text(l10n.attendanceConflictKeepServer), findsOneWidget);

      await tester.tap(find.text(l10n.attendanceConflictKeepMine));
      await tester.pumpAndSettle();

      verify(
        () => repository.keepLocalMark(
          sessionId: sessionId,
          childId: 'child-1',
          correctedAt: any(named: 'correctedAt'),
        ),
      ).called(1);
    });

    testWidgets('keeping the server record drops this device\'s mark', (
      tester,
    ) async {
      when(
        () => repository.keepServerRecord(
          sessionId: any(named: 'sessionId'),
          childId: any(named: 'childId'),
        ),
      ).thenAnswer((_) async {});

      stubSheet(
        sheetOf([
          entry(
            'child-1',
            'آدم',
            conflict: AttendanceConflict(
              childId: 'child-1',
              attemptedStatus: AttendanceStatus.absent,
              attemptedRecordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
              serverStatus: AttendanceStatus.present,
              serverRecordedAt: DateTime.utc(2026, 9, 13, 9, 7),
            ),
          ),
        ]),
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(AttendanceScreen)));
      await tester.tap(find.text(l10n.attendanceConflictTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.attendanceConflictKeepServer));
      await tester.pumpAndSettle();

      verify(
        () => repository.keepServerRecord(
          sessionId: sessionId,
          childId: 'child-1',
        ),
      ).called(1);
    });
  });

  group('health alert', () {
    testWidgets('is icon-only, with no health text on the row', (tester) async {
      // An attendance list is read in a classroom with parents at the door.
      stubSheet(sheetOf([entry('child-1', 'آدم', hasHealthAlert: true)]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(HealthAlertBadge), findsOneWidget);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join(' ');
      for (final leak in ['حساسية', 'allergy', 'دواء', 'asthma']) {
        expect(texts, isNot(contains(leak)));
      }
    });
  });

  group('accessibility', () {
    testWidgets('every status button meets the primary-action target', (
      tester,
    ) async {
      stubSheet(sheetOf([entry('child-1', 'آدم')]));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      for (final status in AttendanceStatusSelector.fastStatuses) {
        final size = tester.getSize(segmentFor(tester, status));
        expect(
          size.height,
          greaterThanOrEqualTo(RaeedTouchTarget.primaryActionsPx),
          reason: 'buttons are tapped repeatedly, at speed, one-handed',
        );
        expect(size.width, greaterThanOrEqualTo(RaeedTouchTarget.primaryActionsPx));
      }
    });

    testWidgets('the row holds up at 130% text scaling', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      stubSheet(
        sheetOf([
          entry(
            'child-1',
            'عبد الرحمن بن محمد الإدريسي',
            hasHealthAlert: true,
            serverStatus: AttendanceStatus.excused,
          ),
          entry('child-2', 'مريم'),
        ]),
      );

      await pumpScreen(tester, textScaler: const TextScaler.linear(1.3));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
