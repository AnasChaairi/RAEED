import 'educator_child.dart';

/// The educator's reads of a child in their group (EDU-M-06).
abstract interface class EducatorChildrenRepository {
  Future<EducatorChildProfile> fetchProfile(String childId);

  /// Recorded server-side as `guardian.emergency_call`.
  Future<EmergencyCall> emergencyCall(String childId);
}
