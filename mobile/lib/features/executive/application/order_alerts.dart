import '../domain/dashboard_overview.dart';

/// Orders alerts the way the dashboard scans them: danger first, then
/// warning, then info; within a severity the most recent first.
///
/// A pure function so the ordering rule — which decides what an executive
/// standing in a corridor sees first — is tested directly rather than
/// inferred from a rendered list.
List<DashboardAlert> orderAlerts(Iterable<DashboardAlert> alerts) {
  final ordered = alerts.toList(growable: false);
  ordered.sort((a, b) {
    final bySeverity = a.severity.index.compareTo(b.severity.index);
    if (bySeverity != 0) return bySeverity;
    return b.raisedAt.compareTo(a.raisedAt);
  });
  return ordered;
}

/// How many alerts are of the most serious kind.
int dangerCount(Iterable<DashboardAlert> alerts) =>
    alerts.where((alert) => alert.severity == AlertSeverity.danger).length;
