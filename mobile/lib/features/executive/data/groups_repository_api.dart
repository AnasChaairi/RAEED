import '../../../core/network/api_client.dart';
import '../domain/executive_group.dart';
import '../domain/groups_repository.dart';
import 'group_dto.dart';

/// [GroupsRepository] against the REST API.
///
/// Catches nothing: a `scope.forbidden` on a group outside the caller's
/// branch travels up as the `ApiException` it is, and renders as "not
/// available to you".
class ApiGroupsRepository implements GroupsRepository {
  const ApiGroupsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ExecutiveGroup>> fetchGroups() async {
    final page = await _client.getList<ExecutiveGroup>(
      '/groups',
      executiveGroupFromJson,
    );
    return page.items;
  }

  @override
  Future<ExecutiveGroup> fetchGroup(String groupId) async =>
      executiveGroupFromJson(await _client.getObject('/groups/$groupId'));

  @override
  Future<ExecutiveGroup> updateSchedule(
    String groupId,
    List<ScheduleSlot> slots,
  ) async => executiveGroupFromJson(
    await _client.patch(
      '/groups/$groupId',
      body: {
        'weekly_schedule': [for (final s in slots) scheduleSlotToJson(s)],
      },
    ),
  );

  @override
  Future<List<GroupSession>> fetchSessions(String groupId) async {
    final page = await _client.getList<GroupSession>(
      '/groups/$groupId/sessions',
      groupSessionFromJson,
    );
    return page.items;
  }
}
