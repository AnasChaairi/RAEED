import 'dashboard_overview.dart';

/// Reads the executive overview.
///
/// Scoped server-side: `GET /dashboard/overview` already narrows to the
/// caller's branch when their role assignment carries one (`ACC-08`), through
/// the same permission-scoped services the web dashboard uses. The client
/// passes no branch, because a branch it could pass is a branch it could get
/// wrong.
abstract interface class DashboardRepository {
  Future<DashboardOverview> fetchOverview();
}
