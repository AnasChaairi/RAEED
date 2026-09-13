import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../../core/database/raeed_database.dart';
import '../../../core/error/api_error_code.dart';
import '../../../core/error/raeed_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/attendance_repository.dart';
import '../domain/attendance_sheet.dart';
import '../domain/attendance_status.dart';
import '../domain/presence_answer.dart';
import 'attendance_dto.dart';

/// The attendance repository: Drift queue in front, API behind.
///
/// The ordering is the feature. A tap is written to SQLite **before** anything
/// is attempted over the network, so the mark is durable the instant the
/// educator's finger leaves the screen — a dropped connection, a killed app or
/// a flat battery between tap and sync loses nothing. The network attempt is
/// then best-effort, and failing it is an ordinary state rather than an error.
///
/// `specs/README.md` is explicit that offline writes are *queued, not
/// independently validated*: this class never decides whether an absence is
/// unexplained, never suppresses an alert, and never resolves a conflict on the
/// educator's behalf. It transports intent and reports what the server said.
class OfflineFirstAttendanceRepository implements AttendanceRepository {
  OfflineFirstAttendanceRepository({
    required RaeedDatabase database,
    required ApiClient client,
  }) : _db = database,
       _client = client;

  final RaeedDatabase _db;
  final ApiClient _client;

  /// The drain currently in flight, if any.
  ///
  /// Reconnect, manual submit and screen-open can all trigger a sync at the
  /// same moment. Joining one drain rather than starting three is what keeps a
  /// single queued mark from being submitted three times.
  Future<SyncOutcome>? _inFlightDrain;

  /// Monotonic source for claim tokens.
  int _claimCounter = 0;

  @override
  Future<AttendanceSheet> loadSheet({
    required String sessionId,
    required String groupId,
  }) async {
    try {
      final response = await _client.getObject(
        '/sessions/$sessionId/attendance',
      );
      final entries = _entriesFromResponse(response);
      final session = _objectOf(response['session']);
      await _cacheSheet(
        sessionId: sessionId,
        groupId: groupId,
        groupName: session?['group_name'] as String?,
        startsAt:
            DateTime.tryParse(session?['starts_at'] as String? ?? '')
                ?.toUtc() ??
            DateTime.now().toUtc(),
        entries: entries,
      );
      // Awaited inside the try on purpose: composing reads the cache we just
      // wrote, and a failure there should fall through to the cached path
      // below rather than escape as an unhandled rejection.
      return await _composeSheet(
        sessionId: sessionId,
        groupId: groupId,
        isFromCache: false,
      );
    } on NetworkException {
      // An educator in a basement hall still has to mark attendance. A cached
      // sheet is the answer; an exception would be a locked screen.
      return _composeSheet(
        sessionId: sessionId,
        groupId: groupId,
        isFromCache: true,
      );
    }
  }

  @override
  Stream<AttendanceSheet> watchSheet({
    required String sessionId,
    required String groupId,
  }) {
    // Re-composes whenever either side changes: the cached server view, or the
    // queue sitting on top of it.
    final cached = _db.watchCachedEntries(sessionId);
    final pending = _db.watchPendingWrites(
      kind: PendingWriteKind.attendanceMark,
      targetId: sessionId,
    );

    return Rx.combine2(cached, pending, (_, _) => null).asyncMap(
      (_) => _composeSheet(
        sessionId: sessionId,
        groupId: groupId,
        isFromCache: false,
      ),
    );
  }

  @override
  Future<void> mark({
    required String sessionId,
    required String childId,
    required AttendanceStatus status,
    required DateTime recordedAtClient,
  }) async {
    await _db.enqueueWrite(
      kind: PendingWriteKind.attendanceMark,
      targetId: sessionId,
      childId: childId,
      payload: jsonEncode(
        attendanceRecordInputToJson(
          childId: childId,
          status: status,
          recordedAtClient: recordedAtClient,
        ),
      ),
      recordedAtClient: recordedAtClient,
    );

    // Best-effort. The mark is already durable; whether it reaches the server
    // now or on the next reconnect changes nothing about what was recorded.
    unawaited(_drainQuietly(sessionId: sessionId));
  }

  @override
  Future<SyncOutcome> sync({String? sessionId}) {
    final existing = _inFlightDrain;
    if (existing != null) return existing;

    final attempt = _drain(sessionId: sessionId);
    _inFlightDrain = attempt;
    return attempt.whenComplete(() => _inFlightDrain = null);
  }

  @override
  Future<void> keepLocalMark({
    required String sessionId,
    required String childId,
    required DateTime correctedAt,
  }) async {
    final conflicted = await _db.findPendingWrite(
      kind: PendingWriteKind.attendanceMark,
      targetId: sessionId,
      childId: childId,
    );
    if (conflicted == null) return;

    final payload = jsonDecode(conflicted.payload) as Map<String, dynamic>;
    final status = AttendanceStatus.fromWire(payload['status'] as String?);
    if (status == null) return;

    // Re-stamped at `correctedAt`, not at the original tap. This is no longer
    // "my offline mark was first" — it is a deliberate correction made now, in
    // full knowledge of what the server holds, and the server records it as a
    // new attendance_record with corrected_from set rather than an update in
    // place, so both sides survive in the audit trail.
    await _db.replaceWrite(
      id: conflicted.id,
      payload: jsonEncode(
        attendanceRecordInputToJson(
          childId: childId,
          status: status,
          recordedAtClient: correctedAt,
        ),
      ),
      recordedAtClient: correctedAt,
      state: PendingWriteState.pending,
    );

    unawaited(_drainQuietly(sessionId: sessionId));
  }

  @override
  Future<void> keepServerRecord({
    required String sessionId,
    required String childId,
  }) => _db.deletePendingWrite(
    kind: PendingWriteKind.attendanceMark,
    targetId: sessionId,
    childId: childId,
  );

  @override
  Stream<int> watchQueueDepth() => _db.watchQueueDepth();

  // --- Draining -------------------------------------------------------------

  Future<void> _drainQuietly({String? sessionId}) async {
    try {
      await sync(sessionId: sessionId);
    } on Object {
      // A failed drain is not an error the caller of mark() should see — the
      // mark is queued and will go out later.
    }
  }

  Future<SyncOutcome> _drain({String? sessionId}) async {
    final token =
        'drain-${_claimCounter++}-${DateTime.now().microsecondsSinceEpoch}';

    // Claiming is a single transaction: only rows this drain owns are sent, so
    // a concurrent drain cannot pick up the same row and submit it twice.
    final claimed = await _db.claimPendingWrites(
      kind: PendingWriteKind.attendanceMark,
      targetId: sessionId,
      claimToken: token,
    );
    if (claimed.isEmpty) return SyncOutcome.idle;

    var accepted = 0;
    final conflicts = <AttendanceConflict>[];
    final unknownChildIds = <String>[];
    var stillQueued = 0;
    var wasOffline = false;

    for (final write in claimed) {
      if (wasOffline) {
        // Once the network is gone it is gone for the rest of this drain;
        // hammering it per child wastes battery on a device that is already
        // struggling.
        await _db.releaseWrite(id: write.id, claimToken: token);
        stillQueued++;
        continue;
      }

      try {
        await _client.patch(
          '/sessions/${write.targetId}/attendance',
          body: {
            'records': [jsonDecode(write.payload)],
          },
        );
        // Deleted under the same claim token, so an accepted write is removed
        // exactly once even if another drain started meanwhile.
        await _db.completeWrite(id: write.id, claimToken: token);
        accepted++;
      } on NetworkException {
        await _db.releaseWrite(id: write.id, claimToken: token);
        stillQueued++;
        wasOffline = true;
      } on ApiException catch (error) {
        switch (error.code) {
          case ApiErrorCode.attendanceConflict:
            // Never auto-discarded and never auto-retried. The row stays
            // `conflicted` so the educator sees both sides and chooses —
            // silently doing either is exactly what the conflict rule exists
            // to prevent.
            final conflict = conflictFromDetails(
              childId: write.childId,
              attemptedStatus:
                  AttendanceStatus.fromWire(
                    (jsonDecode(write.payload)
                            as Map<String, dynamic>)['status']
                        as String?,
                  ) ??
                  AttendanceStatus.present,
              attemptedRecordedAtClient: write.recordedAtClient,
              details: error.details,
            );
            conflicts.add(conflict);
            await _db.markWriteConflicted(
              id: write.id,
              claimToken: token,
              conflictPayload: jsonEncode(error.details),
              errorCode: error.code.wireValue,
            );

          case ApiErrorCode.attendanceUnknownChild:
            // The child moved groups while this device was offline. The mark
            // can never succeed, so it is dropped — but the educator is told,
            // because a child they thought they had registered is now not on
            // this sheet at all.
            unknownChildIds.add(write.childId);
            await _db.completeWrite(id: write.id, claimToken: token);

          default:
            await _db.releaseWrite(
              id: write.id,
              claimToken: token,
              errorCode: error.code.wireValue,
            );
            stillQueued++;
        }
      } on RaeedException {
        await _db.releaseWrite(id: write.id, claimToken: token);
        stillQueued++;
      }
    }

    return SyncOutcome(
      acceptedCount: accepted,
      conflicts: conflicts,
      unknownChildIds: unknownChildIds,
      stillQueuedCount: stillQueued,
      wasOffline: wasOffline,
    );
  }

  // --- Composition ----------------------------------------------------------

  Map<String, Object?>? _objectOf(Object? value) =>
      value is Map ? value.cast<String, Object?>() : null;

  List<AttendanceEntry> _entriesFromResponse(Map<String, Object?> response) {
    final data = response['data'];
    if (data is! List) {
      throw const ContractException(
        message: 'Attendance sheet is missing its `data` array',
      );
    }
    return data
        .map(
          (element) => attendanceEntryFromJson(
            element is Map<String, Object?>
                ? element
                : (element as Map).cast<String, Object?>(),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _cacheSheet({
    required String sessionId,
    required String groupId,
    required String? groupName,
    required DateTime startsAt,
    required List<AttendanceEntry> entries,
  }) {
    final now = DateTime.now().toUtc();
    return _db.cacheSheetRows(
      sessionId: sessionId,
      groupId: groupId,
      groupName: groupName,
      startsAt: startsAt,
      rows: [
        for (final (index, entry) in entries.indexed)
          CachedAttendanceEntriesCompanion.insert(
            sessionId: sessionId,
            childId: entry.childId,
            childName: entry.childName,
            photoUrl: Value(entry.photoUrl),
            hasHealthAlert: Value(entry.hasHealthAlert),
            presenceAnswer: Value(entry.presenceAnswer?.wireValue),
            presenceReason: Value(entry.presenceReason?.wireValue),
            serverStatus: Value(entry.serverStatus?.wireValue),
            serverRecordedAt: Value(entry.serverRecordedAt),
            position: Value(index),
            cachedAt: now,
          ),
      ],
    );
  }

  /// Maps a cached row back to the domain entry.
  AttendanceEntry _toDomain(CachedAttendanceEntry row) => AttendanceEntry(
    childId: row.childId,
    childName: row.childName,
    photoUrl: row.photoUrl,
    hasHealthAlert: row.hasHealthAlert,
    presenceAnswer: PresenceAnswerValue.fromWire(row.presenceAnswer),
    presenceReason: AbsenceReason.fromWire(row.presenceReason),
    serverStatus: AttendanceStatus.fromWire(row.serverStatus),
    serverRecordedAt: row.serverRecordedAt,
  );

  /// Overlays the queue on the cached server view.
  ///
  /// The queue always wins for display: an educator who marked a child two
  /// minutes ago must see that mark, whether or not it has reached the server.
  /// A conflicted row shows as a conflict rather than as either side's value,
  /// because the whole point is that the app does not know which is right.
  Future<AttendanceSheet> _composeSheet({
    required String sessionId,
    required String groupId,
    required bool isFromCache,
  }) async {
    final cached = await _db.readCachedEntries(sessionId);
    final pending = await _db.readPendingWrites(
      kind: PendingWriteKind.attendanceMark,
      targetId: sessionId,
    );
    final pendingByChild = {for (final write in pending) write.childId: write};

    final entries = cached
        .map((row) {
          final entry = _toDomain(row);
          final write = pendingByChild[entry.childId];
          if (write == null) return entry;

          final payload = jsonDecode(write.payload) as Map<String, dynamic>;
          final status = AttendanceStatus.fromWire(
            payload['status'] as String?,
          );

          if (write.state == PendingWriteState.conflicted) {
            return entry.copyWith(
              conflict: conflictFromDetails(
                childId: entry.childId,
                attemptedStatus: status ?? AttendanceStatus.present,
                attemptedRecordedAtClient: write.recordedAtClient,
                details: write.conflictPayload == null
                    ? const {}
                    : (jsonDecode(write.conflictPayload!) as Map)
                          .cast<String, Object?>(),
              ),
            );
          }

          return entry.copyWith(
            pendingStatus: status,
            pendingRecordedAtClient: write.recordedAtClient,
          );
        })
        .toList(growable: false);

    final session = await _db.readCachedSession(sessionId);

    return AttendanceSheet(
      sessionId: sessionId,
      groupId: groupId,
      groupName: session?.groupName,
      entries: entries,
      isFromCache: isFromCache,
    );
  }
}

/// Minimal two-stream combiner.
///
/// `rxdart` would add a dependency for one function, and `specs/README.md`
/// asks for no unnecessary ones.
abstract final class Rx {
  /// Emits whenever either source emits, once both have produced a value.
  static Stream<R> combine2<A, B, R>(
    Stream<A> a,
    Stream<B> b,
    R Function(A a, B b) combine,
  ) {
    late StreamController<R> controller;
    StreamSubscription<A>? subA;
    StreamSubscription<B>? subB;
    var hasA = false;
    var hasB = false;
    late A latestA;
    late B latestB;

    void emit() {
      if (hasA && hasB) controller.add(combine(latestA, latestB));
    }

    controller = StreamController<R>(
      onListen: () {
        subA = a.listen((value) {
          latestA = value;
          hasA = true;
          emit();
        }, onError: controller.addError);
        subB = b.listen((value) {
          latestB = value;
          hasB = true;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await subA?.cancel();
        await subB?.cancel();
        await controller.close();
      },
    );

    return controller.stream;
  }
}
