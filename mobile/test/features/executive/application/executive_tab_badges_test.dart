import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/application/executive_tab_badges.dart';
import 'package:raeed/features/executive/domain/conversation.dart';
import 'package:raeed/features/executive/domain/dashboard_overview.dart';
import 'package:raeed/features/executive/domain/memories_review.dart';

void main() {
  DashboardAlert alert(AlertSeverity severity, AlertDestination destination) =>
      DashboardAlert(
        id: '${severity.name}-${destination.name}',
        severity: severity,
        text: '',
        destination: destination,
        raisedAt: DateTime.utc(2026, 9, 20),
      );

  ReviewPost post(String id) => ReviewPost(
    id: id,
    albumTitle: 'a',
    authorName: 'b',
    postedAt: DateTime.utc(2026, 9, 20),
    mediaCount: 1,
    tags: const [],
  );

  ConversationSummary thread(
    String id, {
    int unread = 0,
    bool report = false,
  }) => ConversationSummary(
    id: id,
    kind: ConversationKind.child,
    title: id,
    isMember: false,
    unreadCount: unread,
    hasOpenReport: report,
  );

  test('nothing loaded means no badges', () {
    expect(ExecutiveTabBadges.from(), ExecutiveTabBadges.none);
  });

  test('groups counts danger alerts pointing at groups only', () {
    final overview = DashboardOverview(
      alerts: [
        alert(AlertSeverity.danger, AlertDestination.groups),
        alert(AlertSeverity.danger, AlertDestination.messages),
        alert(AlertSeverity.warning, AlertDestination.groups),
      ],
      stats: const [],
      weeklyAttendance: null,
      todaySessions: const [],
      fetchedAt: DateTime.utc(2026, 9, 20),
    );
    expect(ExecutiveTabBadges.from(overview: overview).groups, 1);
  });

  test('memories counts the queue', () {
    final queue = ReviewQueue(posts: [post('p1'), post('p2')]);
    expect(ExecutiveTabBadges.from(queue: queue).memories, 2);
  });

  test('messages counts threads with unread or an open report, once each', () {
    final threads = [
      thread('quiet'),
      thread('unread', unread: 3),
      thread('reported', report: true),
      thread('both', unread: 1, report: true),
    ];
    expect(ExecutiveTabBadges.from(conversations: threads).messages, 3);
  });
}
