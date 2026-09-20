/// Wire mapping for the Memories review queue (proposed paths, Epic F).
library;

import '../../../core/network/api_envelope.dart';
import '../domain/memories_review.dart';
import 'wire_helpers.dart';

const Map<String, ImageRightsLevel> _imageRightsByWire = {
  'allowed': ImageRightsLevel.allowed,
  'app_only': ImageRightsLevel.appOnly,
  'not_allowed': ImageRightsLevel.notAllowed,
};

const Map<String, ModerationMode> _moderationByWire = {
  'publish_then_moderate': ModerationMode.publishThenModerate,
  'approve_before_publish': ModerationMode.approveBeforePublish,
};

/// Parses `moderation_mode`, returning null for absent *or* unknown —
/// "not yet set" is the honest rendering of both.
ModerationMode? moderationModeFromWire(Object? value) =>
    value is String ? _moderationByWire[value] : null;

TaggedChild taggedChildFromJson(Map<String, Object?> json) => TaggedChild(
  id: firstString(json, ['child_id', 'id']) ?? '',
  name: firstString(json, ['full_name', 'name']) ?? '',
  // Unknown reads as not_allowed: the failure mode of guessing wrong on a
  // child's image rights is publishing a photo their guardian refused.
  imageRights: enumFromWire(
    json['image_rights_level'] ?? json['image_rights'],
    _imageRightsByWire,
    fallback: ImageRightsLevel.notAllowed,
  ),
);

ReviewPost reviewPostFromJson(Map<String, Object?> json) {
  final album = objectOrNull(json['album']);
  return ReviewPost(
    id: requireField<String>(json, 'id'),
    albumTitle:
        stringOrNull(album?['title']) ??
        stringOrNull(json['album_title']) ??
        '',
    groupName:
        stringOrNull(album?['group_name']) ?? stringOrNull(json['group_name']),
    authorName: stringOrNull(json['author_name']) ?? '',
    postedAt:
        dateOrNull(json['posted_at']) ??
        dateOrNull(json['created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    mediaCount: intOrNull(json['media_count']) ?? 1,
    thumbnailUrl: stringOrNull(json['thumbnail_url']),
    tags: objectList(
      json['tags'],
      field: 'tags',
    ).map(taggedChildFromJson).toList(growable: false),
    isBlocked:
        boolOr(json['is_blocked'], false) ||
        stringOrNull(json['moderation_status']) == 'hidden' &&
            stringOrNull(json['hidden_reason']) == 'consent_blocked',
  );
}

ReviewQueue reviewQueueFromJson(Map<String, Object?> json) => ReviewQueue(
  posts: objectList(
    json['data'] ?? json['posts'],
    field: 'data',
  ).map(reviewPostFromJson).toList(growable: false),
  moderationMode: moderationModeFromWire(json['moderation_mode']),
);

MemoriesAlbum memoriesAlbumFromJson(Map<String, Object?> json) => MemoriesAlbum(
  id: requireField<String>(json, 'id'),
  title: requireField<String>(json, 'title'),
  postCount: intOrNull(json['post_count']) ?? 0,
  groupName: stringOrNull(json['group_name']),
  coverUrl: stringOrNull(json['cover_url']),
  moderationMode: moderationModeFromWire(json['moderation_mode']),
);
