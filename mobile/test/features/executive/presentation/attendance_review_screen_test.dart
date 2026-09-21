import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/features/executive/domain/attendance_review.dart';
import 'package:raeed/features/executive/presentation/attendance_review_screen.dart';
import 'package:raeed/features/executive/presentation/widgets/correction_sheet.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 20, 11, 45);

  final original = AttendanceRecordEntry(
    id: 'r1',
    status: AttendanceStatus.absent,
    recordedByName: 'عبد الله',
    recordedAt: DateTime.utc(2026, 9, 20, 9, 11),
    deviceLabel: 'Android',
    guardiansNotified: true,
  );
  final correction = AttendanceRecordEntry(
    id: 'r2',
    status: AttendanceStatus.excused,
    recordedByName: 'أنس',
    recordedAt: DateTime.utc(2026, 9, 20, 10, 43),
    correctedFromId: 'r1',
  );

  AttendanceReviewSheet sheet({required bool corrected}) =>
      AttendanceReviewSheet(
        sessionId: 's1',
        groupId: 'g1',
        groupName: 'الأشبال 1',
        startsAt: DateTime.utc(2026, 9, 20, 9),
        recordedByName: 'عبد الله',
        recordedAt: DateTime.utc(2026, 9, 20, 9, 11),
        rows: [
          const AttendanceReviewRow(
            childId: 'c-yousef',
            childName: 'يوسف الإدريسي',
            presenceAnswer: PresenceAnswerValue.yes,
          ).withRecord(
            AttendanceRecordEntry(
              id: 'r0',
              status: AttendanceStatus.present,
              recordedByName: 'عبد الله',
              recordedAt: DateTime.utc(2026, 9, 20, 9, 11),
            ),
          ),
          AttendanceReviewRow(
            childId: 'c-salma',
            childName: 'سلمى القادري',
            hasHealthAlert: true,
            records: corrected ? [original, correction] : [original],
          ),
        ],
      );

  setUp(() {
    registerFallbackValue(
      AttendanceCorrectionDraft(
        childId: '',
        status: AttendanceStatus.present,
        correctedAt: now,
      ),
    );
    mocks = ExecutiveMocks();
  });

  Future<void> pump(WidgetTester tester) async {
    final container = await executiveContainer(mocks);
    await pumpExecutive(
      tester,
      container,
      AttendanceReviewScreen(sessionId: 's1', groupId: 'g1', now: now),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the sheet, its counts and who recorded it', (
    tester,
  ) async {
    when(
      () => mocks.attendanceReview.fetchSheet(sessionId: 's1', groupId: 'g1'),
    ).thenAnswer((_) async => sheet(corrected: false));
    await pump(tester);

    expect(find.text('حضور الأشبال 1'), findsOneWidget);
    expect(find.textContaining('سجّله عبد الله'), findsOneWidget);
    expect(find.text('حاضر'), findsOneWidget);
    expect(find.text('غائب'), findsOneWidget);
    expect(find.text('أكّد الولي الحضور'), findsOneWidget);
    expect(find.text('بلا رد'), findsOneWidget);
    // No trail before any correction.
    expect(find.textContaining('صُحّح إلى'), findsNothing);
  });

  testWidgets('a corrected child shows both records as a visible trail', (
    tester,
  ) async {
    when(
      () => mocks.attendanceReview.fetchSheet(sessionId: 's1', groupId: 'g1'),
    ).thenAnswer((_) async => sheet(corrected: true));
    await pump(tester);

    expect(find.textContaining('سُجّل غائب — عبد الله'), findsOneWidget);
    expect(find.textContaining('أُبلغ الأولياء'), findsOneWidget);
    expect(find.textContaining('صُحّح إلى غياب بعذر — أنس'), findsOneWidget);
    expect(find.textContaining('يشير إلى #r1'), findsOneWidget);
    // The current status is the correction's, the original is not lost.
    expect(find.text('غياب بعذر'), findsOneWidget);
  });

  testWidgets('a correction is saved as a new record pointing at the old one', (
    tester,
  ) async {
    var calls = 0;
    when(
      () => mocks.attendanceReview.fetchSheet(sessionId: 's1', groupId: 'g1'),
    ).thenAnswer((_) async => sheet(corrected: calls++ > 0));
    when(
      () => mocks.attendanceReview.correct(
        sessionId: any(named: 'sessionId'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async {});
    await pump(tester);

    await tester.tap(findSemanticsLabel('تصحيح — سلمى القادري'));
    await tester.pumpAndSettle();
    expect(find.byType(CorrectionSheet), findsOneWidget);
    expect(find.text('تصحيح حضور سلمى القادري'), findsOneWidget);
    expect(find.textContaining('يُسجَّل باسمك'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(CorrectionSheet),
        matching: find.text('غياب بعذر'),
      ),
    );
    await tester.enterText(find.byType(TextField), 'اتصلت الأم');
    await tester.tap(find.text('حفظ التصحيح'));
    await tester.pumpAndSettle();

    final draft =
        verify(
              () => mocks.attendanceReview.correct(
                sessionId: 's1',
                draft: captureAny(named: 'draft'),
              ),
            ).captured.single
            as AttendanceCorrectionDraft;
    expect(draft.childId, 'c-salma');
    expect(draft.status, AttendanceStatus.excused);
    expect(draft.correctedFromId, 'r1');
    expect(draft.note, 'اتصلت الأم');

    // The trail shown afterwards is the server's, re-read.
    expect(calls, 2);
    expect(find.textContaining('صُحّح إلى غياب بعذر'), findsOneWidget);
  });
}
