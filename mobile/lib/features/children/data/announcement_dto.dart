/// Wire → domain mapping for the `Announcement` schema.
library;

import '../../../core/error/raeed_exception.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/announcement.dart';

const Map<String, AnnouncementPriority> _priorityByWire = {
  'normal': AnnouncementPriority.normal,
  'urgent': AnnouncementPriority.urgent,
};

/// Parses the `Announcement` schema.
Announcement announcementFromJson(Map<String, Object?> json) => Announcement(
  id: requireField<String>(json, 'id'),
  title: requireField<String>(json, 'title'),
  priority: enumFromWire(
    json['priority'],
    _priorityByWire,
    // An unknown priority reads as normal, not urgent: a future priority value
    // must not be able to promote itself onto the alert treatment by accident.
    fallback: AnnouncementPriority.normal,
  ),
  pinned: json['pinned'] as bool? ?? false,
  publishAt: requireDateTime(json, 'publish_at'),
  body: _optionalString(json, 'body'),
);

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw ContractException(message: 'Field `$key` should be a string');
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
