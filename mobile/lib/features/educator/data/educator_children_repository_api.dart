import '../../../core/network/api_client.dart';
import '../domain/educator_child.dart';
import '../domain/educator_children_repository.dart';
import 'educator_dto.dart';

class ApiEducatorChildrenRepository implements EducatorChildrenRepository {
  const ApiEducatorChildrenRepository(this._client);

  final ApiClient _client;

  @override
  Future<EducatorChildProfile> fetchProfile(String childId) async =>
      educatorChildFromJson(await _client.getObject('/children/$childId'));

  @override
  Future<EmergencyCall> emergencyCall(String childId) async =>
      emergencyCallFromJson(
        await _client.post('/children/$childId/emergency-call'),
      );
}
