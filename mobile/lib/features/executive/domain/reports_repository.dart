import 'reports.dart';

/// Reports and the recorded export (EXEC-M-11).
abstract interface class ReportsRepository {
  Future<AttendanceReport> fetchAttendance();
  Future<List<EducatorActivity>> fetchEducators();
  Future<EngagementReport> fetchEngagement();

  /// Builds the file server-side; recorded with its field list before the
  /// content is returned.
  Future<ExportFile> export(Set<ExportField> fields);
}
