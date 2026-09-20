import 'package:meta/meta.dart';

import '../domain/conversation.dart';
import '../domain/dashboard_overview.dart';
import '../domain/memories_review.dart';
import 'order_alerts.dart';

/// The counts on the bottom nav.
///
/// Each badge answers one question the executive would otherwise open the
/// tab to ask: how many danger alerts point at groups, how many posts wait
/// for review, how many threads carry unread messages or an open report.
@immutable
class ExecutiveTabBadges {
  const ExecutiveTabBadges({
    this.groups = 0,
    this.memories = 0,
    this.messages = 0,
  });

  static const ExecutiveTabBadges none = ExecutiveTabBadges();

  final int groups;
  final int memories;
  final int messages;

  static ExecutiveTabBadges from({
    DashboardOverview? overview,
    ReviewQueue? queue,
    List<ConversationSummary>? conversations,
  }) => ExecutiveTabBadges(
    groups: overview == null
        ? 0
        : dangerCount(
            overview.alerts.where(
              (alert) => alert.destination == AlertDestination.groups,
            ),
          ),
    memories: queue?.posts.length ?? 0,
    messages:
        conversations
            ?.where((thread) => thread.unreadCount > 0 || thread.hasOpenReport)
            .length ??
        0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutiveTabBadges &&
          other.groups == groups &&
          other.memories == memories &&
          other.messages == messages;

  @override
  int get hashCode => Object.hash(groups, memories, messages);
}
