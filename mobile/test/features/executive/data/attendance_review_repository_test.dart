import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/data/attendance_review_repository_api.dart';
import 'package:raeed/features/executive/domain/attendance_review.dart';

import 'stub_adapter.dart';

void main() {
  late StubAdapter adapter;
  late ApiAttendanceReviewRepository repository;

  setUp(() {
    adapter = StubAdapter();
    repository = ApiAttendanceReviewRepository(stubClient(adapter));
  });

  test('a corrected child carries its whole chain, oldest first', () async {
    adapter.respond(200, {
      'session': {
        'id': 's1',
        'group_id': 'g1',
        'group_name': 'الأشبال 1',
        'starts_at': '2026-09-20T09:00:00Z',
      },
      'data': [
        {
          'child_id': 'c1',
          'child': {'full_name': 'سلمى القادري', 'health_alert': true},
          'presence_answer': null,
          'records': [
            {
              'id': 'r2',
              'status': 'excused',
              'recorded_by': {'display_name': 'أنس'},
              'recorded_at': '2026-09-20T10:43:00Z',
              'corrected_from': 'r1',
              'note': 'اتصلت الأم',
            },
            {
              'id': 'r1',
              'status': 'absent',
              'recorded_by': {'display_name': 'عبد الله'},
              'recorded_at': '2026-09-20T09:11:00Z',
              'device': 'Android',
              'guardians_notified': true,
            },
          ],
        },
        {
          'child_id': 'c2',
          'child': {'full_name': 'يوسف', 'health_alert': false},
          'presence_answer': {'answer': 'yes'},
          'status': 'present',
          'recorded_by': {'display_name': 'عبد الله'},
          'recorded_at': '2026-09-20T09:11:00Z',
        },
        {
          'child_id': 'c3',
          'child': {'full_name': 'آدم', 'health_alert': false},
        },
      ],
    });

    final sheet = await repository.fetchSheet(sessionId: 's1', groupId: 'g1');

    final salma = sheet.rows[0];
    expect(salma.isCorrected, isTrue);
    expect(salma.records.map((r) => r.id), ['r1', 'r2']);
    expect(salma.currentStatus, AttendanceStatus.excused);
    expect(salma.records.first.guardiansNotified, isTrue);
    expect(salma.records.last.correctedFromId, 'r1');
    expect(salma.hasHealthAlert, isTrue);

    // A flat record decodes as a one-link chain.
    final yousef = sheet.rows[1];
    expect(yousef.records.single.status, AttendanceStatus.present);
    expect(yousef.presenceAnswer, PresenceAnswerValue.yes);

    // No mark at all.
    expect(sheet.rows[2].isUnmarked, isTrue);

    expect(sheet.countOf(AttendanceStatus.excused), 1);
    expect(sheet.countOf(AttendanceStatus.absent), 0);
    expect(sheet.unmarkedCount, 1);
    // Recorded-by is the earliest original mark, not the correction.
    expect(sheet.recordedByName, 'عبد الله');
    expect(sheet.groupName, 'الأشبال 1');
  });

  test('a correction is a new record pointing at the old one', () async {
    adapter.respond(200, {
      'applied': ['r3'],
    });

    await repository.correct(
      sessionId: 's1',
      draft: AttendanceCorrectionDraft(
        childId: 'c1',
        status: AttendanceStatus.excused,
        correctedAt: DateTime.utc(2026, 9, 20, 11, 43),
        correctedFromId: 'r1',
        note: ' اتصلت الأم ',
      ),
    );

    expect(adapter.lastRequest!.method, 'PATCH');
    expect(adapter.lastRequest!.path, endsWith('/sessions/s1/attendance'));
    expect(adapter.lastBody, {
      'records': [
        {
          'child_id': 'c1',
          'status': 'excused',
          'recorded_at_client': '2026-09-20T11:43:00.000Z',
          'corrected_from': 'r1',
          'note': 'اتصلت الأم',
        },
      ],
    });
  });
}
