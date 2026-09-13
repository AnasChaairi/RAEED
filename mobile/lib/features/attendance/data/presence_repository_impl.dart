import 'dart:async';
import 'dart:convert';

import '../../../core/database/raeed_database.dart';
import '../../../core/error/raeed_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/attendance_repository.dart';
import '../domain/presence_answer.dart';
import 'attendance_dto.dart';

/// Presence answers, queued offline exactly like attendance marks (`RAEED-16`).
///
/// The two are the only offline-writable things in the product
/// (`specs/02-architecture.md`), and they share the same queue and the same
/// claim protocol — a parent tapping "no" on a bus with no signal must be as
/// safe as an educator marking a hall.
///
/// Unanswered confirmations are kept locally and exposed as a stream because a
/// confirmation that arrived only as a push is lost the moment the push is.
/// `ATT-04` also lets a parent declare an absence in advance without waiting
/// for one at all, so this list is a real surface, not a push cache.
class OfflineFirstPresenceRepository implements PresenceRepository {
  OfflineFirstPresenceRepository({
    required RaeedDatabase database,
    required ApiClient client,
  }) : _db = database,
       _client = client;

  final RaeedDatabase _db;
  final ApiClient _client;

  /// Confirmations last fetched from the server, keyed by confirmation **and
  /// child**.
  ///
  /// Not by confirmation alone: a confirmation belongs to a *session*, so it
  /// covers a whole group, and a guardian with two children in that group owes
  /// two answers against the same confirmation id. Keying on the confirmation
  /// would silently collapse them and lose one child's prompt entirely — which
  /// the seeded data reproduces, two siblings in الأشبال أ.
  ///
  /// Held in memory rather than in Drift: unlike an attendance sheet this is a
  /// prompt, not a record, and a stale prompt surviving a relaunch would ask a
  /// parent to answer something already answered.
  final Map<String, PendingPresenceConfirmation> _unanswered = {};

  /// The composite key: one outstanding answer per (confirmation, child).
  static String _promptKey(String confirmationId, String childId) =>
      '$confirmationId:$childId';
  final StreamController<List<PendingPresenceConfirmation>> _unansweredStream =
      StreamController<List<PendingPresenceConfirmation>>.broadcast();

  Future<SyncOutcome>? _inFlightDrain;
  int _claimCounter = 0;

  @override
  Future<void> answer(PresenceAnswerDraft draft) async {
    await _db.enqueueWrite(
      kind: PendingWriteKind.presenceAnswer,
      targetId: draft.confirmationId,
      childId: draft.childId,
      payload: jsonEncode(presenceAnswerInputToJson(draft)),
      // A presence answer has no `recorded_at_client` in the contract, but the
      // queue needs an ordering key and "when the parent tapped" is the honest
      // one — if two answers for the same child ever race, the later tap is
      // the parent's current intent.
      recordedAtClient: DateTime.now().toUtc(),
    );

    // Answered locally, so stop prompting for it immediately — waiting for the
    // server would leave the card asking a question the parent just answered.
    // Only this child's prompt is removed; a sibling in the same group still
    // owes their own answer.
    _unanswered.remove(_promptKey(draft.confirmationId, draft.childId));
    _emitUnanswered();

    unawaited(_drainQuietly());
  }

  @override
  Stream<List<PendingPresenceConfirmation>> watchUnanswered() async* {
    yield _snapshot();
    yield* _unansweredStream.stream;
  }

  @override
  Future<List<PendingPresenceConfirmation>> refreshUnanswered() async {
    final response = await _client.getObject('/presence-confirmations/pending');
    final data = response['data'];
    if (data is! List) {
      throw const ContractException(
        message: 'Pending confirmations are missing their `data` array',
      );
    }

    _unanswered
      ..clear()
      ..addEntries(
        data
            .map(
              (element) => pendingConfirmationFromJson(
                element is Map<String, Object?>
                    ? element
                    : (element as Map).cast<String, Object?>(),
              ),
            )
            .map(
              (confirmation) => MapEntry(
                _promptKey(confirmation.confirmationId, confirmation.childId),
                confirmation,
              ),
            ),
      );

    // A confirmation the parent has already answered offline must not come
    // back as a prompt just because the server has not heard yet.
    final queued = await _db.readPendingWrites(
      kind: PendingWriteKind.presenceAnswer,
    );
    for (final write in queued) {
      _unanswered.remove(_promptKey(write.targetId, write.childId));
    }

    _emitUnanswered();
    return _snapshot();
  }

  @override
  Future<SyncOutcome> sync() {
    final existing = _inFlightDrain;
    if (existing != null) return existing;

    final attempt = _drain();
    _inFlightDrain = attempt;
    return attempt.whenComplete(() => _inFlightDrain = null);
  }

  /// Releases the stream. Called when the owning provider is disposed.
  Future<void> dispose() => _unansweredStream.close();

  // --- Internals ------------------------------------------------------------

  List<PendingPresenceConfirmation> _snapshot() =>
      _unanswered.values.toList(growable: false)
        ..sort((a, b) => a.sessionStartsAt.compareTo(b.sessionStartsAt));

  void _emitUnanswered() {
    if (_unansweredStream.isClosed) return;
    _unansweredStream.add(_snapshot());
  }

  Future<void> _drainQuietly() async {
    try {
      await sync();
    } on Object {
      // Queued; it will go out on the next reconnect.
    }
  }

  Future<SyncOutcome> _drain() async {
    final token =
        'presence-${_claimCounter++}-${DateTime.now().microsecondsSinceEpoch}';
    final claimed = await _db.claimPendingWrites(
      kind: PendingWriteKind.presenceAnswer,
      claimToken: token,
    );
    if (claimed.isEmpty) return SyncOutcome.idle;

    var accepted = 0;
    var stillQueued = 0;
    var wasOffline = false;

    for (final write in claimed) {
      if (wasOffline) {
        await _db.releaseWrite(id: write.id, claimToken: token);
        stillQueued++;
        continue;
      }

      try {
        await _client.post(
          '/presence-confirmations/${write.targetId}/answers',
          body: jsonDecode(write.payload),
        );
        await _db.completeWrite(id: write.id, claimToken: token);
        accepted++;
      } on NetworkException {
        await _db.releaseWrite(id: write.id, claimToken: token);
        stillQueued++;
        wasOffline = true;
      } on ApiException catch (error) {
        // A presence answer has no conflict rule: the server takes the latest
        // answer. Anything it refuses outright is dropped rather than retried
        // forever — a confirmation whose deadline has passed will never accept
        // an answer, and a queue that never empties is a queue nobody trusts.
        await _db.completeWrite(id: write.id, claimToken: token);
        _lastErrorCode = error.code.wireValue;
      } on RaeedException {
        await _db.releaseWrite(id: write.id, claimToken: token);
        stillQueued++;
      }
    }

    return SyncOutcome(
      acceptedCount: accepted,
      stillQueuedCount: stillQueued,
      wasOffline: wasOffline,
    );
  }

  /// The last server refusal, for diagnostics.
  String? _lastErrorCode;

  /// Exposed for diagnostics and tests; not part of the interface.
  String? get lastErrorCode => _lastErrorCode;
}
