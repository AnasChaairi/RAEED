import '../domain/dashboard_overview.dart';

/// Resolves how a session's attendance reads at [now].
///
/// Only the *presentation* of a state the server already holds: whether a
/// session with no records is "not recorded" or merely "upcoming" depends on
/// the clock, and the clock is the one thing the payload cannot carry. The
/// escalation itself (educator reminder at +30min, executive visibility
/// beyond that — `RAEED-20`) is a server job and is not re-derived here.
SessionAttendanceState sessionAttendanceStateAt(
  TodaySession session,
  DateTime now,
) {
  final utc = now.toUtc();
  if (session.attendanceRecorded) return SessionAttendanceState.recorded;
  if (utc.isBefore(session.startsAt)) return SessionAttendanceState.upcoming;
  if (utc.isBefore(session.endsAt)) return SessionAttendanceState.live;
  return SessionAttendanceState.notRecorded;
}
