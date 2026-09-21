import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/application/notification_filter.dart';
import 'package:raeed/features/executive/domain/notification_item.dart';

void main() {
  NotificationItem item(
    String id,
    NotificationKind kind, {
    bool read = false,
  }) => NotificationItem(
    id: id,
    kind: kind,
    title: id,
    sentAt: DateTime.utc(2026, 9, 20),
    isRead: read,
  );

  final items = [
    item('absence', NotificationKind.critical),
    item('change-request', NotificationKind.request, read: true),
    item('photos', NotificationKind.memories),
    item('new-device', NotificationKind.security, read: true),
  ];

  test('all keeps everything in order', () {
    expect(
      filterNotifications(items, NotificationFilter.all).map((i) => i.id),
      ['absence', 'change-request', 'photos', 'new-device'],
    );
  });

  test('each filter keeps only its kind', () {
    expect(
      filterNotifications(items, NotificationFilter.critical).single.id,
      'absence',
    );
    expect(
      filterNotifications(items, NotificationFilter.requests).single.id,
      'change-request',
    );
    expect(
      filterNotifications(items, NotificationFilter.memories).single.id,
      'photos',
    );
  });

  test('unreadCount ignores read items', () {
    expect(unreadCount(items), 2);
  });
}
