import '../../../core/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/announcement.dart';
import '../domain/announcements_repository.dart';
import 'announcement_dto.dart';

/// [AnnouncementsRepository] against `GET /announcements`.
class ApiAnnouncementsRepository implements AnnouncementsRepository {
  const ApiAnnouncementsRepository(this._client);

  final ApiClient _client;

  @override
  Future<Paginated<Announcement>> fetchAnnouncements({String? cursor}) =>
      _client.getList<Announcement>(
        '/announcements',
        announcementFromJson,
        cursor: cursor,
      );
}
