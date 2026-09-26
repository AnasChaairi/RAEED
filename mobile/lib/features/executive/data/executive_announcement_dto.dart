/// Wire mapping for the executive side of `/announcements`.
///
/// `audience` is the `audience_json` column of `announcement`
/// (`specs/03-domain-model/schema.sql`): `{ "type": all|parents|educators
/// |categories, "category_ids": [...] }`. The read model adds `expire_at`,
/// `is_draft` and `read_rate`, which the parent-facing schema omits because a
/// guardian must not see who else an announcement went to.
library;

import '../../../core/network/api_envelope.dart';
import '../domain/announcement_draft.dart';
import 'wire_helpers.dart';

const Map<String, AnnouncementPriority> _priorityByWire = {
  'normal': AnnouncementPriority.normal,
  'urgent': AnnouncementPriority.urgent,
};

const Map<String, AudienceMode> _audienceModeByWire = {
  'all': AudienceMode.all,
  'parents': AudienceMode.parents,
  'educators': AudienceMode.educators,
  'categories': AudienceMode.categories,
};

AnnouncementAudience audienceFromJson(Object? value) {
  final json = objectOrNull(value);
  if (json == null) return const AnnouncementAudience.all();
  final mode = enumFromWire(
    json['type'] ?? json['mode'],
    _audienceModeByWire,
    fallback: AudienceMode.all,
  );
  return AnnouncementAudience(
    mode: mode,
    categoryIds: mode == AudienceMode.categories
        ? stringList(json['category_ids']).toSet()
        : const {},
  );
}

Map<String, Object?> audienceToJson(AnnouncementAudience audience) =>
    <String, Object?>{
      'type': audience.mode.wireValue,
      if (audience.mode == AudienceMode.categories)
        'category_ids': audience.categoryIds.toList()..sort(),
      if (audience.mode == AudienceMode.groups)
        'group_ids': audience.groupIds.toList()..sort(),
    };

ExecutiveAnnouncement executiveAnnouncementFromJson(Map<String, Object?> json) {
  final readRate =
      doubleOrNull(json['read_rate']) ??
      _rateFromCounts(json['read_count'], json['audience_count']);
  return ExecutiveAnnouncement(
    id: requireField<String>(json, 'id'),
    title: requireField<String>(json, 'title'),
    body: stringOrNull(json['body']),
    priority: enumFromWire(
      json['priority'],
      _priorityByWire,
      fallback: AnnouncementPriority.normal,
    ),
    pinned: boolOr(json['pinned'], false),
    publishAt: requireDateTime(json, 'publish_at'),
    expireAt: optionalDateTime(json, 'expire_at'),
    audience: audienceFromJson(json['audience']),
    isDraft: boolOr(json['is_draft'], false),
    readRate: readRate?.clamp(0, 1).toDouble(),
  );
}

double? _rateFromCounts(Object? read, Object? total) {
  final readCount = intOrNull(read);
  final audienceCount = intOrNull(total);
  if (readCount == null || audienceCount == null || audienceCount == 0) {
    return null;
  }
  return readCount / audienceCount;
}

AudienceReach audienceReachFromJson(Map<String, Object?> json) => AudienceReach(
  allCount: intOrNull(json['all']) ?? 0,
  parentsCount: intOrNull(json['parents']) ?? 0,
  educatorsCount: intOrNull(json['educators']) ?? 0,
  categories: [
    for (final category in objectList(json['categories'], field: 'categories'))
      AudienceCategory(
        id: requireField<String>(category, 'id'),
        name: stringOrNull(category['name']) ?? '',
        guardianCount: intOrNull(category['guardian_count']) ?? 0,
      ),
  ],
  groups: [
    for (final group in objectList(json['groups'], field: 'groups'))
      AudienceCategory(
        id: requireField<String>(group, 'id'),
        name: stringOrNull(group['name']) ?? '',
        guardianCount: intOrNull(group['guardian_count']) ?? 0,
      ),
  ],
);

/// The `POST /announcements` body.
Map<String, Object?> announcementDraftToJson(AnnouncementDraft draft) =>
    <String, Object?>{
      'title': draft.title.trim(),
      if (stringOrNull(draft.body) case final String body) 'body': body,
      'audience': audienceToJson(draft.audience),
      'priority': draft.priority.wireValue,
      if (draft.ackRequired) 'ack_required': true,
      if (draft.expireAt case final DateTime expireAt)
        'expire_at': expireAt.toUtc().toIso8601String(),
    };
