import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/application/session_attendance_state.dart';
import 'package:raeed/features/executive/domain/dashboard_overview.dart';

void main() {
  final startsAt = DateTime.utc(2026, 9, 20, 9);
  final endsAt = DateTime.utc(2026, 9, 20, 10, 30);

  TodaySession session({required bool recorded}) => TodaySession(
    id: 's1',
    groupId: 'g1',
    groupName: 'الأشبال 1',
    startsAt: startsAt,
    endsAt: endsAt,
    attendanceRecorded: recorded,
  );

  test('a recorded session is recorded regardless of the clock', () {
    expect(
      sessionAttendanceStateAt(
        session(recorded: true),
        DateTime.utc(2026, 9, 20, 8),
      ),
      SessionAttendanceState.recorded,
    );
  });

  test('before it starts, no records means upcoming, not missing', () {
    expect(
      sessionAttendanceStateAt(
        session(recorded: false),
        DateTime.utc(2026, 9, 20, 8, 59),
      ),
      SessionAttendanceState.upcoming,
    );
  });

  test('while it runs it is live', () {
    expect(
      sessionAttendanceStateAt(
        session(recorded: false),
        DateTime.utc(2026, 9, 20, 9, 30),
      ),
      SessionAttendanceState.live,
    );
  });

  test('after it ends with no records it is not recorded', () {
    expect(
      sessionAttendanceStateAt(
        session(recorded: false),
        DateTime.utc(2026, 9, 20, 10, 30),
      ),
      SessionAttendanceState.notRecorded,
    );
  });

  test('a local-time clock is compared in UTC', () {
    // 09:30 UTC expressed as a local DateTime elsewhere must still be live.
    final local = DateTime.utc(2026, 9, 20, 9, 30).toLocal();
    expect(
      sessionAttendanceStateAt(session(recorded: false), local),
      SessionAttendanceState.live,
    );
  });
}
