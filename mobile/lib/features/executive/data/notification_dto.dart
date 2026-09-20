/// Wire mapping for the notification centre (proposed `GET /notifications`).
library;

import '../../../core/network/api_envelope.dart';
import '../domain/notification_item.dart';
import 'dashboard_dto.dart';
import 'wire_helpers.dart';

const Map<String, NotificationKind> _kindByWire = {
  'critical': NotificationKind.critical,
  'request': NotificationKind.request,
  'memories': NotificationKind.memories,
  'security': NotificationKind.security,
  'other': NotificationKind.other,
};

NotificationItem notificationItemFromJson(Map<String, Object?> json) =>
    NotificationItem(
      id: requireField<String>(json, 'id'),
      kind: enumFromWire(
        json['kind'],
        _kindByWire,
        fallback: NotificationKind.other,
      ),
      title: requireField<String>(json, 'title'),
      body: stringOrNull(json['body']),
      sentAt: requireDateTime(json, 'sent_at'),
      isRead:
          boolOr(json['is_read'] ?? json['read'], false) ||
          json['read_at'] != null,
      destination: alertDestinationFromWire(json['destination']),
    );
