import 'package:meta/meta.dart';

import '../../children/domain/child.dart';
import '../../children/domain/child_detail.dart'
    show HealthInfo, ImageRightsLevel;

export '../../children/domain/child.dart' show Child, ChildGroupRef;
export '../../children/domain/child_detail.dart'
    show HealthInfo, ImageRightsLevel;

/// Present-or-late marks against sessions that took place.
@immutable
class AttendanceRatio {
  const AttendanceRatio({required this.present, required this.expected});

  final int present;
  final int expected;

  /// Null when nothing was expected yet — no rate is claimed from zero.
  int? get percent => expected == 0 ? null : (present * 100 / expected).round();
}

/// A child as the executive's list shows them: the summary plus the two
/// oversight-only columns.
@immutable
class ExecutiveChildSummary {
  const ExecutiveChildSummary({
    required this.child,
    required this.imageRights,
    this.attendance,
  });

  final Child child;
  final ImageRightsLevel imageRights;
  final AttendanceRatio? attendance;

  String get id => child.id;
  String get fullName => child.fullName;
}

/// Whether a guardian has ever signed in.
enum AccountStatus { active, pending }

@immutable
class GuardianSummary {
  const GuardianSummary({
    required this.id,
    required this.displayName,
    required this.relationship,
    required this.account,
    this.lastSeenAt,
    this.phoneHint,
  });

  final String id;
  final String displayName;

  /// As stored — `mother`, `father`, `parent`, or free text.
  final String relationship;
  final AccountStatus account;
  final DateTime? lastSeenAt;

  /// The masked tail, e.g. "•• 07". The full number is a logged reveal.
  final String? phoneHint;
}

@immutable
class PrivacyConsent {
  const PrivacyConsent({
    required this.guardianId,
    required this.version,
    required this.at,
  });

  final String guardianId;
  final int version;
  final DateTime at;
}

@immutable
class ImageRightsConsent {
  const ImageRightsConsent({
    required this.guardianId,
    required this.level,
    required this.version,
    required this.at,
  });

  final String guardianId;
  final ImageRightsLevel level;
  final int version;
  final DateTime at;
}

@immutable
class ChildGroupMembership {
  const ChildGroupMembership({
    required this.id,
    required this.name,
    required this.isMain,
    required this.attendance,
    this.educatorNames = const [],
    this.scheduleLabel,
  });

  final String id;
  final String name;
  final bool isMain;
  final List<String> educatorNames;
  final String? scheduleLabel;
  final AttendanceRatio attendance;
}

/// The executive's profile of a child (EXEC-M-09).
///
/// Carries no health text: that is [HealthReveal], fetched through the route
/// that logs it, and never held on this object so a rebuild cannot show it
/// without the reveal having happened.
@immutable
class ExecutiveChildProfile {
  const ExecutiveChildProfile({
    required this.id,
    required this.fullName,
    required this.hasHealthAlert,
    required this.imageRights,
    required this.guardians,
    required this.privacyConsents,
    required this.imageRightsConsents,
    required this.groups,
    this.dateOfBirth,
    this.schoolLevel,
    this.mainGroup,
    this.seasonAttendance,
    this.conversationId,
  });

  final String id;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? schoolLevel;
  final ChildGroupRef? mainGroup;
  final bool hasHealthAlert;
  final ImageRightsLevel imageRights;
  final AttendanceRatio? seasonAttendance;
  final List<GuardianSummary> guardians;
  final List<PrivacyConsent> privacyConsents;
  final List<ImageRightsConsent> imageRightsConsents;
  final List<ChildGroupMembership> groups;
  final String? conversationId;
}

/// The health text, with the moment its reading was recorded.
@immutable
class HealthReveal {
  const HealthReveal({
    required this.health,
    required this.viewedAt,
    this.specialNeedsNotes,
  });

  final HealthInfo health;
  final String? specialNeedsNotes;
  final DateTime viewedAt;
}

/// A guardian's number, with the moment its reveal was recorded.
@immutable
class PhoneReveal {
  const PhoneReveal({required this.phone, required this.revealedAt});

  final String? phone;
  final DateTime revealedAt;
}
