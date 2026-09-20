import '../../../core/network/api_client.dart';
import '../domain/dashboard_overview.dart';
import '../domain/dashboard_repository.dart';
import 'dashboard_dto.dart';

/// [DashboardRepository] against `GET /dashboard/overview`.
class ApiDashboardRepository implements DashboardRepository {
  const ApiDashboardRepository(this._client, {DateTime Function()? clock})
    : _clock = clock ?? _utcNow;

  final ApiClient _client;
  final DateTime Function() _clock;

  static DateTime _utcNow() => DateTime.now().toUtc();

  @override
  Future<DashboardOverview> fetchOverview() async {
    final json = await _client.getObject('/dashboard/overview');
    return dashboardOverviewFromJson(json, fetchedAt: _clock());
  }
}

/// The last good overview, kept so a failed refresh degrades to "the version
/// from 10:42" instead of an error screen.
///
/// In memory only: the dashboard names children in its alerts, and the
/// offline scope in `specs/02-architecture.md` is attendance and presence,
/// not oversight data at rest on the device.
class DashboardSnapshotCache {
  DashboardOverview? _snapshot;

  DashboardOverview? get snapshot => _snapshot;

  void save(DashboardOverview overview) => _snapshot = overview;

  void clear() => _snapshot = null;
}
