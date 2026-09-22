/// Wire → domain for the executive's reads of children (EXEC-M-08/09).
library;

import '../../../core/network/api_envelope.dart';
import '../../children/data/child_dto.dart';
import '../domain/executive_child.dart';
import 'wire_helpers.dart';

const Map<String, ImageRightsLevel> _imageRightsByWire = {
  'allowed': ImageRightsLevel.allowed,
  'app_only': ImageRightsLevel.appOnly,
  'not_allowed': ImageRightsLevel.notAllowed,
};

/// Unknown reads as not allowed: the failure mode of guessing wrong on a
/// child's image rights is publishing a photo their guardian refused.
ImageRightsLevel imageRightsFromWire(Object? value) => enumFromWire(
  value,
  _imageRightsByWire,
  fallback: ImageRightsLevel.notAllowed,
);

AttendanceRatio? attendanceRatioFromJson(Object? value) {
  final json = objectOrNull(value);
  if (json == null) return null;
  return AttendanceRatio(
    present: intOrNull(json['present']) ?? 0,
    expected: intOrNull(json['expected']) ?? 0,
  );
}

ExecutiveChildSummary executiveChildSummaryFromJson(
  Map<String, Object?> json,
) => ExecutiveChildSummary(
  child: childFromJson(json),
  imageRights: imageRightsFromWire(json['image_rights_level']),
  attendance: attendanceRatioFromJson(json['attendance']),
);

ExecutiveChildProfile executiveChildProfileFromJson(Map<String, Object?> json) {
  final group = objectOrNull(json['group']);
  final consents = objectOrNull(json['consents']) ?? const {};
  return ExecutiveChildProfile(
    id: requireField<String>(json, 'id'),
    fullName: requireField<String>(json, 'full_name'),
    dateOfBirth: optionalDateTime(json, 'dob'),
    schoolLevel: stringOrNull(json['school_level']),
    mainGroup: group == null
        ? null
        : ChildGroupRef(
            id: stringOrNull(group['id']) ?? '',
            name: stringOrNull(group['name']) ?? '',
          ),
    hasHealthAlert: boolOr(json['health_alert'], false),
    imageRights: imageRightsFromWire(json['image_rights_level']),
    seasonAttendance: attendanceRatioFromJson(json['season_attendance']),
    guardians: [
      for (final g in objectList(json['guardians'], field: 'guardians'))
        GuardianSummary(
          id: requireField<String>(g, 'id'),
          displayName: stringOrNull(g['display_name']) ?? '',
          relationship: stringOrNull(g['relationship']) ?? 'parent',
          account: stringOrNull(g['account']) == 'active'
              ? AccountStatus.active
              : AccountStatus.pending,
          lastSeenAt: dateOrNull(g['last_seen_at']),
          phoneHint: stringOrNull(g['phone_hint']),
        ),
    ],
    privacyConsents: [
      for (final c in objectList(
        consents['privacy_policy'],
        field: 'privacy_policy',
      ))
        if (dateOrNull(c['at']) case final DateTime at)
          PrivacyConsent(
            guardianId: stringOrNull(c['guardian_id']) ?? '',
            version: intOrNull(c['version']) ?? 1,
            at: at,
          ),
    ],
    imageRightsConsents: [
      for (final c in objectList(
        consents['image_rights'],
        field: 'image_rights',
      ))
        if (dateOrNull(c['at']) case final DateTime at)
          ImageRightsConsent(
            guardianId: stringOrNull(c['guardian_id']) ?? '',
            level: imageRightsFromWire(c['level']),
            version: intOrNull(c['version']) ?? 1,
            at: at,
          ),
    ],
    groups: [
      for (final g in objectList(json['groups'], field: 'groups'))
        ChildGroupMembership(
          id: requireField<String>(g, 'id'),
          name: stringOrNull(g['name']) ?? '',
          isMain: boolOr(g['is_main'], false),
          educatorNames: stringList(g['educator_names']),
          scheduleLabel: stringOrNull(g['schedule_label']),
          attendance:
              attendanceRatioFromJson(g['attendance']) ??
              const AttendanceRatio(present: 0, expected: 0),
        ),
    ],
    conversationId: stringOrNull(json['conversation_id']),
  );
}

HealthReveal healthRevealFromJson(Map<String, Object?> json) => HealthReveal(
  health: healthInfoFromJson(json['health_json']),
  specialNeedsNotes: stringOrNull(json['special_needs_notes']),
  viewedAt: requireDateTime(json, 'viewed_at'),
);

PhoneReveal phoneRevealFromJson(Map<String, Object?> json) => PhoneReveal(
  phone: stringOrNull(json['phone']),
  revealedAt: requireDateTime(json, 'revealed_at'),
);
