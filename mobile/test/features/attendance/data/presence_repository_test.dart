import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/config/app_environment.dart';
import 'package:raeed/core/database/raeed_database.dart';
import 'package:raeed/core/network/api_client.dart';
import 'package:raeed/features/attendance/data/presence_repository_impl.dart';
import 'package:raeed/features/attendance/domain/presence_answer.dart';

import '../../../support/sqlite_test_setup.dart';

/// `RAEED-16`: presence answers queue offline and sync on reconnect, and an
/// unanswered confirmation surfaces on the Home card so it survives a missed
/// push.
void main() {
  late RaeedDatabase db;
  late _StubAdapter adapter;
  late OfflineFirstPresenceRepository repository;

  setUpAll(configureSqliteForTests);

  setUp(() {
    db = RaeedDatabase.forTesting(NativeDatabase.memory());
    adapter = _StubAdapter();
    repository = OfflineFirstPresenceRepository(
      database: db,
      client: ApiClient(
        environment: const AppEnvironment(
          flavor: AppFlavor.dev,
          apiBaseUrl: 'http://localhost:3000/api/v1',
          sentryDsn: '',
          connectTimeout: Duration(seconds: 1),
          receiveTimeout: Duration(seconds: 1),
        ),
        dio: Dio()..httpClientAdapter = adapter,
      ),
    );
  });

  tearDown(() async {
    await repository.dispose();
    await db.close();
  });

  /// Two siblings in one group, so both owe an answer against the **same**
  /// confirmation — a confirmation belongs to a session, not to a child.
  Map<String, Object?> siblingsPayload() => {
    'data': [
      {
        'id': 'confirmation-1',
        'session_id': 'session-1',
        'child_id': 'child-adam',
        'child_name': 'آدم',
        'session_starts_at': '2026-09-13T16:00:00Z',
        'group_name': 'الأشبال أ',
      },
      {
        'id': 'confirmation-1',
        'session_id': 'session-1',
        'child_id': 'child-omar',
        'child_name': 'عمر',
        'session_starts_at': '2026-09-13T16:00:00Z',
        'group_name': 'الأشبال أ',
      },
    ],
  };

  group('siblings sharing one confirmation', () {
    test('both prompts survive the refresh', () async {
      // A regression test for a real bug: keying the prompt map by
      // confirmation id alone collapsed two siblings into one, and the second
      // child's prompt vanished. The live seed reproduces it — two children in
      // الأشبال أ, one confirmation.
      adapter.respond(200, siblingsPayload());

      final pending = await repository.refreshUnanswered();

      expect(pending, hasLength(2));
      expect(
        pending.map((confirmation) => confirmation.childId),
        containsAll(['child-adam', 'child-omar']),
      );
    });

    test(
      'answering for one child leaves the sibling still owing one',
      () async {
        adapter.respond(200, siblingsPayload());
        await repository.refreshUnanswered();

        adapter.throwDio(DioExceptionType.connectionError);
        await repository.answer(
          const PresenceAnswerDraft(
            confirmationId: 'confirmation-1',
            childId: 'child-adam',
            answer: PresenceAnswerValue.no,
            reason: AbsenceReason.illness,
          ),
        );

        final remaining = await repository.watchUnanswered().first;
        expect(remaining, hasLength(1));
        expect(remaining.single.childId, 'child-omar');
      },
    );

    test('a queued answer does not clear the sibling on the next refresh', () async {
      adapter.throwDio(DioExceptionType.connectionError);
      await repository.answer(
        const PresenceAnswerDraft(
          confirmationId: 'confirmation-1',
          childId: 'child-adam',
          answer: PresenceAnswerValue.yes,
        ),
      );

      adapter.respond(200, siblingsPayload());
      final pending = await repository.refreshUnanswered();

      // The answered child is suppressed because the server has not heard yet;
      // the sibling is untouched.
      expect(pending, hasLength(1));
      expect(pending.single.childId, 'child-omar');
    });
  });

  group('offline queue', () {
    test('an answer is durable before it is transmitted', () async {
      adapter.throwDio(DioExceptionType.connectionError);

      await repository.answer(
        const PresenceAnswerDraft(
          confirmationId: 'confirmation-1',
          childId: 'child-adam',
          answer: PresenceAnswerValue.no,
          reason: AbsenceReason.travel,
        ),
      );

      final queued = await db.readPendingWrites(
        kind: PendingWriteKind.presenceAnswer,
      );
      expect(queued, hasLength(1));
      final payload = jsonDecode(queued.single.payload) as Map<String, dynamic>;
      expect(payload['answer'], 'no');
      expect(payload['reason'], 'travel');
    });

    test('drains on reconnect', () async {
      adapter.throwDio(DioExceptionType.connectionError);
      await repository.answer(
        const PresenceAnswerDraft(
          confirmationId: 'confirmation-1',
          childId: 'child-adam',
          answer: PresenceAnswerValue.yes,
        ),
      );

      adapter.respond(200, {'recorded': true});
      final outcome = await repository.sync();

      expect(outcome.acceptedCount, 1);
      expect(
        await db.readPendingWrites(kind: PendingWriteKind.presenceAnswer),
        isEmpty,
      );
    });

    test(
      'a later answer for the same child supersedes the queued one',
      () async {
        // A parent changing their mind before the session is giving a better
        // answer, not queueing a second one.
        adapter.throwDio(DioExceptionType.connectionError);

        await repository.answer(
          const PresenceAnswerDraft(
            confirmationId: 'confirmation-1',
            childId: 'child-adam',
            answer: PresenceAnswerValue.no,
          ),
        );
        await repository.answer(
          const PresenceAnswerDraft(
            confirmationId: 'confirmation-1',
            childId: 'child-adam',
            answer: PresenceAnswerValue.yes,
          ),
        );

        final queued = await db.readPendingWrites(
          kind: PendingWriteKind.presenceAnswer,
        );
        expect(queued, hasLength(1));
        expect(
          (jsonDecode(queued.single.payload) as Map<String, dynamic>)['answer'],
          'yes',
        );
      },
    );
  });
}

class _StubAdapter implements HttpClientAdapter {
  int _status = 200;
  Object? _body;
  DioExceptionType? _throwType;

  void respond(int status, Object? body) {
    _status = status;
    _body = body;
    _throwType = null;
  }

  void throwDio(DioExceptionType type) => _throwType = type;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final throwType = _throwType;
    if (throwType != null) {
      throw DioException(requestOptions: options, type: throwType);
    }
    return ResponseBody.fromString(
      _body == null ? '' : jsonEncode(_body),
      _status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
