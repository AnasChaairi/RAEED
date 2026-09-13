/// Wire → domain mapping for `Child` and `ChildDetail`.
///
/// Hand-written rather than generated, and built on the parse helpers in
/// `core/network/api_envelope.dart`, because the failure mode those helpers
/// enforce is the one that matters here: a malformed payload raises a
/// [ContractException] instead of quietly producing a child with no name or a
/// list with no children. On an attendance sheet a silently-empty list looks
/// exactly like "nobody is enrolled", which is a safeguarding failure rather
/// than a cosmetic bug.
///
/// Only `id` and `full_name` are required. Everything else is optional, so a
/// backend that predates a field — or a caller whose scope excludes it —
/// degrades to a quieter card rather than an error screen.
library;

import '../../../core/error/raeed_exception.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/child.dart';
import '../domain/child_day_status.dart';
import '../domain/child_detail.dart';
import '../domain/session_summary.dart';

/// Wire values of `attendance_status` and the presence-answer states, mapped
/// onto [DayStatusKind].
///
/// Unrecognised values fall back to [DayStatusKind.unknown] via
/// [enumFromWire]: a status added server-side must not crash an older app on
/// the one screen a parent opens first.
const Map<String, DayStatusKind> _dayStatusByWire = {
  'no_session': DayStatusKind.noSession,
  'awaiting_presence_answer': DayStatusKind.awaitingPresenceAnswer,
  'presence_confirmed': DayStatusKind.presenceConfirmed,
  'presence_declined': DayStatusKind.presenceDeclined,
  'presence_late': DayStatusKind.presenceLate,
  'present': DayStatusKind.present,
  'late': DayStatusKind.late,
  'absent': DayStatusKind.absent,
  'excused': DayStatusKind.excused,
};

const Map<String, ImageRightsLevel> _imageRightsByWire = {
  'allowed': ImageRightsLevel.allowed,
  'app_only': ImageRightsLevel.appOnly,
  'not_allowed': ImageRightsLevel.notAllowed,
};

/// Parses the `Child` schema.
Child childFromJson(Map<String, Object?> json) => Child(
  id: requireField<String>(json, 'id'),
  fullName: requireField<String>(json, 'full_name'),
  // Absent means "no flag raised". Defaulting a *health* flag to false is the
  // permissive direction, so it is worth being explicit: the flag's absence in
  // a list payload is how the contract says "nothing to warn about", and the
  // authoritative answer is always the detail endpoint behind the tap-through.
  healthAlert: json['health_alert'] as bool? ?? false,
  photoUrl: _optionalString(json, 'photo_url'),
  group: _groupFromJson(json['group']),
  dateOfBirth: optionalDateTime(json, 'dob'),
  nextSession: _sessionFromJson(json['next_session']),
  todayStatus: _dayStatusFromJson(json['today_status']),
);

/// Parses the `ChildDetail` schema — `Child` plus the profile fields.
ChildDetail childDetailFromJson(Map<String, Object?> json) => ChildDetail(
  summary: childFromJson(json),
  imageRightsLevel: enumFromWire(
    json['image_rights_level'],
    _imageRightsByWire,
    // The most restrictive level is the fallback, always. An unrecognised
    // value must never be read as permission to publish a child's photo.
    fallback: ImageRightsLevel.notAllowed,
  ),
  schoolLevel: _optionalString(json, 'school_level'),
  health: healthInfoFromJson(json['health_json']),
);

/// Parses `child.health_json`.
///
/// The key set is **open decision #2** in `specs/01-product-brief.md`, so this
/// reads the working-draft keys from `specs/03-domain-model/entities.md` and
/// keeps everything else in [HealthInfo.otherNotes] rather than dropping it.
/// Losing an allergy because the backend renamed a key is not an acceptable
/// failure mode.
HealthInfo healthInfoFromJson(Object? value) {
  if (value == null) return const HealthInfo.empty();
  final json = asJsonObject(value, context: 'health_json');

  const known = {'allergies', 'conditions', 'medications', 'dietary_notes'};
  final other = <String, String>{};
  for (final entry in json.entries) {
    if (known.contains(entry.key)) continue;
    final rendered = _renderUnknownHealthValue(entry.value);
    if (rendered != null) other[entry.key] = rendered;
  }

  return HealthInfo(
    allergies: _stringList(json['allergies'], 'health_json.allergies'),
    conditions: _stringList(json['conditions'], 'health_json.conditions'),
    medications: _stringList(json['medications'], 'health_json.medications'),
    dietaryNotes: _optionalString(json, 'dietary_notes'),
    otherNotes: other,
  );
}

ChildGroupRef? _groupFromJson(Object? value) {
  if (value == null) return null;
  final json = asJsonObject(value, context: 'child.group');
  return ChildGroupRef(
    id: requireField<String>(json, 'id'),
    name: requireField<String>(json, 'name'),
  );
}

SessionSummary? _sessionFromJson(Object? value) {
  if (value == null) return null;
  final json = asJsonObject(value, context: 'child.next_session');
  return SessionSummary(
    id: requireField<String>(json, 'id'),
    startsAt: requireDateTime(json, 'starts_at'),
    groupId: _optionalString(json, 'group_id'),
    title: _optionalString(json, 'title'),
  );
}

ChildDayStatus _dayStatusFromJson(Object? value) {
  if (value == null) return const ChildDayStatus.noSession();
  final json = asJsonObject(value, context: 'child.today_status');
  return ChildDayStatus(
    kind: enumFromWire(
      json['status'],
      _dayStatusByWire,
      fallback: DayStatusKind.unknown,
    ),
    alertRaisedAt: optionalDateTime(json, 'alert_raised_at'),
  );
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw ContractException(message: 'Field `$key` should be a string');
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _stringList(Object? value, String context) {
  if (value == null) return const [];
  if (value is! List) {
    throw ContractException(message: '`$context` should be an array');
  }
  return [
    for (final element in value)
      if (element is String && element.trim().isNotEmpty) element.trim(),
  ];
}

/// Renders a health value this build does not have a field for.
///
/// Scalars and string arrays survive; anything more nested is summarised
/// rather than rendered, because an unbounded blob pasted into the profile
/// would be unreadable and could carry more than the screen means to show.
String? _renderUnknownHealthValue(Object? value) => switch (value) {
  null => null,
  final String text when text.trim().isNotEmpty => text.trim(),
  final String _ => null,
  final bool flag => flag.toString(),
  final num number => number.toString(),
  final List<Object?> list =>
    list.whereType<String>().isEmpty
        ? null
        : list.whereType<String>().join('، '),
  _ => null,
};
