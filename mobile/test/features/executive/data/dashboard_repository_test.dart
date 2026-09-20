import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/features/executive/data/dashboard_repository_api.dart';
import 'package:raeed/features/executive/domain/dashboard_overview.dart';

import 'stub_adapter.dart';

void main() {
  late StubAdapter adapter;
  late ApiDashboardRepository repository;
  final fetchedAt = DateTime.utc(2026, 9, 20, 10, 42);

  setUp(() {
    adapter = StubAdapter();
    repository = ApiDashboardRepository(
      stubClient(adapter),
      clock: () => fetchedAt,
    );
  });

  test('decodes the overview shape the screen spec needs', () async {
    adapter.respond(200, {
      'alerts': [
        {
          'id': 'a1',
          'severity': 'danger',
          'text': '3 جلسات أمس بلا تسجيل حضور',
          'destination': 'groups',
          'raised_at': '2026-09-20T08:00:00Z',
          'group_id': 'g1',
        },
      ],
      'stats': {
        'children': {'value': 246, 'delta': 12},
        'families': 163,
        'groups': {'value': 14},
        'educators': {'value': 18, 'delta': null},
      },
      'weekly_attendance': {
        'present_count': 412,
        'expected_count': 453,
        'weekly_rates': [82, 86, 91],
        'delta_points': 2,
      },
      'today_sessions': [
        {
          'id': 's1',
          'group_id': 'g1',
          'group_name': 'الأشبال 1',
          'title': 'حلقة القرآن',
          'educator_name': 'عبد الله المرابط',
          'starts_at': '2026-09-20T09:00:00Z',
          'ends_at': '2026-09-20T10:30:00Z',
          'attendance_recorded': true,
        },
      ],
    });

    final overview = await repository.fetchOverview();

    expect(overview.alerts.single.severity, AlertSeverity.danger);
    expect(overview.alerts.single.groupId, 'g1');
    expect(overview.stats.map((s) => s.kind), StatKind.values);
    expect(overview.stats.first.delta, 12);
    // A bare integer is accepted as the value.
    expect(overview.stats[1].value, 163);
    expect(overview.weeklyAttendance!.ratePercent, 91);
    expect(overview.weeklyAttendance!.weeklyRates, [82, 86, 91]);
    expect(overview.todaySessions.single.attendanceRecorded, isTrue);
    expect(overview.fetchedAt, fetchedAt);
    expect(adapter.lastRequest!.path, endsWith('/dashboard/overview'));
  });

  test('an unknown severity reads as info, never danger', () async {
    adapter.respond(200, {
      'alerts': [
        {
          'id': 'a1',
          'severity': 'catastrophic',
          'text': 'x',
          'destination': 'groups',
          'raised_at': '2026-09-20T08:00:00Z',
        },
      ],
    });

    final overview = await repository.fetchOverview();

    expect(overview.alerts.single.severity, AlertSeverity.info);
    expect(overview.stats, isEmpty);
    expect(overview.weeklyAttendance, isNull);
    expect(overview.todaySessions, isEmpty);
  });

  test('no expected marks means no rate rather than a fake 0%', () async {
    adapter.respond(200, {
      'weekly_attendance': {'present_count': 0, 'expected_count': 0},
    });

    final overview = await repository.fetchOverview();

    expect(overview.weeklyAttendance!.ratePercent, isNull);
  });

  test('a network failure travels as NetworkException', () async {
    adapter.throwDio(DioExceptionType.connectionError);

    await expectLater(
      repository.fetchOverview(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('scope.forbidden is not swallowed into an empty overview', () async {
    adapter.respond(403, {
      'error': {'code': 'scope.forbidden', 'message': 'no'},
    });

    await expectLater(repository.fetchOverview(), throwsA(isA<ApiException>()));
  });
}
