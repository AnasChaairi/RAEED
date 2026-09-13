/// The on-device schema — deliberately the smallest thing that satisfies
/// `specs/02-architecture.md`'s offline scope, and nothing more.
///
/// That scope is narrow on purpose:
///
/// > Only two things work offline: today's sessions + attendance marking
/// > (Drift-backed local queue, synced on reconnect), and presence-confirmation
/// > answers. Everything else is read-cached, write-online-only.
///
/// So there is no `child` table, no messages, no Memories Wall, no
/// announcements here. Caching a child's profile for writing would be a
/// safeguarding liability (a stale `image_rights_level` on a device is worse
/// than no value at all), and the spec settles the question: those features are
/// online-only for writes.
library;

import 'package:drift/drift.dart';

/// A session the device may need while offline.
///
/// Populated only for today's sessions. Rows older than that are pruned on
/// open — an educator does not mark last month's attendance from a plane, and
/// keeping the window tight keeps the amount of children's data at rest on a
/// lost phone to a day.
class CachedSessions extends Table {
  /// `session.id`.
  TextColumn get id => text()();

  /// `session.group_id` — the group whose attendance this sheet belongs to.
  TextColumn get groupId => text()();

  /// The group's display name, denormalised so the screen has a title offline.
  TextColumn get groupName => text()();

  /// When the session starts (UTC).
  DateTimeColumn get startsAt => dateTime()();

  /// When the session ends (UTC), where the server supplied it.
  DateTimeColumn get endsAt => dateTime().nullable()();

  /// When this row was last refreshed from the server.
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One row of an attendance sheet as the server last described it.
///
/// This is the *server's* view, cached. The educator's un-synced intent lives
/// in [PendingWrites] and is layered on top at read time rather than written
/// over this — so a sync failure can never erase what the server actually has,
/// and a conflict has both sides available to show.
class CachedAttendanceEntries extends Table {
  /// `attendance_record.session_id`.
  TextColumn get sessionId => text().references(CachedSessions, #id)();

  /// `attendance_record.child_id`.
  TextColumn get childId => text()();

  /// The child's display name.
  TextColumn get childName => text()();

  /// Avatar URL, when one exists.
  TextColumn get photoUrl => text().nullable()();

  /// `child.health_alert` — the presence-only flag.
  ///
  /// Never the health text itself: `specs/04-api/openapi.yaml` states the full
  /// text is never inlined in a list response, and it is not cached on the
  /// device either. The badge is an icon; the text is fetched on tap-through,
  /// online, and that read is audit-logged server-side (`AUD-03`).
  BoolColumn get hasHealthAlert =>
      boolean().withDefault(const Constant(false))();

  /// The guardian's `presence_answer.answer`, when one was given.
  TextColumn get presenceAnswer => text().nullable()();

  /// The guardian's `presence_answer.reason`, when one was given.
  TextColumn get presenceReason => text().nullable()();

  /// `attendance_record.status` as the server last reported it.
  TextColumn get serverStatus => text().nullable()();

  /// `attendance_record.recorded_at` — **server** time, the source of truth for
  /// "who wrote last" and the left-hand side of the conflict comparison.
  DateTimeColumn get serverRecordedAt => dateTime().nullable()();

  /// Preserves the order the server returned, so the list does not reshuffle
  /// between an online load and an offline one.
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// When this row was last refreshed from the server.
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, childId};
}

/// What kind of write is queued.
enum PendingWriteKind {
  /// An `AttendanceRecordInput` bound for
  /// `PATCH /sessions/{sessionId}/attendance`.
  attendanceMark,

  /// A `PresenceAnswerInput` bound for
  /// `POST /presence-confirmations/{id}/answers`.
  presenceAnswer,
}

/// Where a queued write is in its life.
enum PendingWriteState {
  /// Waiting for connectivity.
  pending,

  /// Handed to the server; the outcome is not known yet.
  ///
  /// A row left here by a process death is released back to [pending] on the
  /// next open, never dropped.
  inFlight,

  /// The server refused it with `attendance.conflict`.
  ///
  /// The row stays in the queue so the educator can be shown what was lost and
  /// decide. It is never auto-discarded and never auto-retried: doing either
  /// silently is exactly what the conflict rule exists to prevent.
  conflicted,
}

/// The offline write queue.
///
/// One row per pending intent. The unique key on
/// (kind, targetId, childId) coalesces repeated taps on the same child into a
/// single queued write carrying the latest intent — an educator cycling a chip
/// four times must produce one write, not four, and the server must not receive
/// three superseded marks for a child before the real one.
class PendingWrites extends Table {
  /// Local autoincrement id. Also the claim unit during a sync drain.
  IntColumn get id => integer().autoIncrement()();

  /// Which endpoint this write is bound for.
  TextColumn get kind => textEnum<PendingWriteKind>()();

  /// The path parameter: a `session.id` for a mark, a
  /// `presence_confirmation.id` for an answer.
  TextColumn get targetId => text()();

  /// The child the write is about.
  TextColumn get childId => text()();

  /// The request body fragment, JSON-encoded.
  TextColumn get payload => text()();

  /// **The moment of the tap**, not the moment of the sync.
  ///
  /// This is `attendance_record.recorded_at_client`, and the distinction is the
  /// entire point of the field (`specs/03-domain-model/entities.md`): the
  /// server compares it against its current `recorded_at` to decide whether
  /// this device's intent is older than what has already been written. Stamping
  /// it at sync time would make every offline write look freshly authoritative
  /// and would silently overwrite whoever marked the child in the meantime.
  DateTimeColumn get recordedAtClient => dateTime()();

  /// When the row entered the queue.
  DateTimeColumn get queuedAt => dateTime()();

  /// Progress through the queue.
  TextColumn get state =>
      textEnum<PendingWriteState>().withDefault(const Constant('pending'))();

  /// Identifies the drain that claimed this row.
  ///
  /// Only the claiming drain may delete or release it, so two triggers firing
  /// at once (a reconnect and a manual submit) cannot both submit the same row.
  TextColumn get claimToken => text().nullable()();

  /// How many times a send has been attempted. Surfaced in diagnostics; the
  /// queue does not give up on its own.
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// The last `ApiErrorCode.wireValue` the server answered with, if any.
  TextColumn get lastErrorCode => text().nullable()();

  /// For a [PendingWriteState.conflicted] row: the server's current record,
  /// JSON-encoded, so the educator can compare the two sides.
  TextColumn get conflictPayload => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {kind, targetId, childId},
  ];
}
