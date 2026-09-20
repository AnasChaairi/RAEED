import '../domain/notification_item.dart';

/// The filter chips on the notification centre.
enum NotificationFilter { all, critical, requests, memories }

/// Applies [filter], preserving the server's newest-first order.
List<NotificationItem> filterNotifications(
  Iterable<NotificationItem> items,
  NotificationFilter filter,
) {
  bool keep(NotificationItem item) => switch (filter) {
    NotificationFilter.all => true,
    NotificationFilter.critical => item.kind == NotificationKind.critical,
    NotificationFilter.requests => item.kind == NotificationKind.request,
    NotificationFilter.memories => item.kind == NotificationKind.memories,
  };
  return items.where(keep).toList(growable: false);
}

/// Unread notifications — the bell's dot.
int unreadCount(Iterable<NotificationItem> items) =>
    items.where((item) => !item.isRead).length;
