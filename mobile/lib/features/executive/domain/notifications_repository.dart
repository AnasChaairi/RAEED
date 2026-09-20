import 'notification_item.dart';

/// The notification centre. Proposed path `GET /notifications`.
abstract interface class NotificationsRepository {
  /// Newest first.
  Future<List<NotificationItem>> fetchNotifications();

  Future<void> markAllRead();
}
