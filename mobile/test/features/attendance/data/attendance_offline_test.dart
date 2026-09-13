import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/config/app_environment.dart';
import 'package:raeed/core/database/raeed_database.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/core/network/api_client.dart';
import 'package:raeed/features/attendance/data/attendance_repository_impl.dart';
import 'package:raeed/features/attendance/domain/attendance_repository.dart';
import 'package:raeed/features/attendance/domain/attendance_status.dart';

import '../../../support/sqlite_test_setup.dart';

/// The two non-negotiable cases from `specs/11-testing-strategy.md`, written
/// first, plus the queue behaviour they depend on.
///
/// This is the one safety-critical path in the product: a mark that is silently
/// lost is a child whose absence is never reported.
void main() {
  late RaeedDatabase db;
  late _StubAdapter adapter;
  late OfflineFirstAttendanceRepository repository;

  const sessionId = 'session-1';
  const groupId = 'group-1';

  setUpAll(configureSqliteForTests);

  setUp(() async {
    db = RaeedDatabase.forTesting(NativeDatabase.memory());
    adapter = _StubAdapter();
    repository = OfflineFirstAttendanceRepository(
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

    // A cached sheet with two children, so composition has something to
    // overlay the queue onto.
    await db.cacheSheetRows(
      sessionId: sessionId,
      groupId: groupId,
      groupName: 'الأشبال',
      startsAt: DateTime.utc(2026, 9, 13, 9),
      rows: [
        CachedAttendanceEntriesCompanion.insert(
          sessionId: sessionId,
          childId: 'child-1',
          childName: 'آدم',
          position: const Value(0),
          cachedAt: DateTime.utc(2026, 9, 13, 9),
        ),
        CachedAttendanceEntriesCompanion.insert(
          sessionId: sessionId,
          childId: 'child-2',
          childName: 'مريم',
          position: const Value(1),
          cachedAt: DateTime.utc(2026, 9, 13, 9),
        ),
      ],
    );
  });

  tearDown(() => db.close());

  Future<List<PendingWrite>> queue() =>
      db.readPendingWrites(kind: PendingWriteKind.attendanceMark);

  /// Waits out the background drain `mark()` fires deliberately.
  ///
  /// `mark()` queues and then attempts a send without awaiting it, because the
  /// tap must not block on the network. Tests that assert on queue state have
  /// to let that attempt finish first, or they race it — `sync()` joins an
  /// in-flight drain rather than starting a second one, so one call is enough.
  Future<SyncOutcome> settle() => repository.sync(sessionId: sessionId);

  group('non-negotiable case 1 — attendance conflict', () {
    test('a stale mark is surfaced as a conflict, never silently '
        'overwritten', () async {
      // Two devices marked the same child on the same session while offline.
      // This device's mark is the older one, so the server refuses it.
      final tapAt = DateTime.utc(2026, 9, 13, 9, 5);
      adapter.respond(409, {
        'error': {
          'code': 'attendance.conflict',
          'message': 'Already recorded.',
          'details': {
            'child_id': 'child-1',
            'status': 'present',
            'recorded_at': '2026-09-13T09:07:00Z',
            'recorded_by_name': 'Fatima Z.',
          },
        },
      });

      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: tapAt,
      );
      final outcome = await repository.sync(sessionId: sessionId);

      expect(outcome.conflicts, hasLength(1));
      expect(outcome.needsAttention, isTrue);

      final conflict = outcome.conflicts.single;
      expect(conflict.childId, 'child-1');
      expect(
        conflict.attemptedStatus,
        AttendanceStatus.absent,
        reason: 'the educator must be shown what *they* marked',
      );
      expect(conflict.attemptedRecordedAtClient, tapAt);
      expect(
        conflict.serverStatus,
        AttendanceStatus.present,
        reason: 'and what the server holds instead',
      );

      // The losing write is kept, not dropped — the educator decides.
      final rows = await queue();
      expect(rows, hasLength(1));
      expect(rows.single.state, PendingWriteState.conflicted);
      expect(outcome.acceptedCount, 0);
    });

    test('a conflicted write is never auto-retried by a later drain', () async {
      adapter.respond(409, {
        'error': {
          'code': 'attendance.conflict',
          'message': 'Already recorded.',
          'details': {'child_id': 'child-1'},
        },
      });
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await repository.sync(sessionId: sessionId);

      // The network recovers. A conflicted row must stay put: auto-retrying it
      // would silently overwrite the other device's mark, which is exactly what
      // the conflict rule exists to prevent.
      adapter.respond(200, {'data': <Object?>[]});
      final second = await repository.sync(sessionId: sessionId);

      expect(second.acceptedCount, 0);
      expect((await queue()).single.state, PendingWriteState.conflicted);
    });

    test(
      'the sheet shows the conflict rather than either side\'s value',
      () async {
        adapter.respond(409, {
          'error': {
            'code': 'attendance.conflict',
            'message': 'Already recorded.',
            'details': {
              'child_id': 'child-1',
              'status': 'present',
              'recorded_at': '2026-09-13T09:07:00Z',
            },
          },
        });
        await repository.mark(
          sessionId: sessionId,
          childId: 'child-1',
          status: AttendanceStatus.absent,
          recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
        );
        await repository.sync(sessionId: sessionId);

        adapter.throwDio(DioExceptionType.connectionError);
        final sheet = await repository.loadSheet(
          sessionId: sessionId,
          groupId: groupId,
        );
        final entry = sheet.entries.firstWhere((e) => e.childId == 'child-1');

        expect(entry.hasConflict, isTrue);
        expect(
          entry.isPending,
          isFalse,
          reason:
              'a conflicted mark is not "on its way", it is waiting on a '
              'person',
        );
      },
    );

    test(
      'keeping the local mark re-queues it as a correction stamped now',
      () async {
        adapter.respond(409, {
          'error': {
            'code': 'attendance.conflict',
            'message': 'Already recorded.',
            'details': {'child_id': 'child-1'},
          },
        });
        final originalTap = DateTime.utc(2026, 9, 13, 9, 5);
        await repository.mark(
          sessionId: sessionId,
          childId: 'child-1',
          status: AttendanceStatus.absent,
          recordedAtClient: originalTap,
        );
        await repository.sync(sessionId: sessionId);

        adapter.throwDio(DioExceptionType.connectionError);
        final correctedAt = DateTime.utc(2026, 9, 13, 9, 30);
        await repository.keepLocalMark(
          sessionId: sessionId,
          childId: 'child-1',
          correctedAt: correctedAt,
        );
        await settle();

        final row = (await queue()).single;
        expect(row.state, PendingWriteState.pending);
        expect(
          row.recordedAtClient,
          correctedAt,
          reason:
              'a correction is a decision made now, in knowledge of the '
              'server record — not a re-assertion that the old tap was first',
        );
        final payload = jsonDecode(row.payload) as Map<String, dynamic>;
        expect(payload['status'], 'absent');
      },
    );

    test('keeping the server record drops this device\'s mark', () async {
      adapter.respond(409, {
        'error': {
          'code': 'attendance.conflict',
          'message': 'Already recorded.',
          'details': {'child_id': 'child-1'},
        },
      });
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await repository.sync(sessionId: sessionId);

      await repository.keepServerRecord(
        sessionId: sessionId,
        childId: 'child-1',
      );

      expect(await queue(), isEmpty);
    });
  });

  group('non-negotiable case 2 — a mark is submitted exactly once', () {
    test(
      'repeated taps on one child coalesce into a single queued write',
      () async {
        // An educator cycling a chip present→late→absent must produce one write
        // carrying the final intent, not three the server applies in order.
        adapter.throwDio(DioExceptionType.connectionError);

        for (final (index, status) in [
          AttendanceStatus.present,
          AttendanceStatus.late,
          AttendanceStatus.absent,
        ].indexed) {
          await repository.mark(
            sessionId: sessionId,
            childId: 'child-1',
            status: status,
            recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5 + index),
          );
        }

        final rows = await queue();
        expect(rows, hasLength(1));
        final payload = jsonDecode(rows.single.payload) as Map<String, dynamic>;
        expect(payload['status'], 'absent', reason: 'the latest intent wins');
      },
    );

    test('an accepted write is submitted once and removed', () async {
      adapter.respond(200, {'data': <Object?>[]});

      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      // mark() already drains in the background; settle it before counting.
      await repository.sync(sessionId: sessionId);

      expect(
        adapter.patchCount,
        1,
        reason:
            'an absence alert must fire exactly once — a duplicate PATCH '
            'is a duplicate alert to the guardians',
      );
      expect(await queue(), isEmpty);
    });

    test('a retried drain does not double-submit', () async {
      adapter.throwDio(DioExceptionType.connectionError);
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      expect(await queue(), hasLength(1));

      adapter.respond(200, {'data': <Object?>[]});
      await repository.sync(sessionId: sessionId);
      final countAfterFirst = adapter.patchCount;

      // Everything downstream retries: reconnect, manual submit, screen reopen.
      await repository.sync(sessionId: sessionId);
      await repository.sync(sessionId: sessionId);

      expect(adapter.patchCount, countAfterFirst);
      expect(await queue(), isEmpty);
    });

    test('concurrent drains submit each write once', () async {
      // A reconnect and a manual submit firing together must not both send.
      adapter.throwDio(DioExceptionType.connectionError);
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-2',
        status: AttendanceStatus.present,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 6),
      );

      await settle();
      final offlineAttempts = adapter.patchCount;

      adapter.respond(200, {'data': <Object?>[]});
      await Future.wait([
        repository.sync(sessionId: sessionId),
        repository.sync(sessionId: sessionId),
        repository.sync(sessionId: sessionId),
      ]);

      expect(
        adapter.patchCount - offlineAttempts,
        2,
        reason: 'two children, two writes — three concurrent drains, not six',
      );
      expect(await queue(), isEmpty);
    });

    test('a child marked present does not queue differently from one marked '
        'absent', () async {
      // The client does not decide whether an absence is "unexplained" and
      // does not suppress or synthesise an alert — specs/README.md keeps that
      // rule server-side. Both marks are the same kind of queued write.
      adapter.throwDio(DioExceptionType.connectionError);

      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-2',
        status: AttendanceStatus.present,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );

      final rows = await queue();
      expect(rows, hasLength(2));
      expect(
        rows.every((r) => r.kind == PendingWriteKind.attendanceMark),
        isTrue,
      );
    });
  });

  group('the offline queue', () {
    test('a mark is durable before it is transmitted', () async {
      // The tap is written to SQLite first, so a killed app between tap and
      // sync loses nothing.
      adapter.throwDio(DioExceptionType.connectionError);

      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );

      expect(await queue(), hasLength(1));
    });

    test('queued marks survive a restart and drain on reconnect', () async {
      adapter.throwDio(DioExceptionType.connectionError);
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await settle();

      // A new repository over the same database is what a relaunch looks like.
      final afterRestart = OfflineFirstAttendanceRepository(
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

      adapter.respond(200, {'data': <Object?>[]});
      final outcome = await afterRestart.sync(sessionId: sessionId);

      expect(outcome.acceptedCount, 1);
      expect(await queue(), isEmpty);
    });

    test(
      'an offline drain reports the queue as still waiting, not failed',
      () async {
        adapter.throwDio(DioExceptionType.connectionError);
        await repository.mark(
          sessionId: sessionId,
          childId: 'child-1',
          status: AttendanceStatus.absent,
          recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
        );

        final outcome = await repository.sync(sessionId: sessionId);

        expect(outcome.wasOffline, isTrue);
        expect(outcome.stillQueuedCount, 1);
        expect(outcome.acceptedCount, 0);
        expect(
          outcome.needsAttention,
          isFalse,
          reason:
              'being offline is a supported state, not something to escalate',
        );
        expect((await queue()).single.state, PendingWriteState.pending);
      },
    );

    test('an unknown child is dropped from the queue and reported', () async {
      // The child moved groups while this device was offline. The mark can
      // never succeed, so retrying forever would be pointless — but the
      // educator has to be told, because a child they thought they registered
      // is not on this sheet.
      adapter.respond(422, {
        'error': {
          'code': 'attendance.unknown_child',
          'message': 'Not enrolled.',
          'details': {'child_id': 'child-1'},
        },
      });

      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      final outcome = await repository.sync(sessionId: sessionId);

      expect(outcome.unknownChildIds, ['child-1']);
      expect(outcome.needsAttention, isTrue);
      expect(await queue(), isEmpty);
    });

    test(
      'a scope failure keeps the write queued rather than losing it',
      () async {
        adapter.respond(403, {
          'error': {'code': 'scope.forbidden', 'message': 'Not yours.'},
        });

        await repository.mark(
          sessionId: sessionId,
          childId: 'child-1',
          status: AttendanceStatus.absent,
          recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
        );
        final outcome = await repository.sync(sessionId: sessionId);

        expect(outcome.acceptedCount, 0);
        expect(outcome.stillQueuedCount, 1);
        expect((await queue()).single.lastErrorCode, 'scope.forbidden');
      },
    );

    test('one child\'s conflict does not fail another child\'s mark', () async {
      // A drain is not success-or-failure; the educator must not be told a
      // landed mark failed because a different one was refused.
      //
      // Both marks are queued offline first, so a single drain handles the
      // pair — which is also the real shape of the case: a group marked in a
      // hall with no signal, submitted on the way out.
      adapter.throwDio(DioExceptionType.connectionError);
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.present,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-2',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 6),
      );
      await settle();

      adapter.respondByChild({
        'child-1': const _StubResponse(200, {'data': <Object?>[]}),
        'child-2': const _StubResponse(409, {
          'error': {
            'code': 'attendance.conflict',
            'message': 'Already recorded.',
            'details': {'child_id': 'child-2'},
          },
        }),
      });
      final outcome = await settle();

      expect(outcome.acceptedCount, 1);
      expect(outcome.conflicts, hasLength(1));
      expect(outcome.conflicts.single.childId, 'child-2');
    });

    test('a conflict discovered by a background drain still reaches the '
        'sheet', () async {
      // mark() fires a drain without awaiting it, so its SyncOutcome is
      // discarded by design. The educator must still find out — the sheet is
      // the channel that carries it, not the return value nobody read.
      adapter.respondByChild({
        'child-1': const _StubResponse(409, {
          'error': {
            'code': 'attendance.conflict',
            'message': 'Already recorded.',
            'details': {'child_id': 'child-1', 'status': 'present'},
          },
        }),
      });

      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await settle();

      adapter.throwDio(DioExceptionType.connectionError);
      final sheet = await repository.loadSheet(
        sessionId: sessionId,
        groupId: groupId,
      );

      expect(
        sheet.entries.firstWhere((e) => e.childId == 'child-1').hasConflict,
        isTrue,
      );
    });

    test('the queue depth excludes conflicted rows', () async {
      // A conflicted row is not waiting for the network, it is waiting for a
      // person — counting it as pending would show a badge that never clears.
      adapter.respond(409, {
        'error': {
          'code': 'attendance.conflict',
          'message': 'Already recorded.',
          'details': {'child_id': 'child-1'},
        },
      });
      await repository.mark(
        sessionId: sessionId,
        childId: 'child-1',
        status: AttendanceStatus.absent,
        recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
      );
      await repository.sync(sessionId: sessionId);

      expect(await repository.watchQueueDepth().first, 0);
    });
  });

  group('loadSheet', () {
    test(
      'falls back to the cached sheet when offline, rather than throwing',
      () async {
        adapter.throwDio(DioExceptionType.connectionError);

        final sheet = await repository.loadSheet(
          sessionId: sessionId,
          groupId: groupId,
        );

        expect(sheet.isFromCache, isTrue);
        expect(sheet.entries, hasLength(2));
      },
    );

    test(
      'a pending mark shows on the sheet before it reaches the server',
      () async {
        adapter.throwDio(DioExceptionType.connectionError);
        await repository.mark(
          sessionId: sessionId,
          childId: 'child-1',
          status: AttendanceStatus.late,
          recordedAtClient: DateTime.utc(2026, 9, 13, 9, 5),
        );

        final sheet = await repository.loadSheet(
          sessionId: sessionId,
          groupId: groupId,
        );
        final entry = sheet.entries.firstWhere((e) => e.childId == 'child-1');

        expect(entry.isPending, isTrue);
        expect(entry.effectiveStatus, AttendanceStatus.late);
      },
    );

    test('a malformed sheet fails loudly rather than reading as an empty '
        'group', () async {
      adapter.respond(200, {'data': 'not-an-array'});

      await expectLater(
        repository.loadSheet(sessionId: sessionId, groupId: groupId),
        throwsA(isA<ContractException>()),
      );
    });
  });
}

class _StubResponse {
  const _StubResponse(this.status, this.body);

  final int status;
  final Object? body;
}

class _StubAdapter implements HttpClientAdapter {
  int _status = 200;
  Object? _body;
  DioExceptionType? _throwType;
  Map<String, _StubResponse>? _byChildId;

  /// How many PATCHes were actually sent — the duplicate-submission counter.
  int patchCount = 0;

  void respond(int status, Object? body) {
    _status = status;
    _body = body;
    _throwType = null;
    _byChildId = null;
  }

  /// Answers by which child the write is about.
  ///
  /// Keyed rather than ordered because `mark()` fires a background drain, so
  /// the number and order of requests is not something a test should have to
  /// predict.
  void respondByChild(Map<String, _StubResponse> byChildId) {
    _byChildId = byChildId;
    _throwType = null;
  }

  void throwDio(DioExceptionType type) {
    _throwType = type;
    _byChildId = null;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'PATCH') patchCount++;

    final throwType = _throwType;
    if (throwType != null) {
      throw DioException(requestOptions: options, type: throwType);
    }

    final byChildId = _byChildId;
    var response = _StubResponse(_status, _body);
    if (byChildId != null) {
      final body = options.data;
      final records = body is Map ? body['records'] : null;
      final first = records is List && records.isNotEmpty
          ? records.first
          : null;
      final childId = first is Map ? first['child_id'] as String? : null;
      response =
          byChildId[childId] ?? const _StubResponse(200, {'data': <Object?>[]});
    }

    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
