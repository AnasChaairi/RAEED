import '../../../core/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/structure.dart';
import '../domain/structure_repository.dart';
import 'wire_helpers.dart';

Season seasonFromJson(Map<String, Object?> json) => Season(
  id: requireField<String>(json, 'id'),
  label: stringOrNull(json['label']) ?? '',
  startDate:
      DateTime.tryParse(stringOrNull(json['start_date']) ?? '') ??
      DateTime(1970),
  endDate:
      DateTime.tryParse(stringOrNull(json['end_date']) ?? '') ?? DateTime(1970),
  status: stringOrNull(json['status']) == 'archived'
      ? SeasonStatus.archived
      : SeasonStatus.active,
  groupCount: intOrNull(json['group_count']) ?? 0,
  childCount: intOrNull(json['child_count']) ?? 0,
);

const Map<String, CategoryGender> _genderByWire = {
  'boys': CategoryGender.boys,
  'girls': CategoryGender.girls,
  'mixed': CategoryGender.mixed,
};

Category categoryFromJson(Map<String, Object?> json) => Category(
  id: requireField<String>(json, 'id'),
  name: stringOrNull(json['name']) ?? stringOrNull(json['name_ar']) ?? '',
  minAge: intOrNull(json['min_age']),
  maxAge: intOrNull(json['max_age']),
  gender: json['gender'] is String ? _genderByWire[json['gender']] : null,
  childCount: intOrNull(json['child_count']) ?? 0,
  groupCount: intOrNull(json['group_count']) ?? 0,
);

Branch branchFromJson(Map<String, Object?> json) => Branch(
  id: requireField<String>(json, 'id'),
  name: stringOrNull(json['name']) ?? '',
  address: stringOrNull(json['address']),
  executiveNames: stringList(json['executive_names'])
      .where((n) => n.isNotEmpty)
      .toList(),
);

AuditEntry auditEntryFromJson(Map<String, Object?> json) {
  final actor = objectOrNull(json['actor']) ?? const {};
  return AuditEntry(
    id: requireField<String>(json, 'id'),
    at: requireDateTime(json, 'at'),
    actorId: stringOrNull(actor['id']),
    actorName: stringOrNull(actor['display_name']) ?? '',
    actorRole: stringOrNull(actor['role']),
    action: stringOrNull(json['action']) ?? '',
    resourceType: stringOrNull(json['resource_type']) ?? '',
    resourceId: stringOrNull(json['resource_id']),
    resourceLabel: stringOrNull(json['resource_label']),
    deviceMeta: objectOrNull(json['device_meta']) ?? const {},
  );
}

/// [StructureRepository] against the REST API.
class ApiStructureRepository implements StructureRepository {
  const ApiStructureRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Category>> fetchCategories() async =>
      (await _client.getList<Category>('/categories', categoryFromJson)).items;

  @override
  Future<List<Season>> fetchSeasons() async =>
      (await _client.getList<Season>('/seasons', seasonFromJson)).items;

  @override
  Future<void> archiveSeason(String seasonId) =>
      _client.post('/seasons/$seasonId/archive');

  @override
  Future<List<Branch>> fetchBranches() async =>
      (await _client.getList<Branch>('/branches', branchFromJson)).items;

  @override
  Future<Branch> createBranch({required String name, String? address}) async =>
      branchFromJson(
        await _client.post(
          '/branches',
          body: {'name': name, 'address': ?address},
        ),
      );

  @override
  Future<List<AuditEntry>> fetchAuditLog({String? action}) async =>
      (await _client.getList<AuditEntry>(
        '/audit-log',
        auditEntryFromJson,
        query: {'action': action, 'limit': 200},
      )).items;
}
