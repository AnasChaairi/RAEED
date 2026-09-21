import 'package:meta/meta.dart';

import '../../attendance/domain/attendance_status.dart';
import '../../attendance/domain/presence_answer.dart';

export '../../attendance/domain/attendance_status.dart';
export '../../attendance/domain/presence_answer.dart'
    show AbsenceReason, PresenceAnswerValue;

/// One `attendance_record` row, as the trail beneath a corrected child shows.
@immutable
class AttendanceRecordEntry {
  const AttendanceRecordEntry({
    required this.id,
    required this.status,
    required this.recordedByName,
    required this.recordedAt,
    this.correctedFromId,
    this.deviceLabel,
    this.guardiansNotified = false,
    this.note,
  });

  final String id;
  final AttendanceStatus status;
  final String recordedByName;
  final DateTime recordedAt;

  /// The record this one supersedes. A correction is a new row pointing at
  /// the old one (`specs/03-domain-model/schema.sql`); nothing is edited.
  final String? correctedFromId;

  /// "Android", "Web" — from the audit entry, when the server includes it.
  final String? deviceLabel;

  /// Whether this mark paged the guardians (an unexplained absence).
  final bool guardiansNotified;

  final String? note;

  bool get isCorrection => correctedFromId != null;
}

/// One child on the review sheet, with every record ever made for them.
@immutable
class AttendanceReviewRow {
  const AttendanceReviewRow({
    required this.childId,
    required this.childName,
    this.photoUrl,
    this.hasHealthAlert = false,
    this.presenceAnswer,
    this.presenceReason,
    this.records = const [],
  });

  final String childId;
  final String childName;
  final String? photoUrl;

  /// A flag, never the text — see `HealthAlertBadge`.
  final bool hasHealthAlert;

  final PresenceAnswerValue? presenceAnswer;
  final AbsenceReason? presenceReason;

  /// Chronological: the original mark first, corrections after it.
  final List<AttendanceRecordEntry> records;

  /// The record that currently stands.
  AttendanceRecordEntry? get current => records.isEmpty ? null : records.last;

  AttendanceStatus? get currentStatus => current?.status;

  bool get isCorrected => records.length > 1;

  bool get isUnmarked => records.isEmpty;

  AttendanceReviewRow withRecord(AttendanceRecordEntry record) =>
      AttendanceReviewRow(
        childId: childId,
        childName: childName,
        photoUrl: photoUrl,
        hasHealthAlert: hasHealthAlert,
        presenceAnswer: presenceAnswer,
        presenceReason: presenceReason,
        records: [...records, record],
      );
}

/// The review sheet for one session.
@immutable
class AttendanceReviewSheet {
  const AttendanceReviewSheet({
    required this.sessionId,
    required this.groupId,
    required this.startsAt,
    required this.rows,
    this.groupName,
    this.sessionTitle,
    this.recordedByName,
    this.recordedAt,
    this.isFromCache = false,
  });

  final String sessionId;
  final String groupId;
  final String? groupName;
  final String? sessionTitle;
  final DateTime startsAt;

  /// Who made the first mark on this sheet, and when.
  final String? recordedByName;
  final DateTime? recordedAt;

  final List<AttendanceReviewRow> rows;
  final bool isFromCache;

  bool get isEmpty => rows.isEmpty;

  int countOf(AttendanceStatus status) =>
      rows.where((row) => row.currentStatus == status).length;

  int get unmarkedCount => rows.where((row) => row.isUnmarked).length;

  AttendanceReviewSheet withRow(AttendanceReviewRow row) =>
      AttendanceReviewSheet(
        sessionId: sessionId,
        groupId: groupId,
        groupName: groupName,
        sessionTitle: sessionTitle,
        startsAt: startsAt,
        recordedByName: recordedByName,
        recordedAt: recordedAt,
        isFromCache: isFromCache,
        rows: [
          for (final existing in rows)
            if (existing.childId == row.childId) row else existing,
        ],
      );
}

/// A correction the executive is about to save.
@immutable
class AttendanceCorrectionDraft {
  const AttendanceCorrectionDraft({
    required this.childId,
    required this.status,
    required this.correctedAt,
    this.correctedFromId,
    this.note,
  });

  final String childId;
  final AttendanceStatus status;

  /// The moment of the tap — carried as `recorded_at_client`.
  final DateTime correctedAt;

  /// The record being corrected, when there is one.
  final String? correctedFromId;

  final String? note;
}
