import 'executive_group.dart';

/// Reads groups and their sessions, scoped server-side.
///
/// `GET /groups/{id}/sessions` is in `specs/04-api/openapi.yaml`; the list and
/// detail reads are proposed there by the executive screen specs and not yet
/// defined, so against today's backend they fail with a normal error state.
abstract interface class GroupsRepository {
  /// Every group the caller may see this season.
  Future<List<ExecutiveGroup>> fetchGroups();

  /// One group.
  ///
  /// Throws `ApiException` with `scope.forbidden` for a group outside the
  /// caller's branch — rendered as "not available to you", never "not found".
  Future<ExecutiveGroup> fetchGroup(String groupId);

  /// The group's sessions, most recent first as the server orders them.
  Future<List<GroupSession>> fetchSessions(String groupId);
}
