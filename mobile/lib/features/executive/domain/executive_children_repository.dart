import 'executive_child.dart';

/// The executive's reads of children (EXEC-M-08/09).
///
/// The two sensitive reads are separate methods on purpose. Each is a
/// server route that writes the audit entry before answering, and a screen
/// that could not fetch the profile without also fetching the health text
/// would log a reveal the executive never asked for.
abstract interface class ExecutiveChildrenRepository {
  Future<List<ExecutiveChildSummary>> fetchChildren({
    String? query,
    String? categoryId,
    bool unassigned = false,
  });

  Future<ExecutiveChildProfile> fetchProfile(String childId);

  /// Recorded as `child.health_view` (`AUD-03`).
  Future<HealthReveal> revealHealth(String childId);

  /// Recorded as `guardian.phone_reveal` (`MSG-06`).
  Future<PhoneReveal> revealPhone({
    required String childId,
    required String guardianId,
  });
}
