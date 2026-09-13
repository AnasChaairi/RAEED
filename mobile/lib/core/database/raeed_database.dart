import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'tables.dart';

export 'tables.dart';

part 'raeed_database.g.dart';

/// The app's single SQLite database.
///
/// It holds only `specs/02-architecture.md`'s offline scope: today's sessions,
/// the attendance sheet as the server last described it, and the queue of
/// writes waiting for connectivity. It is not a general-purpose mirror of the
/// backend, and it must not grow into one — every table added here is one more
/// piece of children's data sitting at rest on a volunteer educator's phone.
@DriftDatabase(tables: [CachedSessions, CachedAttendanceEntries, PendingWrites])
class RaeedDatabase extends _$RaeedDatabase {
  /// Opens the on-device database.
  ///
  /// On the web, drift runs SQLite compiled to WebAssembly in a worker; the two
  /// files that takes are served from `web/` (`sqlite3.wasm`, `drift_worker.js`)
  /// and named here by relative URL. On native platforms [DriftWebOptions] is
  /// simply ignored, so this one constructor serves every target — the web is a
  /// convenience for looking at screens, not a supported runtime, and this is
  /// what lets the attendance screen open there at all.
  RaeedDatabase()
    : super(
        driftDatabase(
          name: _databaseName,
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  /// Opens a database on [executor] — used by tests with an in-memory one, and
  /// the reason no test ever touches the real file.
  RaeedDatabase.forTesting(super.executor);

  static const String _databaseName = 'raeed';

  /// Timestamps are stored as ISO-8601 text, not as unix seconds.
  ///
  /// Drift's default packs a DateTime into an integer and hands it back in the
  /// device's local zone. `recorded_at_client` is the value the conflict rule
  /// compares against the server's `recorded_at`
  /// (`specs/03-domain-model/entities.md`), and it travels between a phone, a
  /// server and another phone — losing its UTC offset on the way through
  /// SQLite would make a mark look hours older or newer than it was, and the
  /// conflict rule would resolve the wrong way. Text keeps the offset.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  /// How long a cached session stays useful.
  ///
  /// The offline scope is "today's sessions". Two days of slack covers a
  /// session that runs past midnight and a device whose clock is a little off,
  /// without turning the cache into an archive.
  static const Duration cacheWindow = Duration(days: 2);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes(m);
    },
    onUpgrade: (m, from, to) async {
      // Deliberately fails rather than falling back to deleteAndRecreate. The
      // queue can hold an educator's unsent attendance marks at the moment an
      // app update lands; dropping the database on a schema bump would delete
      // them, and the children whose absence never got reported would be the
      // cost. Every schema change adds its step here first.
      throw StateError(
        'No migration defined from schema v$from to v$to. Add one before '
        'shipping the schema change — the pending-write queue must survive an '
        'app update.',
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) return;
      await _recoverInterruptedWrites();
      await _pruneStaleCache();
    },
  );

  Future<void> _createIndexes(Migrator m) async {
    await m.createIndex(
      Index(
        'idx_pending_writes_state',
        'CREATE INDEX idx_pending_writes_state ON '
            'pending_writes (state, target_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_cached_attendance_session',
        'CREATE INDEX idx_cached_attendance_session ON '
            'cached_attendance_entries (session_id, position)',
      ),
    );
  }

  /// Releases rows a killed process left mid-flight.
  ///
  /// Their outcome is unknown, so they go back to `pending` rather than being
  /// deleted: re-sending a mark the server already has is harmless (the PATCH
  /// is keyed on session+child), whereas dropping one loses an absence.
  Future<void> _recoverInterruptedWrites() async {
    await (update(
      pendingWrites,
    )..where((row) => row.state.equalsValue(PendingWriteState.inFlight))).write(
      const PendingWritesCompanion(
        state: Value(PendingWriteState.pending),
        claimToken: Value(null),
      ),
    );
  }

  /// Drops cached sessions outside the offline window, and the sheet rows that
  /// hang off them.
  ///
  /// Sessions still carrying queued writes are kept regardless of age — an
  /// unsent mark must never lose the sheet it belongs to.
  Future<void> _pruneStaleCache() async {
    final cutoff = DateTime.now().toUtc().subtract(cacheWindow);
    final queuedSessionIds =
        await (selectOnly(pendingWrites)
              ..addColumns([pendingWrites.targetId])
              ..where(
                pendingWrites.kind.equalsValue(PendingWriteKind.attendanceMark),
              ))
            .map((row) => row.read(pendingWrites.targetId)!)
            .get();

    final stale =
        await (select(cachedSessions)..where(
              (row) =>
                  row.startsAt.isSmallerThanValue(cutoff) &
                  row.id.isNotIn(queuedSessionIds),
            ))
            .map((row) => row.id)
            .get();
    if (stale.isEmpty) return;

    await transaction(() async {
      await (delete(
        cachedAttendanceEntries,
      )..where((row) => row.sessionId.isIn(stale))).go();
      await (delete(cachedSessions)..where((row) => row.id.isIn(stale))).go();
    });
  }
}

/// The app's database instance.
///
/// `keepAlive` because closing and reopening SQLite between screens would drop
/// the queue's in-flight claims, and because the sync service holds it for the
/// life of the app.
@Riverpod(keepAlive: true)
RaeedDatabase raeedDatabase(Ref ref) {
  final database = RaeedDatabase();
  ref.onDispose(database.close);
  return database;
}

/// Queries and mutations the attendance/presence repositories build on.
///
/// Kept on the database rather than in the repositories so the claim protocol —
/// the thing that makes a retried drain idempotent — lives in one place and is
/// testable without a network.
extension RaeedDatabaseQueries on RaeedDatabase {
  // --- Cached sheet ---------------------------------------------------------

  /// The cached session row, if one exists.
  Future<CachedSession?> readCachedSession(String sessionId) => (select(
    cachedSessions,
  )..where((t) => t.id.equals(sessionId))).getSingleOrNull();

  /// The cached entries for a session, in the server's order.
  Future<List<CachedAttendanceEntry>> readCachedEntries(String sessionId) =>
      (select(cachedAttendanceEntries)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .get();

  /// Watches [readCachedEntries].
  Stream<List<CachedAttendanceEntry>> watchCachedEntries(String sessionId) =>
      (select(cachedAttendanceEntries)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .watch();

  /// Replaces the cached sheet for one session.
  ///
  /// Deletes then inserts inside a transaction: a child removed from the group
  /// server-side has to disappear locally too, and a half-applied refresh that
  /// left them behind would put a child on an attendance sheet they are no
  /// longer enrolled in.
  Future<void> cacheSheetRows({
    required String sessionId,
    required String groupId,
    String? groupName,
    required DateTime startsAt,
    required List<CachedAttendanceEntriesCompanion> rows,
  }) => transaction(() async {
    final now = DateTime.now().toUtc();
    await into(cachedSessions).insertOnConflictUpdate(
      CachedSessionsCompanion.insert(
        id: sessionId,
        groupId: groupId,
        groupName: groupName ?? '',
        startsAt: startsAt,
        cachedAt: now,
      ),
    );
    await (delete(
      cachedAttendanceEntries,
    )..where((t) => t.sessionId.equals(sessionId))).go();
    await batch((b) => b.insertAll(cachedAttendanceEntries, rows));
  });

  // --- Pending write queue --------------------------------------------------

  /// Adds or replaces the queued write for one child.
  ///
  /// The unique key on (kind, targetId, childId) coalesces repeated taps: an
  /// educator cycling a chip four times produces one write carrying the latest
  /// intent, not four the server has to apply in order.
  ///
  /// A conflicted row is deliberately overwritten — re-tapping a child after
  /// seeing a conflict is a new decision, and it supersedes the refused one.
  Future<void> enqueueWrite({
    required PendingWriteKind kind,
    required String targetId,
    required String childId,
    required String payload,
    required DateTime recordedAtClient,
  }) => into(pendingWrites).insert(
    PendingWritesCompanion.insert(
      kind: kind,
      targetId: targetId,
      childId: childId,
      payload: payload,
      recordedAtClient: recordedAtClient,
      queuedAt: DateTime.now().toUtc(),
      state: const Value(PendingWriteState.pending),
      claimToken: const Value(null),
      conflictPayload: const Value(null),
      lastErrorCode: const Value(null),
      attempts: const Value(0),
    ),
    mode: InsertMode.insertOrReplace,
  );

  /// The queued write for one child, if any.
  Future<PendingWrite?> findPendingWrite({
    required PendingWriteKind kind,
    required String targetId,
    required String childId,
  }) =>
      (select(pendingWrites)..where(
            (t) =>
                t.kind.equalsValue(kind) &
                t.targetId.equals(targetId) &
                t.childId.equals(childId),
          ))
          .getSingleOrNull();

  /// Every queued write for a target.
  Future<List<PendingWrite>> readPendingWrites({
    required PendingWriteKind kind,
    String? targetId,
  }) {
    final query = select(pendingWrites)..where((t) => t.kind.equalsValue(kind));
    if (targetId != null) {
      query.where((t) => t.targetId.equals(targetId));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.queuedAt)]);
    return query.get();
  }

  /// Watches [readPendingWrites].
  Stream<List<PendingWrite>> watchPendingWrites({
    required PendingWriteKind kind,
    String? targetId,
  }) {
    final query = select(pendingWrites)..where((t) => t.kind.equalsValue(kind));
    if (targetId != null) {
      query.where((t) => t.targetId.equals(targetId));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.queuedAt)]);
    return query.watch();
  }

  /// Replaces a queued write's payload and returns it to [PendingWriteState.pending].
  Future<void> replaceWrite({
    required int id,
    required String payload,
    required DateTime recordedAtClient,
    required PendingWriteState state,
  }) => (update(pendingWrites)..where((t) => t.id.equals(id))).write(
    PendingWritesCompanion(
      payload: Value(payload),
      recordedAtClient: Value(recordedAtClient),
      state: Value(state),
      claimToken: const Value(null),
      conflictPayload: const Value(null),
      lastErrorCode: const Value(null),
    ),
  );

  /// Drops the queued write for one child.
  Future<void> deletePendingWrite({
    required PendingWriteKind kind,
    required String targetId,
    required String childId,
  }) =>
      (delete(pendingWrites)..where(
            (t) =>
                t.kind.equalsValue(kind) &
                t.targetId.equals(targetId) &
                t.childId.equals(childId),
          ))
          .go();

  /// How many writes are waiting, across every session and kind.
  ///
  /// Conflicted rows are excluded: they are not waiting for anything, they are
  /// waiting for a person.
  Stream<int> watchQueueDepth() {
    final count = pendingWrites.id.count();
    final query = selectOnly(pendingWrites)
      ..addColumns([count])
      ..where(pendingWrites.state.equalsValue(PendingWriteState.pending));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  // --- The claim protocol ---------------------------------------------------

  /// Claims every pending write for this drain, in one transaction.
  ///
  /// Claiming is what makes a retried or concurrent drain safe: only rows
  /// stamped with *this* token are sent, and only the holder of the token may
  /// later complete or release them. Two drains firing at once — a reconnect
  /// and a manual submit — cannot both pick up the same row, so a queued mark
  /// is never submitted twice.
  Future<List<PendingWrite>> claimPendingWrites({
    required PendingWriteKind kind,
    String? targetId,
    required String claimToken,
  }) => transaction(() async {
    final query = select(pendingWrites)
      ..where(
        (t) =>
            t.kind.equalsValue(kind) &
            t.state.equalsValue(PendingWriteState.pending),
      );
    if (targetId != null) {
      query.where((t) => t.targetId.equals(targetId));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.queuedAt)]);

    final rows = await query.get();
    if (rows.isEmpty) return const <PendingWrite>[];

    await batch((b) {
      for (final row in rows) {
        b.update(
          pendingWrites,
          PendingWritesCompanion(
            state: const Value(PendingWriteState.inFlight),
            claimToken: Value(claimToken),
            attempts: Value(row.attempts + 1),
          ),
          where: (t) => t.id.equals(row.id),
        );
      }
    });

    return rows;
  });

  /// Removes an accepted write — only if this drain still holds the claim.
  Future<void> completeWrite({required int id, required String claimToken}) =>
      (delete(
        pendingWrites,
      )..where((t) => t.id.equals(id) & t.claimToken.equals(claimToken))).go();

  /// Returns an unsent write to the queue for a later drain.
  Future<void> releaseWrite({
    required int id,
    required String claimToken,
    String? errorCode,
  }) =>
      (update(
        pendingWrites,
      )..where((t) => t.id.equals(id) & t.claimToken.equals(claimToken))).write(
        PendingWritesCompanion(
          state: const Value(PendingWriteState.pending),
          claimToken: const Value(null),
          lastErrorCode: Value(errorCode),
        ),
      );

  /// Parks a write the server refused as stale.
  ///
  /// It stays in the queue, out of the pending set, until a person decides.
  Future<void> markWriteConflicted({
    required int id,
    required String claimToken,
    required String conflictPayload,
    required String errorCode,
  }) =>
      (update(
        pendingWrites,
      )..where((t) => t.id.equals(id) & t.claimToken.equals(claimToken))).write(
        PendingWritesCompanion(
          state: const Value(PendingWriteState.conflicted),
          claimToken: const Value(null),
          conflictPayload: Value(conflictPayload),
          lastErrorCode: Value(errorCode),
        ),
      );
}
