import '../../../core/network/api_client.dart';
import '../domain/educator_group.dart';
import '../domain/educator_session.dart';
import '../domain/sessions_repository.dart';
import 'educator_dto.dart';

class ApiSessionsRepository implements SessionsRepository {
  const ApiSessionsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<SessionItem>> fetchSessions({
    required DateTime from,
    required DateTime to,
    String? groupId,
  }) async {
    final page = await _client.getList<SessionItem>(
      '/sessions',
      sessionItemFromJson,
      query: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        'group_id': groupId,
      },
    );
    return page.items;
  }

  @override
  Future<SessionDetail> fetchSession(String sessionId) async =>
      sessionDetailFromJson(await _client.getObject('/sessions/$sessionId'));

  @override
  Future<SessionDetail> updateContent(
    String sessionId,
    SessionContentDraft draft,
  ) async => sessionDetailFromJson(
    await _client.patch(
      '/sessions/$sessionId',
      body: {
        'title': draft.title.trim(),
        'theme': draft.theme,
        'objectives': draft.objectives,
        'materials': [
          for (final entry in draft.visibility.entries)
            {'id': entry.key, 'visibility': entry.value.wireValue},
        ],
      },
    ),
  );

  @override
  Future<SessionMaterial> addMaterial(
    String sessionId, {
    required MaterialKind kind,
    required String storageKey,
    String? title,
    MaterialVisibility visibility = MaterialVisibility.afterSession,
    int? sizeBytes,
  }) async => materialFromJson(
    await _client.post(
      '/sessions/$sessionId/materials',
      body: {
        'kind': kind.wireValue,
        'storage_key': storageKey,
        'title': title,
        'visibility': visibility.wireValue,
        'size_bytes': sizeBytes,
      },
    ),
  );

  @override
  Future<void> removeMaterial(String materialId) =>
      _client.delete('/materials/$materialId');

  @override
  Future<({int notifiedCount, int guardianCount})> changeSession(
    String sessionId,
    CancelDraft draft,
  ) async {
    final json = await _client.post(
      '/sessions/$sessionId/cancel',
      body: {
        'mode': draft.mode.name,
        'reason': draft.reason.trim(),
        'starts_at': draft.startsAt?.toUtc().toIso8601String(),
        'ends_at': draft.endsAt?.toUtc().toIso8601String(),
        'place': draft.place,
      },
    );
    return (
      notifiedCount: (json['notified_count'] as num?)?.toInt() ?? 0,
      guardianCount: (json['guardian_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<({DateTime sentAt, int familyCount})> sendSummary(
    String sessionId, {
    required String body,
    List<String> mediaKeys = const [],
  }) async {
    final json = await _client.post(
      '/sessions/$sessionId/summary',
      body: {'body': body.trim(), 'media_keys': mediaKeys},
    );
    return (
      sentAt:
          DateTime.tryParse(json['sent_at'] as String? ?? '') ?? DateTime.now(),
      familyCount: (json['family_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<PresenceOverview> fetchPresence(String sessionId) async =>
      presenceOverviewFromJson(
        await _client.getObject('/sessions/$sessionId/presence'),
      );

  @override
  Future<int> remindUnanswered(String sessionId) async {
    final json = await _client.post('/sessions/$sessionId/presence/remind');
    return (json['reminded_count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<HomeworkItem> createHomework(
    String sessionId,
    HomeworkDraft draft,
  ) async => homeworkFromJson(
    await _client.post(
      '/sessions/$sessionId/homework',
      body: {
        'title': draft.title.trim().isEmpty ? null : draft.title.trim(),
        'instructions': draft.instructions.trim(),
        'due_at': draft.dueAt!.toUtc().toIso8601String(),
        'target_child_ids': draft.targetChildIds?.toList(),
        'attachment_storage_key': draft.attachmentKey,
      },
    ),
  );

  @override
  Future<List<HomeworkItem>> fetchGroupHomework(String groupId) async {
    final page = await _client.getList<HomeworkItem>(
      '/groups/$groupId/homework',
      homeworkFromJson,
    );
    return page.items;
  }

  @override
  Future<List<RosterChild>> fetchRoster(String groupId) async {
    final page = await _client.getList<RosterChild>(
      '/groups/$groupId/roster',
      rosterChildFromJson,
    );
    return page.items;
  }
}
