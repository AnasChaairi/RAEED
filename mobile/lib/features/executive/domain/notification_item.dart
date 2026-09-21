import 'package:meta/meta.dart';

import 'dashboard_overview.dart';

/// What kind of thing a notification is about — drives the icon and filter.
enum NotificationKind {
  /// Absence alerts and everything else on the critical channel.
  critical('critical'),

  /// Something waiting for the executive's decision.
  request('request'),

  memories('memories'),

  /// Sign-ins, new devices.
  security('security'),

  other('other');

  const NotificationKind(this.wireValue);

  final String wireValue;
}

/// One notification.
@immutable
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.sentAt,
    this.body,
    this.isRead = false,
    this.destination,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String? body;
  final DateTime sentAt;
  final bool isRead;
  final AlertDestination? destination;
}
