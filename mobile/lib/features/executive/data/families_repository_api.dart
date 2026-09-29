import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../../children/domain/child.dart' show ChildGroupRef;
import '../domain/executive_group.dart';
import '../domain/families_repository.dart';
import '../domain/family.dart';
import 'group_dto.dart';
import 'wire_helpers.dart';

Family familyFromJson(Map<String, Object?> json) {
  final status = switch (stringOrNull(json['status'])) {
    'active' => FamilyStatus.active,
    'partial' => FamilyStatus.partial,
    _ => FamilyStatus.pending,
  };
  return Family(
    id: requireField<String>(json, 'id'),
    label: stringOrNull(json['label']) ?? '',
    status: status,
    guardians: [
      for (final g in objectList(json['guardians'], field: 'guardians'))
        FamilyGuardian(
          id: requireField<String>(g, 'id'),
          displayName: stringOrNull(g['display_name']) ?? '',
          relationship: stringOrNull(g['relationship']) ?? 'parent',
          phoneHint: stringOrNull(g['phone_hint']),
          account: stringOrNull(g['account']) == 'active'
              ? AccountStatus.active
              : AccountStatus.pending,
        ),
    ],
    children: [
      for (final c in objectList(json['children'], field: 'children'))
        FamilyChild(
          id: requireField<String>(c, 'id'),
          fullName: stringOrNull(c['full_name']) ?? '',
          dob: switch (stringOrNull(c['dob'])) {
            null => null,
            final raw => DateTime.tryParse(raw),
          },
          group: switch (objectOrNull(c['group'])) {
            null => null,
            final group => ChildGroupRef(
              id: stringOrNull(group['id']) ?? '',
              name: stringOrNull(group['name']) ?? '',
            ),
          },
        ),
    ],
  );
}

Educator educatorFromJson(Map<String, Object?> json) => Educator(
  id: requireField<String>(json, 'id'),
  displayName: stringOrNull(json['display_name']) ?? '',
  groupCount: intOrNull(json['group_count']) ?? 0,
);

final _wireDate = DateFormat('yyyy-MM-dd');

/// One guardian, as `POST /families` and `POST /families/{id}/guardians` want it.
Map<String, Object?> guardianDraftToJson(GuardianDraft g) => {
  'display_name': g.displayName.trim(),
  'phone': g.e164,
  'relationship': g.relationship,
};

/// One child, as `POST /families` and `POST /families/{id}/children` want it.
Map<String, Object?> childDraftToJson(ChildDraft c) => {
  'full_name': c.fullName.trim(),
  'dob': _wireDate.format(c.dateOfBirth!),
  if (c.groupId != null) 'group_id': c.groupId,
};

/// The `POST /families` body.
Map<String, Object?> familyDraftToJson(FamilyDraft draft) => {
  'guardians': [for (final g in draft.guardians) guardianDraftToJson(g)],
  'children': [for (final c in draft.children) childDraftToJson(c)],
};

/// The `PATCH /families/{id}/guardians/{gid}` body — set fields only.
Map<String, Object?> guardianPatchToJson(GuardianPatch patch) => {
  if (patch.displayName != null) 'display_name': patch.displayName!.trim(),
  if (patch.e164 != null) 'phone': patch.e164,
  if (patch.relationship != null) 'relationship': patch.relationship,
};

/// The `PATCH /families/{id}/children/{cid}` body — set fields only.
Map<String, Object?> childPatchToJson(ChildPatch patch) => {
  if (patch.fullName != null) 'full_name': patch.fullName!.trim(),
  if (patch.dateOfBirth != null) 'dob': _wireDate.format(patch.dateOfBirth!),
};

GuardianCredential _credentialFromJson(Map<String, Object?> raw) =>
    GuardianCredential(
      id: stringOrNull(raw['id']) ?? '',
      displayName: stringOrNull(raw['display_name']) ?? '',
      password: stringOrNull(raw['password']),
    );

/// The `POST /groups` body.
Map<String, Object?> groupDraftToJson(GroupDraft draft) => {
  'name': draft.name.trim(),
  'category_id': draft.categoryId,
  'capacity': draft.capacity,
  'educator_ids': draft.educatorIds.toList()..sort(),
  if (draft.childIds.isNotEmpty) 'child_ids': draft.childIds.toList()..sort(),
};

/// [FamiliesRepository] against the REST API.
class ApiFamiliesRepository implements FamiliesRepository {
  const ApiFamiliesRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Family>> fetchFamilies() async =>
      (await _client.getList<Family>('/families', familyFromJson)).items;

  @override
  Future<FamilyCreated> createFamily(FamilyDraft draft) async {
    final json = await _client.post(
      '/families',
      body: familyDraftToJson(draft),
    );
    return FamilyCreated(
      guardianIds: stringList(json['guardian_ids']),
      childIds: stringList(json['child_ids']),
      invitations: intOrNull(json['invitations']) ?? 0,
      guardians: [
        for (final raw in json['guardians'] as List? ?? const [])
          if (raw is Map<String, Object?>) _credentialFromJson(raw),
      ],
    );
  }

  @override
  Future<Family> fetchFamily(String familyId) async =>
      familyFromJson(await _client.getObject('/families/$familyId'));

  @override
  Future<Family> updateGuardian({
    required String familyId,
    required String guardianId,
    required GuardianPatch patch,
  }) async => familyFromJson(
    await _client.patch(
      '/families/$familyId/guardians/$guardianId',
      body: guardianPatchToJson(patch),
    ),
  );

  @override
  Future<GuardianAdded> addGuardian({
    required String familyId,
    required GuardianDraft guardian,
  }) async {
    final json = await _client.post(
      '/families/$familyId/guardians',
      body: guardianDraftToJson(guardian),
    );
    return GuardianAdded(
      family: familyFromJson(
        requireField<Map<String, Object?>>(json, 'family'),
      ),
      credential: _credentialFromJson(
        requireField<Map<String, Object?>>(json, 'credential'),
      ),
    );
  }

  @override
  Future<Family> unlinkGuardian({
    required String familyId,
    required String guardianId,
  }) async => familyFromJson(
    await _client.deleteObject('/families/$familyId/guardians/$guardianId'),
  );

  @override
  Future<ChildAdded> addChild({
    required String familyId,
    required ChildDraft child,
  }) async {
    final json = await _client.post(
      '/families/$familyId/children',
      body: childDraftToJson(child),
    );
    return ChildAdded(
      family: familyFromJson(
        requireField<Map<String, Object?>>(json, 'family'),
      ),
      childId: requireField<String>(json, 'child_id'),
    );
  }

  @override
  Future<Family> updateChild({
    required String familyId,
    required String childId,
    required ChildPatch patch,
  }) async => familyFromJson(
    await _client.patch(
      '/families/$familyId/children/$childId',
      body: childPatchToJson(patch),
    ),
  );

  @override
  Future<String> resendInvitation(String guardianId) async {
    final json = await _client.post(
      '/invitations',
      body: {'user_id': guardianId},
    );
    return json['password'] as String? ?? '';
  }

  @override
  Future<List<Educator>> fetchEducators() async =>
      (await _client.getList<Educator>('/educators', educatorFromJson)).items;

  @override
  Future<ExecutiveGroup> createGroup(GroupDraft draft) async =>
      executiveGroupFromJson(
        await _client.post('/groups', body: groupDraftToJson(draft)),
      );

  @override
  Future<({int enrolledCount, int? capacity})> assignChildren({
    required String groupId,
    required List<String> childIds,
  }) async {
    final json = await _client.post(
      '/groups/$groupId/children',
      body: {'child_ids': childIds},
    );
    return (
      enrolledCount: intOrNull(json['enrolled_count']) ?? 0,
      capacity: intOrNull(json['capacity']),
    );
  }
}
