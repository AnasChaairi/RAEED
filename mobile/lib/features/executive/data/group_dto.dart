/// Wire → domain mapping for groups and their sessions.
///
/// `GET /groups/{id}/sessions` is contracted; the group list and detail
/// shapes are proposed (EXEC-M-05) and read tolerantly.
library;

import '../../../core/network/api_envelope.dart';
import '../domain/executive_group.dart';
import 'wire_helpers.dart';

const Map<String, SessionStatus> _sessionStatusByWire = {
  'planned': SessionStatus.planned,
  'delivered': SessionStatus.delivered,
  'cancelled': SessionStatus.cancelled,
};

ExecutiveGroup executiveGroupFromJson(Map<String, Object?> json) {
  final category = objectOrNull(json['category']);
  final educators = objectList(json['educators'], field: 'educators');
  return ExecutiveGroup(
    id: requireField<String>(json, 'id'),
    name: requireField<String>(json, 'name'),
    categoryName:
        stringOrNull(category?['name']) ??
        stringOrNull(json['category_name']) ??
        '',
    enrolledCount: intOrNull(json['enrolled_count']) ?? 0,
    capacity: intOrNull(json['capacity']),
    educatorNames: educators.isNotEmpty
        ? [
            for (final educator in educators)
              if (firstString(educator, ['full_name', 'display_name'])
                  case final String name)
                name,
          ]
        : stringList(json['educator_names']),
    scheduleLabel: stringOrNull(json['schedule_label']),
    weeklySchedule: [
      for (final slot in objectList(
        json['weekly_schedule'],
        field: 'weekly_schedule',
      ))
        if ((
              intOrNull(slot['weekday']),
              stringOrNull(slot['starts_at']),
              stringOrNull(slot['ends_at']),
            )
            case (
              final int weekday,
              final String startsAt,
              final String endsAt,
            ))
          ScheduleSlot(weekday: weekday, startsAt: startsAt, endsAt: endsAt),
    ],
    place: stringOrNull(json['place']),
    stats: _statsOrNull(objectOrNull(json['stats'])),
  );
}

GroupStats? _statsOrNull(Map<String, Object?>? json) {
  if (json == null) return null;
  final attendance = objectOrNull(json['attendance']);
  final homework = objectOrNull(json['homework']);
  return GroupStats(
    present: intOrNull(attendance?['present']) ?? 0,
    expected: intOrNull(attendance?['expected']) ?? 0,
    homeworkDone: intOrNull(homework?['done']) ?? 0,
    homeworkTotal: intOrNull(homework?['total']) ?? 0,
    nextSessionAt: dateOrNull(json['next_session_at']),
    flags: [
      for (final flag in objectList(json['flags'], field: 'flags'))
        CareFlag(
          childId: stringOrNull(flag['child_id']) ?? '',
          fullName: stringOrNull(flag['full_name']) ?? '',
          consecutiveAbsences: intOrNull(flag['consecutive_absences']) ?? 0,
        ),
    ],
  );
}

GroupSession groupSessionFromJson(Map<String, Object?> json) {
  final attendance = objectOrNull(json['attendance']);
  return GroupSession(
    id: requireField<String>(json, 'id'),
    groupId: requireField<String>(json, 'group_id'),
    title: stringOrNull(json['title']),
    startsAt: requireDateTime(json, 'starts_at'),
    endsAt: requireDateTime(json, 'ends_at'),
    status: enumFromWire(
      json['status'],
      _sessionStatusByWire,
      fallback: SessionStatus.planned,
    ),
    attendanceRecorded: boolOr(
      attendance?['recorded'] ?? json['attendance_recorded'],
      false,
    ),
    presentCount: intOrNull(
      attendance?['present_count'] ?? json['present_count'],
    ),
    enrolledCount: intOrNull(
      attendance?['enrolled_count'] ?? json['enrolled_count'],
    ),
  );
}

/// One slot, as `PATCH /groups/{id}` wants it.
Map<String, Object?> scheduleSlotToJson(ScheduleSlot slot) => {
  'weekday': slot.weekday,
  'starts_at': slot.startsAt,
  'ends_at': slot.endsAt,
};
