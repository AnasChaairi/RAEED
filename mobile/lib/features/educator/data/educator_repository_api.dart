import '../../../core/network/api_client.dart';
import '../domain/availability.dart';
import '../domain/educator_repository.dart';
import '../domain/educator_session.dart';
import 'educator_dto.dart';

class ApiEducatorRepository implements EducatorRepository {
  const ApiEducatorRepository(this._client);

  final ApiClient _client;

  @override
  Future<TodayView> fetchToday() async =>
      todayFromJson(await _client.getObject('/educator/today'));

  @override
  Future<void> confirmRead(String announcementId) async {
    await _client.post('/announcements/$announcementId/confirm-read');
  }

  @override
  Future<AvailabilityWindow?> fetchAvailability() async {
    final me = await _client.getObject('/auth/me');
    return availabilityOrNull(me['availability_hours']);
  }

  @override
  Future<AvailabilityWindow> setAvailability(AvailabilityWindow window) async {
    final json = await _client.patch(
      '/auth/me/availability',
      body: {'start': window.start, 'end': window.end},
    );
    return availabilityOrNull(json) ?? window;
  }
}
