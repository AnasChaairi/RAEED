import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/data/executive_announcement_dto.dart';
import 'package:raeed/features/executive/data/executive_announcements_repository_api.dart';
import 'package:raeed/features/executive/domain/announcement_draft.dart';

import 'stub_adapter.dart';

void main() {
  late StubAdapter adapter;
  late ApiExecutiveAnnouncementsRepository repository;

  setUp(() {
    adapter = StubAdapter();
    repository = ApiExecutiveAnnouncementsRepository(stubClient(adapter));
  });

  test(
    'decodes the executive read model including audience and read rate',
    () async {
      adapter.respond(200, {
        'data': [
          {
            'id': 'ann-1',
            'title': 'يوم مفتوح',
            'priority': 'urgent',
            'pinned': true,
            'publish_at': '2026-09-19T08:00:00Z',
            'expire_at': '2026-09-28T00:00:00Z',
            'audience': {
              'type': 'categories',
              'category_ids': ['ashbal', 'zahrat'],
            },
            'read_count': 31,
            'audience_count': 50,
          },
        ],
      });

      final page = await repository.fetchAnnouncements();
      final announcement = page.items.single;

      expect(announcement.isUrgent, isTrue);
      expect(announcement.audience.mode, AudienceMode.categories);
      expect(announcement.audience.categoryIds, {'ashbal', 'zahrat'});
      expect(announcement.readRate, closeTo(0.62, 0.001));
      expect(announcement.expireAt, DateTime.utc(2026, 9, 28));
    },
  );

  test(
    'a missing audience defaults to all rather than failing the list',
    () async {
      adapter.respond(200, {
        'data': [
          {'id': 'ann-1', 'title': 't', 'publish_at': '2026-09-19T08:00:00Z'},
        ],
      });

      final page = await repository.fetchAnnouncements();

      expect(page.items.single.audience, const AnnouncementAudience.all());
      expect(page.items.single.readRate, isNull);
    },
  );

  test('publish sends the audience_json shape and the priority', () async {
    adapter.respond(201, {'id': 'ann-9'});

    final id = await repository.publish(
      const AnnouncementDraft(
        title: '  تغيير قاعة  ',
        body: 'النص',
        audience: AnnouncementAudience(
          mode: AudienceMode.categories,
          categoryIds: {'zahrat', 'ashbal'},
        ),
        priority: AnnouncementPriority.urgent,
      ),
    );

    expect(id, 'ann-9');
    expect(adapter.lastRequest!.path, endsWith('/announcements'));
    expect(adapter.lastBody, {
      'title': 'تغيير قاعة',
      'body': 'النص',
      'audience': {
        'type': 'categories',
        'category_ids': ['ashbal', 'zahrat'],
      },
      'priority': 'urgent',
    });
  });

  test('the audience roundtrips through the wire', () {
    for (final audience in const [
      AnnouncementAudience.all(),
      AnnouncementAudience.parents(),
      AnnouncementAudience.educators(),
      AnnouncementAudience(mode: AudienceMode.categories, categoryIds: {'a'}),
    ]) {
      expect(audienceFromJson(audienceToJson(audience)), audience);
    }
  });

  test('reach decodes the server counts', () async {
    adapter.respond(200, {
      'all': 264,
      'parents': 246,
      'educators': 18,
      'categories': [
        {'id': 'ashbal', 'name': 'الأشبال', 'guardian_count': 58},
      ],
    });

    final reach = await repository.fetchReach();

    expect(reach.allCount, 264);
    expect(reach.categories.single.guardianCount, 58);
    expect(adapter.lastRequest!.path, endsWith('/announcements/reach'));
  });
}
