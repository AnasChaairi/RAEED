import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/raeed_database.dart';
import '../../../core/network/api_client_provider.dart';
import '../data/attendance_repository_impl.dart';
import '../data/presence_repository_impl.dart';
import '../domain/attendance_repository.dart';
import '../domain/attendance_sheet.dart';
import '../domain/attendance_status.dart';
import '../domain/presence_answer.dart';

part 'attendance_providers.g.dart';

/// The attendance repository.
@Riverpod(keepAlive: true)
AttendanceRepository attendanceRepository(Ref ref) =>
    OfflineFirstAttendanceRepository(
      database: ref.watch(raeedDatabaseProvider),
      client: ref.watch(apiClientProvider),
    );

/// The presence repository.
@Riverpod(keepAlive: true)
PresenceRepository presenceRepository(Ref ref) {
  final repository = OfflineFirstPresenceRepository(
    database: ref.watch(raeedDatabaseProvider),
    client: ref.watch(apiClientProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
}

/// How many writes are waiting to reach the server.
///
/// Surfaced so an educator can see that the group they marked in a basement
/// hall has not synced yet — a silent queue is indistinguishable from a lost
/// one.
@riverpod
Stream<int> pendingWriteCount(Ref ref) =>
    ref.watch(attendanceRepositoryProvider).watchQueueDepth();

/// Confirmations the guardian has not answered.
///
/// Read by the Home card so an unanswered confirmation survives a missed push.
@riverpod
Stream<List<PendingPresenceConfirmation>> unansweredConfirmations(Ref ref) =>
    ref.watch(presenceRepositoryProvider).watchUnanswered();

/// The attendance sheet for one session, kept live as writes queue and drain.
@riverpod
class AttendanceSheetController extends _$AttendanceSheetController {
  @override
  Stream<AttendanceSheet> build(String sessionId, String groupId) async* {
    final repository = ref.watch(attendanceRepositoryProvider);

    // Load once so the screen has content immediately — from cache when the
    // device is unreachable, which is the whole point of this screen.
    yield await repository.loadSheet(sessionId: sessionId, groupId: groupId);
    yield* repository.watchSheet(sessionId: sessionId, groupId: groupId);
  }

  /// Cycles one child's status: present → late → absent → excused → present.
  ///
  /// [tappedAt] is the moment of the tap and is carried all the way to
  /// `recorded_at_client`. Defaulting it at sync time would make every offline
  /// mark look freshly authoritative and silently overwrite whoever marked the
  /// child in the meantime.
  Future<void> cycle(AttendanceEntry entry, {DateTime? tappedAt}) {
    final next = (entry.effectiveStatus ?? AttendanceStatus.excused).next;
    return _mark(entry.childId, next, tappedAt ?? DateTime.now().toUtc());
  }

  /// Sets one child's status explicitly.
  Future<void> setStatus(
    AttendanceEntry entry,
    AttendanceStatus status, {
    DateTime? tappedAt,
  }) => _mark(entry.childId, status, tappedAt ?? DateTime.now().toUtc());

  /// Marks every still-unmarked child present.
  ///
  /// The common ending: an educator marks the handful who are absent or late,
  /// then sweeps the rest. It deliberately touches only unmarked children —
  /// overwriting a deliberate mark with a bulk action would be the one way this
  /// button could lose data.
  Future<void> markRemainingPresent({DateTime? tappedAt}) async {
    final sheet = state.value;
    if (sheet == null) return;

    final at = tappedAt ?? DateTime.now().toUtc();
    for (final entry in sheet.entries.where((e) => e.isUnmarked)) {
      await _mark(entry.childId, AttendanceStatus.present, at);
    }
  }

  /// Pushes everything queued for this session.
  Future<SyncOutcome> submit() =>
      ref.read(attendanceRepositoryProvider).sync(sessionId: sessionId);

  /// Re-asserts this device's mark after a conflict, as a correction.
  Future<void> keepLocalMark(String childId) => ref
      .read(attendanceRepositoryProvider)
      .keepLocalMark(
        sessionId: sessionId,
        childId: childId,
        correctedAt: DateTime.now().toUtc(),
      );

  /// Accepts the server's record and drops this device's.
  Future<void> keepServerRecord(String childId) => ref
      .read(attendanceRepositoryProvider)
      .keepServerRecord(sessionId: sessionId, childId: childId);

  Future<void> _mark(
    String childId,
    AttendanceStatus status,
    DateTime tappedAt,
  ) => ref
      .read(attendanceRepositoryProvider)
      .mark(
        sessionId: sessionId,
        childId: childId,
        status: status,
        recordedAtClient: tappedAt,
      );
}

/// Submits a guardian's presence answer.
@riverpod
Future<void> Function(PresenceAnswerDraft) submitPresenceAnswer(Ref ref) =>
    ref.watch(presenceRepositoryProvider).answer;
