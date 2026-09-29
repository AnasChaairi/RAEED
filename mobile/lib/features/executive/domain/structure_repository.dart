import 'structure.dart';

/// Seasons, categories, branches and the audit log (EXEC-M-12/13).
///
/// The category list is open to any signed-in caller; everything else is
/// the admin's, and a non-admin's call is refused with `scope.forbidden`
/// — and recorded, which the "admins only" card says.
abstract interface class StructureRepository {
  Future<List<Category>> fetchCategories();

  /// Adds a category by name; age range and gender wait for open decision #1.
  Future<Category> createCategory({required String name});

  Future<List<Season>> fetchSeasons();

  /// Opens a season, active from creation; recorded.
  Future<Season> createSeason({
    required String label,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void> archiveSeason(String seasonId);
  Future<List<Branch>> fetchBranches();
  Future<Branch> createBranch({required String name, String? address});

  /// Newest first; [action] narrows to one kind (`child.health_view`).
  Future<List<AuditEntry>> fetchAuditLog({String? action});
}
