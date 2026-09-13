import '../../../core/network/api_client.dart';
import '../domain/consent.dart';
import '../domain/consent_repository.dart';
import 'auth_dtos.dart';

/// The [ConsentRepository] against `GET`/`POST /consent`.
///
/// Both calls go through the authenticated client: consent is recorded
/// *against a signed-in guardian*, and the server resolves which children they
/// may consent for from `parent_child` rather than trusting the ids in the
/// body (`specs/04-api/conventions.md` — the ability check is resolved against
/// the resource, never taken from the request).
class ApiConsentRepository implements ConsentRepository {
  const ApiConsentRepository(this._client);

  final ApiClient _client;

  @override
  Future<ConsentRequirement> loadRequirement() async {
    final response = await _client.getObject('/consent');
    return consentRequirementFromJson(response);
  }

  @override
  Future<void> submit(ConsentSubmission submission) =>
      _client.post('/consent', body: consentSubmissionToJson(submission));
}
