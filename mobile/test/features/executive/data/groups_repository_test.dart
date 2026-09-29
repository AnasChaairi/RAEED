import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/data/groups_repository_api.dart';
import 'package:raeed/features/executive/domain/executive_group.dart';

import 'stub_adapter.dart';

void main() {
  late StubAdapter adapter;
  late ApiGroupsRepository repository;

  setUp(() {
    adapter = StubAdapter();
    repository = ApiGroupsRepository(stubClient(adapter));
  });

  test('a group decodes its schedule slots, dropping malformed ones', () async {
    adapter.respond(200, {
      'id': 'g1',
      'name': 'الأشبال',
      'category': {'id': 'c', 'name': 'الأشبال'},
      'enrolled_count': 3,
      'schedule_label': 'السبت 10:00',
      'weekly_schedule': [
        {'weekday': 6, 'starts_at': '10:00', 'ends_at': '12:00'},
        {'weekday': 'x'},
      ],
    });

    final group = await repository.fetchGroup('g1');

    expect(group.weeklySchedule, [
      const ScheduleSlot(weekday: 6, startsAt: '10:00', endsAt: '12:00'),
    ]);
  });

  test('replacing the schedule sends every slot on the wire', () async {
    adapter.respond(200, {
      'id': 'g1',
      'name': 'الأشبال',
      'enrolled_count': 3,
      'weekly_schedule': <Object?>[],
    });

    await repository.updateSchedule('g1', const [
      ScheduleSlot(weekday: 2, startsAt: '16:00', endsAt: '18:00'),
    ]);

    expect(adapter.lastRequest!.method, 'PATCH');
    expect(adapter.lastRequest!.path, endsWith('/groups/g1'));
    expect(adapter.lastBody, {
      'weekly_schedule': [
        {'weekday': 2, 'starts_at': '16:00', 'ends_at': '18:00'},
      ],
    });
  });
}
