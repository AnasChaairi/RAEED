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

/// The `POST /families` body.
Map<String, Object?> familyDraftToJson(FamilyDraft draft) => {
  'guardians': [
    for (final g in draft.guardians)
      {
        'display_name': g.displayName.trim(),
        'phone': g.e164,
        'relationship': g.relationship,
      },
  ],
  'children': [
    for (final c in draft.children)
      {
        'full_name': c.fullName.trim(),
        'dob': DateFormat('yyyy-MM-dd').format(c.dateOfBirth!),
        if (c.groupId != null) 'group_id': c.groupId,
      },
  ],
};

/// The `POST /groups` body.
Map<String, Object?> groupDraftToJson(GroupDraft draft) => {
  'name': draft.name.trim(),
  'category_id': draft.categoryId,
  'capacity': draft.capacity,
  'weekly_schedule': [
    {
      'weekday': draft.slot.weekday,
      'starts_at': draft.slot.startsAt,
      'ends_at': draft.slot.endsAt,
    },
  ],
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
    );
  }

  @override
  Future<void> resendInvitation(String guardianId) =>
      _client.post('/invitations', body: {'user_id': guardianId});

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
