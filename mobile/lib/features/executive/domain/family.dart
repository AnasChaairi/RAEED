import 'package:meta/meta.dart';

import 'executive_child.dart' show AccountStatus, ChildGroupRef;

export 'executive_child.dart' show AccountStatus;

/// How far a household is into using the app.
enum FamilyStatus {
  /// Every guardian has signed in.
  active,

  /// Some have.
  partial,

  /// None yet — invitations are out.
  pending,
}

@immutable
class FamilyGuardian {
  const FamilyGuardian({
    required this.id,
    required this.displayName,
    required this.account,
  });

  final String id;
  final String displayName;
  final AccountStatus account;
}

@immutable
class FamilyChild {
  const FamilyChild({required this.id, required this.fullName, this.group});

  final String id;
  final String fullName;
  final ChildGroupRef? group;
}

/// A household — the children who share the same current guardians.
@immutable
class Family {
  const Family({
    required this.id,
    required this.label,
    required this.guardians,
    required this.children,
    required this.status,
  });

  final String id;
  final String label;
  final List<FamilyGuardian> guardians;
  final List<FamilyChild> children;
  final FamilyStatus status;

  /// Whether any guardian is still waiting to sign in.
  bool get canResendInvitation =>
      guardians.any((guardian) => guardian.account == AccountStatus.pending);
}

/// An educator, for the new-group form.
@immutable
class Educator {
  const Educator({
    required this.id,
    required this.displayName,
    required this.groupCount,
  });

  final String id;
  final String displayName;
  final int groupCount;
}

/// A guardian being entered in the new-family wizard.
@immutable
class GuardianDraft {
  const GuardianDraft({
    this.displayName = '',
    this.phone = '',
    this.relationship = 'parent',
  });

  final String displayName;

  /// National digits after +212, as typed.
  final String phone;
  final String relationship;

  GuardianDraft copyWith({
    String? displayName,
    String? phone,
    String? relationship,
  }) => GuardianDraft(
    displayName: displayName ?? this.displayName,
    phone: phone ?? this.phone,
    relationship: relationship ?? this.relationship,
  );

  bool get isComplete =>
      displayName.trim().length >= 2 && RegExp(r'^[5-7]\d{8}$').hasMatch(phone);

  /// E.164, as the API wants it.
  String get e164 => '+212$phone';
}

/// A child being entered in the new-family wizard.
@immutable
class ChildDraft {
  const ChildDraft({this.fullName = '', this.dateOfBirth, this.groupId});

  final String fullName;
  final DateTime? dateOfBirth;

  /// Null means "later" — the child lands on the unassigned list.
  final String? groupId;

  ChildDraft copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? groupId,
    bool clearGroup = false,
  }) => ChildDraft(
    fullName: fullName ?? this.fullName,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    groupId: clearGroup ? null : groupId ?? this.groupId,
  );

  bool get isComplete => fullName.trim().length >= 2 && dateOfBirth != null;
}

/// The whole wizard.
@immutable
class FamilyDraft {
  const FamilyDraft({
    this.guardians = const [GuardianDraft()],
    this.children = const [ChildDraft()],
  });

  final List<GuardianDraft> guardians;
  final List<ChildDraft> children;

  bool get guardiansComplete =>
      guardians.isNotEmpty && guardians.every((g) => g.isComplete);
  bool get childrenComplete =>
      children.isNotEmpty && children.every((c) => c.isComplete);
  int get unassignedCount => children.where((c) => c.groupId == null).length;

  FamilyDraft copyWith({
    List<GuardianDraft>? guardians,
    List<ChildDraft>? children,
  }) => FamilyDraft(
    guardians: guardians ?? this.guardians,
    children: children ?? this.children,
  );
}

/// What creating a family did.
@immutable
class FamilyCreated {
  const FamilyCreated({
    required this.guardianIds,
    required this.childIds,
    required this.invitations,
    this.guardians = const [],
  });

  final List<String> guardianIds;
  final List<String> childIds;

  /// How many accounts were created (the rest already existed).
  final int invitations;

  /// Each guardian with the first password of a new account, shown once.
  final List<GuardianCredential> guardians;
}

/// A guardian's first password, handed over in person by the executive.
///
/// [password] is null when the phone already had an account — that one keeps
/// its password. Held in memory only for the dialog that shows it; never
/// persisted, never logged.
@immutable
class GuardianCredential {
  const GuardianCredential({
    required this.id,
    required this.displayName,
    required this.password,
  });

  final String id;
  final String displayName;
  final String? password;
}

/// One weekly slot of a group's schedule.
@immutable
class ScheduleSlot {
  const ScheduleSlot({
    required this.weekday,
    required this.startsAt,
    required this.endsAt,
  });

  /// 0 is Sunday.
  final int weekday;
  final String startsAt;
  final String endsAt;
}

/// The new-group form.
@immutable
class GroupDraft {
  const GroupDraft({
    this.name = '',
    this.categoryId,
    this.capacity = 20,
    this.slot = const ScheduleSlot(
      weekday: 5,
      startsAt: '16:00',
      endsAt: '18:00',
    ),
    this.educatorIds = const {},
    this.childIds = const {},
  });

  final String name;
  final String? categoryId;
  final int capacity;
  final ScheduleSlot slot;
  final Set<String> educatorIds;
  final Set<String> childIds;

  bool get hasName => name.trim().length >= 2;
  bool get isComplete =>
      hasName && categoryId != null && educatorIds.isNotEmpty;

  GroupDraft copyWith({
    String? name,
    String? categoryId,
    int? capacity,
    ScheduleSlot? slot,
    Set<String>? educatorIds,
    Set<String>? childIds,
  }) => GroupDraft(
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    capacity: capacity ?? this.capacity,
    slot: slot ?? this.slot,
    educatorIds: educatorIds ?? this.educatorIds,
    childIds: childIds ?? this.childIds,
  );
}
