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

  Future<List<Educator>> fetchEducators();

  Future<ExecutiveGroup> createGroup(GroupDraft draft);

  /// Moves [childIds] into [groupId] as their main group; returns the group's
  /// enrolment afterwards.
  Future<({int enrolledCount, int? capacity})> assignChildren({
    required String groupId,
    required List<String> childIds,
  });
}
