import '../../../core/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/child.dart';
import '../domain/child_detail.dart';
import '../domain/children_repository.dart';
import 'child_dto.dart';

/// [ChildrenRepository] against the REST API in `specs/04-api/openapi.yaml`.
///
/// Thin by design. It builds a path, hands the decoding to the DTO mappers and
/// lets every failure travel as the `RaeedException` the [ApiClient] already
/// produced — it catches nothing. A repository that swallowed a
/// `scope.forbidden` into an empty list would turn a permission failure into
/// what looks like a child with no data, which is precisely the confusion
/// `specs/11-testing-strategy.md` case 5 exists to prevent.
class ApiChildrenRepository implements ChildrenRepository {
  const ApiChildrenRepository(this._client);

  final ApiClient _client;

  @override
  Future<Paginated<Child>> fetchChildren({
    String? cursor,
    String? groupId,
  }) => _client.getList<Child>(
    '/children',
    childFromJson,
    query: {'group_id': groupId},
    cursor: cursor,
  );

  @override
  Future<ChildDetail> fetchChild(String childId) async {
    final json = await _client.getObject('/children/$childId');
    return childDetailFromJson(json);
  }
}
