import 'package:meta/meta.dart';

import 'child_age.dart';
import 'child_day_status.dart';
import 'session_summary.dart';

/// The group a child currently sits in, as named on a list payload.
@immutable
class ChildGroupRef {
  const ChildGroupRef({required this.id, required this.name});

  /// `group.id`.
  final String id;

  /// The group's display name.
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildGroupRef && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// A child as they appear in a list — the `Child` schema in
/// `specs/04-api/openapi.yaml`.
///
/// Note what is *not* here: no health text, no date of birth beyond what the
/// age needs, no guardian details. The contract is explicit that
/// `health_alert` is a "presence-only flag; full health text is never inlined
/// in a list response", and this entity mirrors that. A list model that could
/// carry health detail is a list model that will eventually render it.
@immutable
class Child {
  const Child({
    required this.id,
    required this.fullName,
    required this.healthAlert,
    this.photoUrl,
    this.group,
    this.dateOfBirth,
    this.nextSession,
    this.todayStatus = const ChildDayStatus.noSession(),
  });

  /// `child.id`.
  final String id;

  /// The child's full name.
  final String fullName;

  /// Whether the child has health information an educator must know about.
  ///
  /// A boolean, never the information itself: in list views the badge is icon
  /// only, and the text is reachable only by tapping through
  /// (`specs/06-mobile-app-spec.md`). Health details must not be readable over
  /// someone's shoulder in a list.
  final bool healthAlert;

  /// The child's photo, when one has been uploaded and consent allows it.
  final String? photoUrl;

  /// The group the child currently belongs to.
  ///
  /// Nullable: `child_group` is time-bounded (`valid_from`/`valid_to`), so a
  /// child between groups at a season boundary genuinely has none, and that is
  /// a state to render, not a payload to reject.
  final ChildGroupRef? group;

  /// Date of birth, from which the card's age is derived.
  final DateTime? dateOfBirth;

  /// The next session this child is expected at.
  final SessionSummary? nextSession;

  /// Today's presence/attendance state.
  final ChildDayStatus todayStatus;

  /// The child's age in whole years on [today], or null when it cannot be
  /// derived.
  int? ageOn(DateTime today) {
    final dob = dateOfBirth;
    return dob == null ? null : ageInYearsOn(dob, today);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Child &&
          other.id == id &&
          other.fullName == fullName &&
          other.healthAlert == healthAlert &&
          other.photoUrl == photoUrl &&
          other.group == group &&
          other.dateOfBirth == dateOfBirth &&
          other.nextSession == nextSession &&
          other.todayStatus == todayStatus;

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    healthAlert,
    photoUrl,
    group,
    dateOfBirth,
    nextSession,
    todayStatus,
  );
}
