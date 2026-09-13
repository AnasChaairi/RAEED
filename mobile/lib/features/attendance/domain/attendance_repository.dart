import 'attendance_sheet.dart';
import 'attendance_status.dart';
import 'presence_answer.dart';

/// The outcome of draining the offline queue.
///
/// A drain is not "success or failure": one child's mark can land while
/// another's is refused as stale, and the educator needs to be told about the
/// second without being told the first failed.
class SyncOutcome {
  const SyncOutcome({
    this.acceptedCount = 0,
    this.conflicts = const [],
    this.unknownChildIds = const [],
    this.stillQueuedCount = 0,
    this.wasOffline = false,
  });

  /// Writes the server accepted.
  final int acceptedCount;

  /// Writes refused with `attendance.conflict`, each carrying both sides.
  final List<AttendanceConflict> conflicts;

  /// Children the server says are not enrolled in this session's group
  /// (`attendance.unknown_child`, 422).
  ///
  /// Almost always means the child was moved between groups while the device
  /// was offline. The mark is dropped from the queue — it can never succeed —
  /// and the educator is told, because a child they thought they were
  /// registering is now nobody's responsibility on this sheet.
  final List<String> unknownChildIds;

  /// Writes still waiting, because the device is still unreachable.
  final int stillQueuedCount;

  /// Whether the drain stopped because there was no network.
  final bool wasOffline;

  /// Whether anything at all needs the educator's attention.
  bool get needsAttention => conflicts.isNotEmpty || unknownChildIds.isNotEmpty;

  /// Nothing was queued, so nothing happened.
  static const SyncOutcome idle = SyncOutcome();
}

/// Reads and writes attendance.
///
/// Pure interface, in the domain layer, so the application and presentation
/// layers never learn whether a mark went to the network or to SQLite — which
/// is the point: `specs/06-mobile-app-spec.md` requires the screen to work
/// identically offline, and a screen that branches on transport would not.
abstract interface class AttendanceRepository {
  /// Loads the sheet for [sessionId], pre-filled from presence answers.
  ///
  /// Fetches from the network and caches. When the device is unreachable,
  /// returns the cached sheet with [AttendanceSheet.isFromCache] set rather
  /// than throwing — an educator in a basement hall still has to mark
  /// attendance.
  Future<AttendanceSheet> loadSheet({
    required String sessionId,
    required String groupId,
  });

  /// Watches the sheet, re-emitting as queued writes are made, drained, or
  /// refused.
  Stream<AttendanceSheet> watchSheet({
    required String sessionId,
    required String groupId,
  });

  /// Records one mark.
  ///
  /// [recordedAtClient] is **the moment of the tap**, supplied by the caller
  /// and never defaulted at sync time. It is the value the conflict rule in
  /// `specs/03-domain-model/entities.md` compares.
  ///
  /// The mark is queued locally first, unconditionally, and only then attempted
  /// against the network — so a tap is durable before it is transmitted.
  Future<void> mark({
    required String sessionId,
    required String childId,
    required AttendanceStatus status,
    required DateTime recordedAtClient,
  });

  /// Drains every queued write for [sessionId], or for every session when it is
  /// null.
  ///
  /// Safe to call repeatedly and concurrently: a drain already in flight is
  /// joined rather than duplicated, and an accepted write is removed from the
  /// queue exactly once.
  Future<SyncOutcome> sync({String? sessionId});

  /// Resolves a conflict by re-asserting this device's mark as a *correction*.
  ///
  /// Queues a fresh write stamped now, which the server accepts and records as
  /// a new `attendance_record` with `corrected_from` pointing at the row it
  /// supersedes (`specs/03-domain-model/entities.md`) — never an update in
  /// place. The audit trail keeps both.
  Future<void> keepLocalMark({
    required String sessionId,
    required String childId,
    required DateTime correctedAt,
  });

  /// Resolves a conflict by accepting the server's record and dropping this
  /// device's.
  Future<void> keepServerRecord({
    required String sessionId,
    required String childId,
  });

  /// How many writes are waiting, across every session.
  Stream<int> watchQueueDepth();
}

/// Submits presence answers (`RAEED-16`).
abstract interface class PresenceRepository {
  /// Records a guardian's answer.
  ///
  /// Queued in Drift when offline and synced on reconnect, exactly like an
  /// attendance mark — the two are the only offline-writable things in the
  /// product (`specs/02-architecture.md`).
  Future<void> answer(PresenceAnswerDraft draft);

  /// Confirmations this device knows the guardian has not answered.
  ///
  /// Exposed so the Home card can show them: a confirmation that only ever
  /// arrived by push is lost the moment the push is, and `ATT-04` depends on
  /// parents being able to declare in advance without waiting for one.
  Stream<List<PendingPresenceConfirmation>> watchUnanswered();

  /// Refreshes the unanswered list from the server.
  Future<List<PendingPresenceConfirmation>> refreshUnanswered();

  /// Drains the queued answers.
  Future<SyncOutcome> sync();
}
