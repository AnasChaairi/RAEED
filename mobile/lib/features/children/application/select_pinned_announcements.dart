/// Picks what the home screen's announcements strip shows.
///
/// `specs/06-mobile-app-spec.md` asks for a "pinned/active announcements
/// strip" on Parent Home — a strip, not a feed. The full list lives in the
/// announcements feature; this narrows it to what earns a place above the
/// child cards.
library;

import '../domain/announcement.dart';

/// How many announcements the strip shows at most.
///
/// The strip sits above the child cards, and the cards are why the parent
/// opened the app. Three is enough to carry an urgent notice plus context
/// without pushing the first child below the fold on a small phone.
const int maxStripAnnouncements = 3;

/// Returns the announcements the strip should render, in display order.
///
/// Filters to those already live at [now] — a scheduled announcement is not
/// news yet — and orders urgent first, then pinned, then newest.
List<Announcement> selectPinnedAnnouncements(
  List<Announcement> announcements,
  DateTime now, {
  int limit = maxStripAnnouncements,
}) {
  final active = announcements.where((a) => a.isActiveAt(now)).toList()
    ..sort(_byProminence);
  return active.take(limit).toList(growable: false);
}

int _byProminence(Announcement a, Announcement b) {
  final urgency = _urgencyRank(b).compareTo(_urgencyRank(a));
  if (urgency != 0) return urgency;
  final pinned = _pinnedRank(b).compareTo(_pinnedRank(a));
  if (pinned != 0) return pinned;
  return b.publishAt.compareTo(a.publishAt);
}

int _urgencyRank(Announcement a) =>
    a.priority == AnnouncementPriority.urgent ? 1 : 0;

int _pinnedRank(Announcement a) => a.pinned ? 1 : 0;
