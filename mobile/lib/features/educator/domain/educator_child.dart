/// A child as their educator sees them (EDU-M-06).
library;

import 'package:meta/meta.dart';

import '../../executive/domain/executive_child.dart'
    show AccountStatus, ChildGroupRef, ImageRightsLevel, AttendanceRatio;

export '../../executive/domain/executive_child.dart'
    show
        AccountStatus,
        AttendanceRatio,
        ChildGroupRef,
        HealthReveal,
        ImageRightsLevel;

@immutable
class EducatorGuardian {
  const EducatorGuardian({
    required this.id,
    required this.displayName,
    required this.relationship,
    required this.account,
    required this.isEmergencyContact,
  });

  final String id;
  final String displayName;
  final String relationship;
  final AccountStatus account;
  final bool isEmergencyContact;
}

@immutable
class EducatorChildProfile {
  const EducatorChildProfile({
    required this.id,
    required this.fullName,
    required this.hasHealthAlert,
    required this.imageRights,
    required this.homeworkDone,
    required this.homeworkTotal,
    required this.guardians,
    this.dateOfBirth,
    this.schoolLevel,
    this.group,
    this.seasonAttendance,
    this.conversationId,
  });

  final String id;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? schoolLevel;
  final ChildGroupRef? group;
  final bool hasHealthAlert;
  final ImageRightsLevel imageRights;
  final AttendanceRatio? seasonAttendance;
  final int homeworkDone;
  final int homeworkTotal;
  final List<EducatorGuardian> guardians;
  final String? conversationId;
}

/// The outcome of a recorded emergency call: the number is dialled, never shown.
@immutable
class EmergencyCall {
  const EmergencyCall({
    required this.guardianName,
    required this.recordedAt,
    this.phone,
  });

  final String guardianName;
  final String? phone;
  final DateTime recordedAt;
}
