import '../../../core/network/api_client.dart';
import '../domain/attendance_review.dart';
import '../domain/attendance_review_repository.dart';
import 'attendance_review_dto.dart';

/// [AttendanceReviewRepository] against `/sessions/{id}/attendance`.
///
/// Online only. The offline scope (`specs/02-architecture.md`) is the
/// educator's marks and the guardian's presence answers; an executive's
/// after-the-fact correction is a deliberate, logged act that should fail
/// visibly when there is no network rather than sit in a queue.
class ApiAttendanceReviewRepository implements AttendanceReviewRepository {
  const ApiAttendanceReviewRepository(this._client);

  final ApiClient _client;

  @override
  Future<AttendanceReviewSheet> fetchSheet({
    required String sessionId,
    required String groupId,
  }) async => attendanceReviewSheetFromJson(
    await _client.getObject('/sessions/$sessionId/attendance'),
    sessionId: sessionId,
    groupId: groupId,
  );

  @override
  Future<void> correct({
    required String sessionId,
    required AttendanceCorrectionDraft draft,
  }) => _client.patch(
    '/sessions/$sessionId/attendance',
    body: attendanceCorrectionToJson(draft),
  );
}
