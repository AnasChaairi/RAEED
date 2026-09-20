/// Wire mapping for the executive's attendance review.
///
/// Reads `GET /sessions/{id}/attendance` exactly as the marking screen does
/// (see `features/attendance/data/attendance_dto.dart` for the contract gap
/// on the nested child and presence answer), plus one enrichment the review
/// needs and the marking screen does not: a `records` array per row carrying
/// the correction chain. A backend that predates it sends the flat
/// `status`/`recorded_by`/`recorded_at`, which decodes as a single-record
/// chain — the trail is then just the one mark, which is true.
library;

import '../../../core/network/api_envelope.dart';
import '../domain/attendance_review.dart';
import 'wire_helpers.dart';

AttendanceRecordEntry attendanceRecordEntryFromJson(Map<String, Object?> json) {
  final recordedBy = objectOrNull(json['recorded_by']);
  return AttendanceRecordEntry(
    id: firstString(json, ['id', 'record_id']) ?? '',
    status:
        AttendanceStatus.fromWire(stringOrNull(json['status'])) ??
        AttendanceStatus.present,
    recordedByName:
        firstString(recordedBy ?? const {}, ['display_name', 'full_name']) ??
        stringOrNull(json['recorded_by_name']) ??
        '',
    recordedAt:
        dateOrNull(json['recorded_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    correctedFromId: stringOrNull(json['corrected_from']),
    deviceLabel: firstString(json, ['device', 'device_label']),
    guardiansNotified: boolOr(json['guardians_notified'], false),
    note: stringOrNull(json['note']),
  );
}

AttendanceReviewRow attendanceReviewRowFromJson(Map<String, Object?> json) {
  final child = objectOrNull(json['child']);
  final answer = objectOrNull(json['presence_answer']);
  final chain = objectList(json['records'], field: 'records');
  final hasFlatRecord = stringOrNull(json['status']) != null;

  final records = chain.isNotEmpty
      ? chain.map(attendanceRecordEntryFromJson).toList()
      : hasFlatRecord
      ? [attendanceRecordEntryFromJson(json)]
      : <AttendanceRecordEntry>[];
  records.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

  return AttendanceReviewRow(
    childId: requireField<String>(json, 'child_id'),
    childName:
        stringOrNull(child?['full_name']) ??
        stringOrNull(json['child_name']) ??
        '',
    photoUrl: stringOrNull(child?['photo_url']),
    hasHealthAlert: boolOr(child?['health_alert'], false),
    presenceAnswer: PresenceAnswerValue.fromWire(
      stringOrNull(answer?['answer']),
    ),
    presenceReason: AbsenceReason.fromWire(stringOrNull(answer?['reason'])),
    records: records,
  );
}

AttendanceReviewSheet attendanceReviewSheetFromJson(
  Map<String, Object?> json, {
  required String sessionId,
  required String groupId,
}) {
  final session = objectOrNull(json['session']);
  final rows = objectList(
    json['data'],
    field: 'data',
  ).map(attendanceReviewRowFromJson).toList(growable: false);

  // Who recorded the sheet: the earliest original mark on it.
  AttendanceRecordEntry? first;
  for (final row in rows) {
    for (final record in row.records) {
      if (record.isCorrection) continue;
      if (first == null || record.recordedAt.isBefore(first.recordedAt)) {
        first = record;
      }
    }
  }

  return AttendanceReviewSheet(
    sessionId: stringOrNull(session?['id']) ?? sessionId,
    groupId: stringOrNull(session?['group_id']) ?? groupId,
    groupName: stringOrNull(session?['group_name']),
    sessionTitle: stringOrNull(session?['title']),
    startsAt:
        dateOrNull(session?['starts_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    recordedByName: first?.recordedByName,
    recordedAt: first?.recordedAt,
    rows: rows,
  );
}

/// The `PATCH /sessions/{id}/attendance` body for one correction.
///
/// `corrected_from` and `note` extend `AttendanceRecordInput`; the server
/// already links a correction to the current row by (session, child), so a
/// backend that ignores both still records the correction correctly.
Map<String, Object?> attendanceCorrectionToJson(
  AttendanceCorrectionDraft draft,
) => <String, Object?>{
  'records': [
    <String, Object?>{
      'child_id': draft.childId,
      'status': draft.status.wireValue,
      'recorded_at_client': draft.correctedAt.toUtc().toIso8601String(),
      if (draft.correctedFromId case final String from) 'corrected_from': from,
      if (stringOrNull(draft.note) case final String note) 'note': note,
    },
  ],
};
