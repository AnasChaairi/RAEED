import 'attendance_review.dart';

/// Reads a session's attendance with its correction history, and corrects it.
///
/// A correction goes through `PATCH /sessions/{id}/attendance` like any mark:
/// the server writes a new `attendance_record` with `corrected_from` set and
/// stamps `superseded_at` on the old one. The old row stays; the trail the
/// screen shows is that row and its successor, not an edit log.
abstract interface class AttendanceReviewRepository {
  Future<AttendanceReviewSheet> fetchSheet({
    required String sessionId,
    required String groupId,
  });

  /// Applies [draft] and returns the record the server created.
  Future<AttendanceRecordEntry> correct({
    required String sessionId,
    required AttendanceCorrectionDraft draft,
  });
}
