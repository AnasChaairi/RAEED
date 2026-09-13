import 'package:meta/meta.dart';

/// The next session a child is expected at, as summarised on a home card.
///
/// Deliberately not the full `session` entity from
/// `specs/03-domain-model/entities.md`: the home card answers "what's next",
/// which needs a time, a group and a way to navigate there. The sessions
/// feature owns the full entity.
@immutable
class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.startsAt,
    this.groupId,
    this.title,
  });

  /// `session.id`.
  final String id;

  /// When the session starts, in UTC.
  ///
  /// Held in UTC and converted for display exactly once, at the widget that
  /// renders it — a card that formats a local `DateTime` it received from JSON
  /// is one timezone bug away from telling a parent the wrong hour.
  final DateTime startsAt;

  /// The group this session belongs to, where the payload names it.
  final String? groupId;

  /// The session's own title, when an educator has set one.
  final String? title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionSummary &&
          other.id == id &&
          other.startsAt == startsAt &&
          other.groupId == groupId &&
          other.title == title;

  @override
  int get hashCode => Object.hash(id, startsAt, groupId, title);
}
