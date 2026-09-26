/// The educator's groups and rosters (EDU-M-06).
library;

import 'package:meta/meta.dart';

import '../../executive/domain/executive_child.dart' show ImageRightsLevel;

export '../../executive/domain/executive_child.dart' show ImageRightsLevel;

/// One child on the roster: flags, never text.
@immutable
class RosterChild {
  const RosterChild({
    required this.id,
    required this.fullName,
    required this.hasHealthAlert,
    required this.imageRights,
    required this.present,
    required this.expected,
    required this.consecutiveAbsences,
    required this.isNew,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final String? photoUrl;
  final bool hasHealthAlert;
  final ImageRightsLevel imageRights;
  final int present;
  final int expected;

  /// Three of the last three sessions absent — a care flag, not a ranking.
  final int consecutiveAbsences;
  final bool isNew;

  bool get needsCare => consecutiveAbsences >= 3;
  bool get canBeTagged => imageRights != ImageRightsLevel.notAllowed;
}
