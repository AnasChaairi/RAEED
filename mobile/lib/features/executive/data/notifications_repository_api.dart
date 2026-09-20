import '../../../core/network/api_client.dart';
import '../domain/notification_item.dart';
import '../domain/notifications_repository.dart';
import 'notification_dto.dart';

/// [NotificationsRepository] against the proposed path.
class ApiNotificationsRepository implements NotificationsRepository {
  const ApiNotificationsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    final page = await _client.getList<NotificationItem>(
      '/notifications',
      notificationItemFromJson,
    );
    return page.items;
  }

  @override
  Future<void> markAllRead() => _client.post('/notifications/read-all');
}
