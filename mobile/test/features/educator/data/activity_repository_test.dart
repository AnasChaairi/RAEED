import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/children/data/children_repository_api.dart';
import 'package:raeed/features/educator/data/sessions_repository_api.dart';
import 'package:raeed/features/educator/domain/educator_session.dart';

import '../../executive/data/stub_adapter.dart';

void main() {
  late StubAdapter adapter;

  setUp(() => adapter = StubAdapter());

  Map<String, Object?> session({String kind = 'sport'}) => {
    'id': 's9',
    'group': {'id': 'g1', 'name': 'الأشبال'},
    'kind': kind,
    'title': 'مباراة ودية',
    'starts_at': '2026-10-01T14:00:00Z',
    'ends_at': '2026-10-01T16:00:00Z',
    'place': 'الملعب',
    'status': 'planned',
    'is_customized': true,
    'has_content': true,
    'material_count': 0,
    'homework_count': 0,
    'attendance_recorded': false,
    'summary_sent': false,
    'enrolled_count': 12,
    'guardian_count': 20,
    'family_count': 10,
    'materials': <Object?>[],
    'homework': <Object?>[],
    'attendance': {'recorded': false},
  };

  test('an activity goes out with its group, kind and slot in UTC', () async {
    adapter.respond(201, session());
    final repository = ApiSessionsRepository(stubClient(adapter));

    final detail = await repository.createActivity(
      ActivityDraft(
        groupId: 'g1',
        day: DateTime(2026, 10, 2),
        startsAt: '14:00',
        endsAt: '16:00',
        title: ' مباراة ودية ',
        place: 'الملعب',
      ),
    );

    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.path, endsWith('/sessions'));
    final body = adapter.lastBody;
    expect(body['group_id'], 'g1');
    expect(body['kind'], 'sport');
    expect(body['title'], 'مباراة ودية');
    expect(body['place'], 'الملعب');
    expect(
      body['starts_at'],
      DateTime(2026, 10, 2, 14).toUtc().toIso8601String(),
    );
    expect(body.containsKey('objectives'), isFalse);
    expect(detail.item.kind, SessionKind.sport);
  });

  test(
    "a guardian's schedule reads the kind; unknown kinds stay sessions",
    () async {
      adapter.respond(200, {
        'data': [session(), session(kind: 'picnic')],
      });
      final repository = ApiChildrenRepository(stubClient(adapter));

      final list = await repository.fetchSessions(
        groupId: 'g1',
        from: DateTime(2026, 9, 29),
        to: DateTime(2026, 10, 29),
      );

      expect(adapter.lastRequest!.path, endsWith('/sessions'));
      expect(adapter.lastRequest!.queryParameters['group_id'], 'g1');
      expect(list.map((s) => s.kind), [SessionKind.sport, SessionKind.session]);
      expect(list.first.place, 'الملعب');
    },
  );
}
