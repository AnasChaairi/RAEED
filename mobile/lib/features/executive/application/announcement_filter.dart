import '../domain/announcement_draft.dart';

/// Keeps the announcements in [state] at [now], preserving server order.
List<ExecutiveAnnouncement> announcementsInState(
  Iterable<ExecutiveAnnouncement> announcements,
  AnnouncementState state,
  DateTime now,
) => announcements
    .where((announcement) => announcement.stateAt(now) == state)
    .toList(growable: false);

/// How many announcements sit in each state — the counts on the filter chips.
Map<AnnouncementState, int> announcementStateCounts(
  Iterable<ExecutiveAnnouncement> announcements,
  DateTime now,
) {
  final counts = {for (final state in AnnouncementState.values) state: 0};
  for (final announcement in announcements) {
    final state = announcement.stateAt(now);
    counts[state] = counts[state]! + 1;
  }
  return counts;
}
