import 'package:meta/meta.dart';

/// How loudly an announcement asks to be seen.
///
/// `urgent` feeds the same critical-alert pipeline as an unexplained absence
/// (`specs/13-roadmap-and-tickets.md`, Epic E) — so on the home strip it is
/// ordered first and rendered in the alert tone, not merely bolder.
enum AnnouncementPriority {
  /// The ordinary case.
  normal('normal'),

  /// Urgent — surfaced above everything else on the strip.
  urgent('urgent');

  const AnnouncementPriority(this.wireValue);

  /// The value as it travels in `specs/04-api/openapi.yaml`.
  final String wireValue;
}

/// An announcement, as the read-only home strip needs it.
///
/// The composer is a later epic (Epic E); this is the parent/educator side of
/// `GET /announcements` only.
@immutable
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.priority,
    required this.pinned,
    required this.publishAt,
    this.body,
  });

  /// `announcement.id`.
  final String id;

  /// The headline.
  final String title;

  /// How loudly it asks to be seen.
  final AnnouncementPriority priority;

  /// Whether it is pinned to the top of the strip.
  final bool pinned;

  /// When it becomes visible, in UTC. A future value is not yet live.
  final DateTime publishAt;

  /// The longer text, when there is one.
  final String? body;

  /// Whether this announcement is live at [now].
  bool isActiveAt(DateTime now) => !publishAt.isAfter(now.toUtc());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          other.id == id &&
          other.title == title &&
          other.priority == priority &&
          other.pinned == pinned &&
          other.publishAt == publishAt &&
          other.body == body;

  @override
  int get hashCode => Object.hash(id, title, priority, pinned, publishAt, body);
}
