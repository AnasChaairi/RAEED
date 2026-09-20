import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/features/executive/data/messages_repository_api.dart';
import 'package:raeed/features/executive/domain/conversation.dart';

import 'stub_adapter.dart';

void main() {
  late StubAdapter adapter;
  late ApiMessagesRepository repository;

  setUp(() {
    adapter = StubAdapter();
    repository = ApiMessagesRepository(stubClient(adapter));
  });

  test(
    'membership defaults to false so oversight is disclosed, not hidden',
    () async {
      adapter.respond(200, {
        'data': [
          {'id': 'c1', 'type': 'child', 'title': 'يوسف الإدريسي'},
        ],
      });

      final threads = await repository.fetchConversations();

      expect(threads.single.isMember, isFalse);
      expect(threads.single.kind, ConversationKind.child);
    },
  );

  test('messages decode sender role, hidden state and open reports', () async {
    adapter.respond(200, {
      'data': [
        {
          'id': 'm1',
          'sender': {'id': 'u1', 'display_name': 'حمزة', 'role': 'educator'},
          'kind': 'text',
          'body': 'هل يمكن مشاركة رقم هاتف الأم؟',
          'created_at': '2026-09-18T18:40:00Z',
          'report': {
            'id': 'rep-1',
            'reporter_name': 'سعاد',
            'reason': 'طلب معلومات شخصية',
          },
        },
        {
          'id': 'm2',
          'sender_id': 'u2',
          'sender_name': 'سعاد',
          'kind': 'voice',
          'duration_seconds': 23,
          'sent_at': '2026-09-18T19:02:00Z',
          'hidden': {'by_name': 'أنس', 'at': '2026-09-20T11:32:00Z'},
        },
      ],
    });

    final messages = await repository.fetchMessages('c1');

    expect(messages[0].senderRole, RaeedRole.educator);
    expect(messages[0].isReported, isTrue);
    expect(messages[0].report!.id, 'rep-1');
    expect(messages[1].kind, MessageKind.voice);
    expect(messages[1].isHidden, isTrue);
    expect(messages[1].hidden!.hiddenByName, 'أنس');
  });

  test('hide and dismiss hit their own paths', () async {
    adapter.respond(204, null);

    await repository.hideMessage('m1');
    expect(adapter.lastRequest!.path, endsWith('/messages/m1/hide'));

    await repository.dismissReport('rep-1');
    expect(
      adapter.lastRequest!.path,
      endsWith('/message-reports/rep-1/dismiss'),
    );
  });
}
