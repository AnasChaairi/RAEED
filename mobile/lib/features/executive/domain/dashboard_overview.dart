import 'package:meta/meta.dart';

/// How loudly an alert asks for the executive's attention.
///
/// Declaration order is severity order: the dashboard sorts by it, and the
/// brief is explicit that this screen "escalates by colour and shape, never by
/// making the reader compare numbers".
enum AlertSeverity {
  /// A child may be unaccounted for, or a safeguarding signal fired.
  danger('danger'),

  /// Something is drifting — over capacity, a delivery not confirmed.
  warning('warning'),

  /// Needs a decision, not a rescue — approvals, reports.
  info('info');

  const AlertSeverity(this.wireValue);

  /// The value as the API sends it.
  final String wireValue;
}

/// Where tapping an alert takes the executive.
///
/// Mirrors the tabs of the executive shell rather than a URL, so the server
/// can name a destination without knowing the app's routing table.
enum AlertDestination {
  groups('groups'),
  memories('memories'),
  messages('messages'),
  announcements('announcements'),
  notifications('notifications');

  const AlertDestination(this.wireValue);

  final String wireValue;
}

/// One card in the "needs your attention" panel.
@immutable
class DashboardAlert {
  const DashboardAlert({
    required this.id,
    required this.severity,
    required this.text,
    required this.destination,
    required this.raisedAt,
    this.groupId,
    this.sessionId,
  });

  final String id;
  final AlertSeverity severity;

  /// Already localised by the server, which knows the branch's language.
  final String text;

  final AlertDestination destination;

  /// When the condition was detected, in UTC. Newer first within a severity.
  final DateTime raisedAt;

  /// The group this is about, when there is one — lets a tap open it.
  final String? groupId;

  /// The session this is about, when there is one.
  final String? sessionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardAlert &&
          other.id == id &&
          other.severity == severity &&
          other.text == text &&
          other.destination == destination &&
          other.raisedAt == raisedAt &&
          other.groupId == groupId &&
          other.sessionId == sessionId;

  @override
  int get hashCode => Object.hash(
    id,
    severity,
    text,
    destination,
    raisedAt,
    groupId,
    sessionId,
  );
}

/// The four headline counts (`DSH-01`).
enum StatKind { children, families, groups, educators }

/// One stat tile.
@immutable
class DashboardStat {
  const DashboardStat({required this.kind, required this.value, this.delta});

  final StatKind kind;

  /// The count. Zero is a value, not an empty state.
  final int value;

  /// Change since the previous period, when the server computed one.
  final int? delta;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardStat &&
          other.kind == kind &&
          other.value == value &&
          other.delta == delta;

  @override
  int get hashCode => Object.hash(kind, value, delta);
}

/// This week's attendance, with the trailing weeks for the bar strip.
@immutable
class WeeklyAttendance {
  const WeeklyAttendance({
    required this.presentCount,
    required this.expectedCount,
    required this.weeklyRates,
    this.deltaPoints,
  });

  /// Marks that were `present` or `late` this week.
  final int presentCount;

  /// Marks expected this week — every enrolled child per delivered session.
  final int expectedCount;

  /// Percent attendance for the trailing weeks, oldest first, this week last.
  final List<int> weeklyRates;

  /// Change in percentage points against last week, when known.
  final int? deltaPoints;

  /// This week's rate, or null when there is too little data to claim one.
  int? get ratePercent =>
      expectedCount == 0 ? null : (presentCount * 100 / expectedCount).round();
}

/// A session happening today, as the dashboard lists it.
@immutable
class TodaySession {
  const TodaySession({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.startsAt,
    required this.endsAt,
    required this.attendanceRecorded,
    this.title,
    this.educatorName,
  });

  final String id;
  final String groupId;
  final String groupName;

  /// UTC, converted for display exactly once at the widget.
  final DateTime startsAt;
  final DateTime endsAt;

  /// Whether any attendance record exists for this session yet.
  final bool attendanceRecorded;

  final String? title;
  final String? educatorName;
}

/// How a session's attendance reads on the dashboard, resolved against the
/// clock by `sessionAttendanceStateAt`.
enum SessionAttendanceState { recorded, notRecorded, live, upcoming }

/// The whole `GET /dashboard/overview` payload.
@immutable
class DashboardOverview {
  const DashboardOverview({
    required this.alerts,
    required this.stats,
    required this.weeklyAttendance,
    required this.todaySessions,
    required this.fetchedAt,
  });

  final List<DashboardAlert> alerts;
  final List<DashboardStat> stats;
  final WeeklyAttendance? weeklyAttendance;
  final List<TodaySession> todaySessions;

  /// When this was fetched, in UTC — shown when it is served from cache.
  final DateTime fetchedAt;

  /// Whether nothing needs the executive right now — the reassuring state.
  bool get hasNoAlerts => alerts.isEmpty;
}
