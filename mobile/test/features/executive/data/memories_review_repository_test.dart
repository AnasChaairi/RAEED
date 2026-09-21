import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/data/memories_review_repository_api.dart';
import 'package:raeed/features/executive/domain/memories_review.dart';

import 'stub_adapter.dart';

void main() {
  late StubAdapter adapter;
  late ApiMemoriesReviewRepository repository;

  setUp(() {
    adapter = StubAdapter();
    repository = ApiMemoriesReviewRepository(stubClient(adapter));
  });

  test('the queue carries the mode as reported, or null when unset', () async {
    adapter.respond(200, {
      'moderation_mode': 'approve_before_publish',
      'data': [
        {
          'id': 'p1',
          'album': {'title': 'رحلة الغابة', 'group_name': 'الفراشات 1'},
          'author_name': 'خديجة',
          'posted_at': '2026-09-12T10:00:00Z',
          'media_count': 10,
          'is_blocked': true,
          'tags': [
            {
              'child_id': 'c1',
              'full_name': 'نور',
              'image_rights_level': 'not_allowed',
            },
            {
              'child_id': 'c2',
              'full_name': 'هشام',
              'image_rights_level': 'allowed',
            },
          ],
        },
      ],
    });

    final queue = await repository.fetchQueue();

    expect(queue.moderationMode, ModerationMode.approveBeforePublish);
    expect(queue.head!.isBlocked, isTrue);
    expect(queue.head!.notAllowedTags.single.name, 'نور');

    adapter.respond(200, {'data': <Object?>[]});
    expect((await repository.fetchQueue()).moderationMode, isNull);
  });

  test('an unknown image-rights level reads as not allowed', () async {
    adapter.respond(200, {
      'data': [
        {
          'id': 'p1',
          'album_title': 'a',
          'author_name': 'b',
          'tags': [
            {
              'child_id': 'c1',
              'full_name': 'x',
              'image_rights_level': 'whatever',
            },
          ],
        },
      ],
    });

    final queue = await repository.fetchQueue();

    expect(queue.head!.tags.single.imageRights, ImageRightsLevel.notAllowed);
  });

  test('approve and hide post to the post, never delete', () async {
    adapter.respond(204, null);

    await repository.approve('p1');
    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.path, endsWith('/memories/posts/p1/approve'));

    await repository.hide('p1');
    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.path, endsWith('/memories/posts/p1/hide'));
  });
}
