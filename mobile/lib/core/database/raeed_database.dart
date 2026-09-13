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
  /// Opens the on-device database file.
  RaeedDatabase() : super(driftDatabase(name: _databaseName));

  /// Opens a database on [executor] — used by tests with an in-memory one, and
  /// the reason no test ever touches the real file.
  RaeedDatabase.forTesting(super.executor);

  static const String _databaseName = 'raeed';

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
