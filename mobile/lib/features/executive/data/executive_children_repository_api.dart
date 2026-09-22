import '../../../core/network/api_client.dart';
import '../domain/executive_child.dart';
import '../domain/executive_children_repository.dart';
import 'executive_child_dto.dart';

/// [ExecutiveChildrenRepository] against `/children`.
class ApiExecutiveChildrenRepository implements ExecutiveChildrenRepository {
  const ApiExecutiveChildrenRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ExecutiveChildSummary>> fetchChildren({
    String? query,
    String? categoryId,
    bool unassigned = false,
  }) async {
    final page = await _client.getList<ExecutiveChildSummary>(
      '/children',
      executiveChildSummaryFromJson,
      query: {
        'q': query?.trim().isEmpty ?? true ? null : query!.trim(),
        'category_id': categoryId,
        'unassigned': unassigned ? 'true' : null,
      },
    );
    return page.items;
  }

  @override
  Future<ExecutiveChildProfile> fetchProfile(String childId) async =>
      executiveChildProfileFromJson(
        await _client.getObject('/children/$childId'),
      );

  @override
  Future<HealthReveal> revealHealth(String childId) async =>
      healthRevealFromJson(
        await _client.getObject('/children/$childId/health'),
      );

  @override
  Future<PhoneReveal> revealPhone({
    required String childId,
    required String guardianId,
  }) async => phoneRevealFromJson(
    await _client.getObject('/children/$childId/guardians/$guardianId/phone'),
  );
}
