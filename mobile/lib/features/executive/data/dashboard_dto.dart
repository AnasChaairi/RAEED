/// Wire → domain mapping for `GET /dashboard/overview`.
///
/// `specs/04-api/openapi.yaml` declares the endpoint (`DSH-01`) but not its
/// response body. The shape read here is the one the executive screen spec
/// needs — alerts, the four stats, this week's attendance, today's sessions —
/// and is flagged for the backend to adopt rather than settled unilaterally:
///
/// ```json
/// {
///   "alerts": [{ "id", "severity", "text", "destination", "raised_at",
///                "group_id"?, "session_id"? }],
///   "stats": { "children": { "value", "delta"? }, "families": …,
///              "groups": …, "educators": … },
///   "weekly_attendance": { "present_count", "expected_count",
///                          "weekly_rates": [int], "delta_points"? },
///   "today_sessions": [{ "id", "group_id", "group_name", "title"?,
///                        "educator_name"?, "starts_at", "ends_at",
///                        "attendance_recorded" }]
/// }
/// ```
library;

import '../../../core/network/api_envelope.dart';
import '../domain/dashboard_overview.dart';
import 'wire_helpers.dart';

const Map<String, AlertSeverity> _severityByWire = {
  'danger': AlertSeverity.danger,
  'warning': AlertSeverity.warning,
  'info': AlertSeverity.info,
};

const Map<String, AlertDestination> _destinationByWire = {
  'groups': AlertDestination.groups,
  'memories': AlertDestination.memories,
  'messages': AlertDestination.messages,
  'announcements': AlertDestination.announcements,
  'notifications': AlertDestination.notifications,
};

const Map<String, StatKind> _statByWire = {
  'children': StatKind.children,
  'families': StatKind.families,
  'groups': StatKind.groups,
  'educators': StatKind.educators,
};

/// Parses an alert destination sent on the wire.
AlertDestination? alertDestinationFromWire(Object? value) =>
    value is String ? _destinationByWire[value] : null;

DashboardAlert dashboardAlertFromJson(Map<String, Object?> json) =>
    DashboardAlert(
      id: requireField<String>(json, 'id'),
      // An unknown severity reads as info, never danger: a new value must
      // not be able to promote itself onto the outlined treatment by accident.
      severity: enumFromWire(
        json['severity'],
        _severityByWire,
        fallback: AlertSeverity.info,
      ),
      text: requireField<String>(json, 'text'),
      destination: enumFromWire(
        json['destination'],
        _destinationByWire,
        fallback: AlertDestination.notifications,
      ),
      raisedAt: requireDateTime(json, 'raised_at'),
      groupId: stringOrNull(json['group_id']),
      sessionId: stringOrNull(json['session_id']),
    );

List<DashboardStat> dashboardStatsFromJson(Object? value) {
  final json = objectOrNull(value);
  if (json == null) return const [];
  return [
    for (final entry in _statByWire.entries)
      if (json[entry.key] case final Object raw)
        DashboardStat(
          kind: entry.value,
          value: intOrNull(objectOrNull(raw)?['value'] ?? raw) ?? 0,
          delta: intOrNull(objectOrNull(raw)?['delta']),
        ),
  ];
}

WeeklyAttendance? weeklyAttendanceFromJson(Object? value) {
  final json = objectOrNull(value);
  if (json == null) return null;
  return WeeklyAttendance(
    presentCount: intOrNull(json['present_count']) ?? 0,
    expectedCount: intOrNull(json['expected_count']) ?? 0,
    weeklyRates: [
      if (json['weekly_rates'] case final List<Object?> rates)
        for (final rate in rates)
          if (intOrNull(rate) case final int percent) percent,
    ],
    deltaPoints: intOrNull(json['delta_points']),
  );
}

TodaySession todaySessionFromJson(Map<String, Object?> json) => TodaySession(
  id: requireField<String>(json, 'id'),
  groupId: requireField<String>(json, 'group_id'),
  groupName: stringOrNull(json['group_name']) ?? '',
  title: stringOrNull(json['title']),
  educatorName: stringOrNull(json['educator_name']),
  startsAt: requireDateTime(json, 'starts_at'),
  endsAt: requireDateTime(json, 'ends_at'),
  attendanceRecorded: boolOr(json['attendance_recorded'], false),
);

/// Decodes the overview. [fetchedAt] is stamped by the caller so a cached
/// copy can say how old it is.
DashboardOverview dashboardOverviewFromJson(
  Map<String, Object?> json, {
  required DateTime fetchedAt,
}) => DashboardOverview(
  alerts: objectList(
    json['alerts'],
    field: 'alerts',
  ).map(dashboardAlertFromJson).toList(growable: false),
  stats: dashboardStatsFromJson(json['stats']),
  weeklyAttendance: weeklyAttendanceFromJson(json['weekly_attendance']),
  todaySessions: objectList(
    json['today_sessions'],
    field: 'today_sessions',
  ).map(todaySessionFromJson).toList(growable: false),
  fetchedAt: fetchedAt.toUtc(),
);
