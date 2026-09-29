import 'executive_group.dart';
import 'family.dart';

/// Families, invitations, educators and group creation (EXEC-M-10).
abstract interface class FamiliesRepository {
  Future<List<Family>> fetchFamilies();

  /// Creates guardians, children and links in one recorded act.
  Future<FamilyCreated> createFamily(FamilyDraft draft);

  /// Re-sends the sign-in invitation; recorded.
  /// Issues [guardianId] a fresh password and returns it, once.
  Future<String> resendInvitation(String guardianId);

  // --- One household (EXEC-M-10b). Every mutation returns the family as it
  // now is: its id is the guardian set, so it changes after a link or unlink.

  Future<Family> fetchFamily(String familyId);

  /// Only the fields set on [patch] change. A phone change signs the guardian
  /// out on every device; the server records which fields changed.
  Future<Family> updateGuardian({
    required String familyId,
    required String guardianId,
    required GuardianPatch patch,
  });

  /// Links [guardian] to every child of the household. A phone that already
  /// has an account is linked and gets no password.
  Future<GuardianAdded> addGuardian({
    required String familyId,
    required GuardianDraft guardian,
  });

  /// Unlinks [guardianId] from every child of the household; refused with
  /// `children.last_guardian` when a child would be left with none.
  Future<Family> unlinkGuardian({
    required String familyId,
    required String guardianId,
  });

  /// Adds [child] to the household, linked to every current guardian.
  Future<ChildAdded> addChild({
    required String familyId,
    required ChildDraft child,
  });

  /// Corrects a child's name or birth date; recorded.
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    required ChildPatch patch,
  });

  Future<List<Educator>> fetchEducators();

  Future<ExecutiveGroup> createGroup(GroupDraft draft);

  /// Moves [childIds] into [groupId] as their main group; returns the group's
  /// enrolment afterwards.
  Future<({int enrolledCount, int? capacity})> assignChildren({
    required String groupId,
    required List<String> childIds,
  });
}
