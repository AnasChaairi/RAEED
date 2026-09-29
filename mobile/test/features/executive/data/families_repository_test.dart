import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/error/api_error_code.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/features/executive/data/families_repository_api.dart';
import 'package:raeed/features/executive/domain/family.dart';

import 'stub_adapter.dart';

void main() {
  late StubAdapter adapter;
  late ApiFamiliesRepository repository;

  setUp(() {
    adapter = StubAdapter();
    repository = ApiFamiliesRepository(stubClient(adapter));
  });

  Map<String, Object?> family({String id = 'p1,p2'}) => {
    'id': id,
    'label': 'الإدريسي',
    'status': 'partial',
    'guardians': [
      {
        'id': 'p1',
        'display_name': 'سعاد',
        'relationship': 'mother',
        'phone_hint': '•• 34',
        'account': 'active',
      },
      {'id': 'p2', 'display_name': 'كريم', 'account': 'pending'},
    ],
    'children': [
      {
        'id': 'c1',
        'full_name': 'يوسف الإدريسي',
        'dob': '2018-05-02',
        'group': {'id': 'g1', 'name': 'الأشبال أ'},
      },
    ],
  };

  test('one household decodes the fields the family page edits', () async {
    adapter.respond(200, family());

    final result = await repository.fetchFamily('p1,p2');

    expect(adapter.lastRequest!.path, endsWith('/families/p1,p2'));
    expect(result.guardians.first.relationship, 'mother');
    expect(result.guardians.first.phoneHint, '•• 34');
    // Missing on the wire: the defaults, not a crash.
    expect(result.guardians.last.relationship, 'parent');
    expect(result.guardians.last.phoneHint, isNull);
    expect(result.children.single.dob, DateTime(2018, 5, 2));
  });

  test('a guardian patch sends only the fields that changed', () async {
    adapter.respond(200, family());

    await repository.updateGuardian(
      familyId: 'p1,p2',
      guardianId: 'p1',
      patch: const GuardianPatch(phone: '611223344'),
    );

    expect(adapter.lastRequest!.method, 'PATCH');
    expect(adapter.lastRequest!.path, endsWith('/families/p1,p2/guardians/p1'));
    expect(adapter.lastBody, {'phone': '+212611223344'});
  });

  test(
    'linking a guardian returns the household it now is and the credential',
    () async {
      adapter.respond(201, {
        'family': family(id: 'p1,p2,p3'),
        'credential': {
          'id': 'p3',
          'display_name': 'الجدة',
          'password': 'v7bh9w',
        },
      });

      final added = await repository.addGuardian(
        familyId: 'p1,p2',
        guardian: const GuardianDraft(
          displayName: ' الجدة ',
          phone: '655000000',
          relationship: 'grandmother',
        ),
      );

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastBody, {
        'display_name': 'الجدة',
        'phone': '+212655000000',
        'relationship': 'grandmother',
      });
      expect(added.family.id, 'p1,p2,p3');
      expect(added.credential.password, 'v7bh9w');
    },
  );

  test('unlinking reads the household off the DELETE body', () async {
    adapter.respond(200, family(id: 'p1'));

    final result = await repository.unlinkGuardian(
      familyId: 'p1,p2',
      guardianId: 'p2',
    );

    expect(adapter.lastRequest!.method, 'DELETE');
    expect(adapter.lastRequest!.path, endsWith('/families/p1,p2/guardians/p2'));
    expect(result.id, 'p1');
  });

  test('the last-guardian refusal surfaces as its code', () async {
    adapter.respond(409, {
      'error': {
        'code': 'children.last_guardian',
        'message': 'A child would be left without a guardian.',
        'details': {
          'child_ids': ['c1'],
        },
      },
    });

    await expectLater(
      repository.unlinkGuardian(familyId: 'p1', guardianId: 'p1'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.childrenLastGuardian,
        ),
      ),
    );
  });

  test('adding and correcting a child send wire dates', () async {
    adapter.respond(201, {'family': family(), 'child_id': 'c9'});

    final added = await repository.addChild(
      familyId: 'p1,p2',
      child: ChildDraft(
        fullName: 'آدم',
        dateOfBirth: DateTime(2020, 2, 2),
        groupId: 'g1',
      ),
    );
    expect(added.childId, 'c9');
    expect(adapter.lastBody, {
      'full_name': 'آدم',
      'dob': '2020-02-02',
      'group_id': 'g1',
    });

    adapter.respond(200, family());
    await repository.updateChild(
      familyId: 'p1,p2',
      childId: 'c1',
      patch: ChildPatch(dateOfBirth: DateTime(2018, 6, 15)),
    );
    expect(adapter.lastRequest!.method, 'PATCH');
    expect(adapter.lastBody, {'dob': '2018-06-15'});
  });
}
