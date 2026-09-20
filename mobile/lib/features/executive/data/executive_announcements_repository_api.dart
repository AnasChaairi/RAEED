import '../../../core/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/announcement_draft.dart';
import '../domain/executive_announcements_repository.dart';
import 'executive_announcement_dto.dart';

/// [ExecutiveAnnouncementsRepository] against the REST API.
class ApiExecutiveAnnouncementsRepository
    implements ExecutiveAnnouncementsRepository {
  const ApiExecutiveAnnouncementsRepository(this._client);

  final ApiClient _client;

  @override
  Future<Paginated<ExecutiveAnnouncement>> fetchAnnouncements({
    String? cursor,
  }) => _client.getList<ExecutiveAnnouncement>(
    '/announcements',
    executiveAnnouncementFromJson,
    cursor: cursor,
  );

  @override
  Future<AudienceReach> fetchReach() async =>
      audienceReachFromJson(await _client.getObject('/announcements/reach'));

  @override
  Future<String> publish(AnnouncementDraft draft) async {
    final response = await _client.post(
      '/announcements',
      body: announcementDraftToJson(draft),
    );
    return response['id'] as String? ?? '';
  }
}
