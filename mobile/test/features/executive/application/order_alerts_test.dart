import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/application/order_alerts.dart';
import 'package:raeed/features/executive/domain/dashboard_overview.dart';

DashboardAlert alert(String id, AlertSeverity severity, int minutesAgo) =>
    DashboardAlert(
      id: id,
      severity: severity,
      text: id,
      destination: AlertDestination.groups,
      raisedAt: DateTime.utc(
        2026,
        9,
        20,
        11,
      ).subtract(Duration(minutes: minutesAgo)),
    );

void main() {
  group('orderAlerts', () {
    test(
      'danger comes before warning before info, whatever the order given',
      () {
        final ordered = orderAlerts([
          alert('info', AlertSeverity.info, 1),
          alert('warning', AlertSeverity.warning, 1),
          alert('danger', AlertSeverity.danger, 1),
        ]);

        expect(ordered.map((a) => a.id), ['danger', 'warning', 'info']);
      },
    );

    test('a fresh info never outranks an old danger', () {
      // The brief: "is any child unaccounted for right now?" is answered
      // first. A newer approval request must not push an absence down.
      final ordered = orderAlerts([
        alert('fresh-info', AlertSeverity.info, 0),
        alert('old-danger', AlertSeverity.danger, 600),
      ]);

      expect(ordered.first.id, 'old-danger');
    });

    test('within a severity the most recent comes first', () {
      final ordered = orderAlerts([
        alert('older', AlertSeverity.danger, 30),
        alert('newer', AlertSeverity.danger, 5),
      ]);

      expect(ordered.map((a) => a.id), ['newer', 'older']);
    });

    test('does not mutate its input', () {
      final input = [
        alert('info', AlertSeverity.info, 1),
        alert('danger', AlertSeverity.danger, 1),
      ];
      orderAlerts(input);
      expect(input.first.id, 'info');
    });
  });

  test('dangerCount counts only danger', () {
    expect(
      dangerCount([
        alert('a', AlertSeverity.danger, 1),
        alert('b', AlertSeverity.warning, 1),
        alert('c', AlertSeverity.danger, 1),
      ]),
      2,
    );
  });
}
