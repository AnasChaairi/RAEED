/// Wire mapping for the attendance and presence endpoints.
///
/// ## A contract gap, and how it is handled
///
/// `specs/04-api/openapi.yaml` documents `GET /sessions/{id}/attendance` as
/// returning `AttendanceRecord` objects — `child_id`, `status`, `recorded_by`,
/// `recorded_at` — while `specs/06-mobile-app-spec.md` requires that same
/// response to drive a list that shows each child's **name**, a **health-alert
/// badge**, and a **pre-fill from the guardian's presence answer**. None of
/// those three fields exist on `AttendanceRecord`, and a sheet is by definition
/// a row per enrolled child, including children with no record yet — for whom
/// `status` and `recorded_at` cannot exist.
///
/// Rather than invent a second endpoint or guess a shape, this decoder treats
/// `child_id` as the only genuinely required field and reads the rest
/// defensively, accepting the enrichment under the names the rest of the
/// contract already uses (`Child.full_name`, `Child.photo_url`,
/// `Child.health_alert`, `PresenceAnswerInput.answer`/`reason`) whether they
/// arrive nested under `child`/`presence_answer` or flattened. A row missing
/// its name renders with a placeholder instead of failing the whole sheet: an
/// attendance screen that refuses to open because one field moved is worse than
/// one row reading oddly.
///
/// **This is flagged for the backend, not settled here.** `AttendanceRecord`
/// should gain the child summary and the presence answer explicitly.
library;

import '../../../core/network/api_envelope.dart';
import '../domain/attendance_sheet.dart';
import '../domain/attendance_status.dart';
import '../domain/presence_answer.dart';

/// Decodes one row of the attendance sheet.
AttendanceEntry attendanceEntryFromJson(Map<String, Object?> json) {
  final child = _objectOrNull(json['child']);
  final answer = _objectOrNull(json['presence_answer']);

  return AttendanceEntry(
    childId: requireField<String>(json, 'child_id'),
    childName:
        _stringOrNull(child?['full_name']) ??
        _stringOrNull(json['child_name']) ??
        _stringOrNull(json['full_name']) ??
        '',
    photoUrl:
        _stringOrNull(child?['photo_url']) ?? _stringOrNull(json['photo_url']),
    hasHealthAlert:
        child?['health_alert'] as bool? ??
        json['health_alert'] as bool? ??
        false,
    presenceAnswer: PresenceAnswerValue.fromWire(
      _stringOrNull(answer?['answer']) ??
          _stringOrNull(json['presence_answer']),
    ),
    presenceReason: AbsenceReason.fromWire(
      _stringOrNull(answer?['reason']) ??
          _stringOrNull(json['presence_reason']),
    ),
    serverStatus: AttendanceStatus.fromWire(_stringOrNull(json['status'])),
    serverRecordedAt: optionalDateTime(json, 'recorded_at'),
  );
}

/// Builds an `AttendanceRecordInput`.
///
/// `recorded_at_client` is serialised from the value the caller captured at the
/// tap. Nothing here reads the clock — doing so at serialisation time is
/// exactly the bug the field exists to prevent.
Map<String, Object?> attendanceRecordInputToJson({
  required String childId,
  required AttendanceStatus status,
  required DateTime recordedAtClient,
}) => <String, Object?>{
  'child_id': childId,
  'status': status.wireValue,
  'recorded_at_client': recordedAtClient.toUtc().toIso8601String(),
};

/// Builds a `PresenceAnswerInput`.
///
/// `note` is sent only alongside `other`, and only because the reason set is
/// closed; every other answer is typing-free by design.
Map<String, Object?> presenceAnswerInputToJson(PresenceAnswerDraft draft) =>
    <String, Object?>{
      'child_id': draft.childId,
      'answer': draft.answer.wireValue,
      if (draft.reason != null) 'reason': draft.reason!.wireValue,
      if (draft.reason == AbsenceReason.other &&
          (draft.note?.trim().isNotEmpty ?? false))
        'note': draft.note!.trim(),
    };

/// Decodes the server's side of an `attendance.conflict`, from the error
/// envelope's `details`.
///
/// Every field is optional: `specs/04-api/conventions.md` guarantees the code,
/// not the shape of `details`. A conflict with no detail still surfaces — the
/// educator is told their mark did not stand, which is the part that matters —
/// it just cannot show them what won.
AttendanceConflict conflictFromDetails({
  required String childId,
  required AttendanceStatus attemptedStatus,
  required DateTime attemptedRecordedAtClient,
  Map<String, Object?> details = const {},
}) {
  final current = _objectOrNull(details['current']) ?? details;
  return AttendanceConflict(
    childId: childId,
    attemptedStatus: attemptedStatus,
    attemptedRecordedAtClient: attemptedRecordedAtClient,
    serverStatus: AttendanceStatus.fromWire(_stringOrNull(current['status'])),
    serverRecordedAt: _dateOrNull(current['recorded_at']),
    serverRecordedByName:
        _stringOrNull(current['recorded_by_name']) ??
        _stringOrNull(current['recorded_by']),
  );
}

/// Reads the child ids named by an `attendance.unknown_child` response.
List<String> unknownChildIdsFromDetails(Map<String, Object?> details) {
  final single = _stringOrNull(details['child_id']);
  if (single != null) return [single];
  final many = details['child_ids'];
  if (many is List) {
    return many.map(_stringOrNull).whereType<String>().toList(growable: false);
  }
  return const [];
}

/// Decodes one unanswered presence confirmation for the Home card.
PendingPresenceConfirmation pendingConfirmationFromJson(
  Map<String, Object?> json,
) {
  final session = _objectOrNull(json['session']);
  final child = _objectOrNull(json['child']);
  return PendingPresenceConfirmation(
    confirmationId: requireField<String>(json, 'id'),
    sessionId:
        _stringOrNull(json['session_id']) ??
        _stringOrNull(session?['id']) ??
        '',
    childId:
        _stringOrNull(json['child_id']) ?? _stringOrNull(child?['id']) ?? '',
    childName:
        _stringOrNull(child?['full_name']) ??
        _stringOrNull(json['child_name']) ??
        '',
    sessionStartsAt:
        _dateOrNull(json['session_starts_at']) ??
        _dateOrNull(session?['starts_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    groupName:
        _stringOrNull(json['group_name']) ??
        _stringOrNull(_objectOrNull(session?['group'])?['name']),
    deadlineAt: _dateOrNull(json['deadline_at']),
  );
}

Map<String, Object?>? _objectOrNull(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  return null;
}

String? _stringOrNull(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

DateTime? _dateOrNull(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;
