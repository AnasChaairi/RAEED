import 'attendance_status.dart';
import 'presence_answer.dart';

/// One child's line on the attendance sheet.
///
/// Carries three layers at once and keeps them apart on purpose:
///
/// * what the guardian answered ([presenceAnswer]) — the pre-fill,
/// * what the server currently records ([serverStatus] / [serverRecordedAt]),
/// * what this device has marked but not yet synced ([pendingStatus]).
///
/// Collapsing them into one "status" field is what makes a conflict
/// unrepresentable, and an unrepresentable conflict is a silent overwrite.
class AttendanceEntry {
  const AttendanceEntry({
    required this.childId,
    required this.childName,
    this.photoUrl,
    this.hasHealthAlert = false,
    this.presenceAnswer,
    this.presenceReason,
    this.serverStatus,
    this.serverRecordedAt,
    this.pendingStatus,
    this.pendingRecordedAtClient,
    this.conflict,
  });

  /// `child.id`.
  final String childId;

  /// The child's display name.
  final String childName;

  /// Avatar URL, when one exists.
  final String? photoUrl;

  /// `child.health_alert` — a flag, never the health text.
  ///
  /// The badge it drives is icon-only. `specs/04-api/openapi.yaml` keeps the
  /// full text out of list responses, and the screen keeps it off the row: a
  /// sheet held up in a hall full of parents must not put one child's medical
  /// condition in everyone's eyeline. The text is reached by a deliberate
  /// tap-through, and that read is audit-logged.
  final bool hasHealthAlert;

  /// What the guardian answered, when they answered.
  final PresenceAnswerValue? presenceAnswer;

  /// The reason the guardian gave, when they gave one.
  final AbsenceReason? presenceReason;

  /// The status the server currently holds.
  final AttendanceStatus? serverStatus;

  /// `attendance_record.recorded_at` — server time.
  final DateTime? serverRecordedAt;

  /// A mark made on this device that has not been accepted yet.
  final AttendanceStatus? pendingStatus;

  /// The instant the educator tapped, carried to the server as
  /// `recorded_at_client`.
  final DateTime? pendingRecordedAtClient;

  /// Set when this device's mark was refused with `attendance.conflict`.
  final AttendanceConflict? conflict;

  /// What the row should display.
  ///
  /// The device's own un-synced mark wins the *display*, because that is what
  /// the educator just did and hiding it would look like a dropped tap. It does
  /// not win the *data* — [serverStatus] is untouched, and a conflict surfaces
  /// separately.
  AttendanceStatus? get effectiveStatus => pendingStatus ?? serverStatus;

  /// Whether this row is waiting on the network.
  bool get isPending => pendingStatus != null && conflict == null;

  /// Whether a mark from this device was refused and is awaiting a decision.
  bool get hasConflict => conflict != null;

  /// Whether the sheet has any status at all for this child.
  bool get isUnmarked => effectiveStatus == null;

  /// The status the sheet arrives pre-filled with, derived from the guardian's
  /// answer.
  ///
  /// A *suggestion for the UI only*. It is never queued as a write on its own:
  /// a pre-fill the educator did not confirm is not an observation, and sending
  /// it would manufacture attendance records — and, for a `no` answer, would
  /// manufacture absences the server then has to reason about.
  static AttendanceStatus? prefillFor(PresenceAnswerValue? answer) =>
      switch (answer) {
        PresenceAnswerValue.yes => AttendanceStatus.present,
        PresenceAnswerValue.late => AttendanceStatus.late,
        PresenceAnswerValue.no => AttendanceStatus.excused,
        null => null,
      };

  /// Returns a copy with the given fields replaced.
  ///
  /// [clearConflict] and [clearPending] exist because `null` is a meaningful
  /// value for those fields, so the usual `?? this.x` idiom cannot express
  /// "remove it".
  AttendanceEntry copyWith({
    AttendanceStatus? pendingStatus,
    DateTime? pendingRecordedAtClient,
    AttendanceStatus? serverStatus,
    DateTime? serverRecordedAt,
    AttendanceConflict? conflict,
    bool clearConflict = false,
    bool clearPending = false,
  }) => AttendanceEntry(
    childId: childId,
    childName: childName,
    photoUrl: photoUrl,
    hasHealthAlert: hasHealthAlert,
    presenceAnswer: presenceAnswer,
    presenceReason: presenceReason,
    serverStatus: serverStatus ?? this.serverStatus,
    serverRecordedAt: serverRecordedAt ?? this.serverRecordedAt,
    pendingStatus: clearPending ? null : pendingStatus ?? this.pendingStatus,
    pendingRecordedAtClient: clearPending
        ? null
        : pendingRecordedAtClient ?? this.pendingRecordedAtClient,
    conflict: clearConflict ? null : conflict ?? this.conflict,
  );
}

/// A mark this device made that the server refused as stale.
///
/// Kept as data rather than logged and dropped. `specs/11-testing-strategy.md`
/// names this as a non-negotiable case: the loser of a conflict is *surfaced to
/// the educator*, never silently discarded and never silently overwriting. An
/// educator who marked a child absent on a phone with no signal has to find out
/// that the mark did not stand.
class AttendanceConflict {
  const AttendanceConflict({
    required this.childId,
    required this.attemptedStatus,
    required this.attemptedRecordedAtClient,
    this.serverStatus,
    this.serverRecordedAt,
    this.serverRecordedByName,
  });

  /// The child whose mark was refused.
  final String childId;

  /// What this device tried to record.
  final AttendanceStatus attemptedStatus;

  /// When this device believed it was recording it — the value the server
  /// compared against its own `recorded_at` and found older.
  final DateTime attemptedRecordedAtClient;

  /// What the server holds instead, when it told us.
  final AttendanceStatus? serverStatus;

  /// When the winning record was written, server-side.
  final DateTime? serverRecordedAt;

  /// Who wrote the winning record, when the server named them.
  final String? serverRecordedByName;
}

/// A whole attendance sheet for one session.
class AttendanceSheet {
  const AttendanceSheet({
    required this.sessionId,
    required this.groupId,
    required this.entries,
    this.groupName,
    this.isFromCache = false,
  });

  /// `session.id`.
  final String sessionId;

  /// `session.group_id`.
  final String groupId;

  /// The group's name, for the app bar.
  final String? groupName;

  /// One row per child currently in the group, in the server's order.
  final List<AttendanceEntry> entries;

  /// Whether this came off the device rather than the network.
  final bool isFromCache;

  /// Whether the group has nobody in it — the empty state.
  bool get isEmpty => entries.isEmpty;

  /// Guardians who answered "yes" or "late".
  int get confirmedCount => entries
      .where(
        (entry) =>
            entry.presenceAnswer == PresenceAnswerValue.yes ||
            entry.presenceAnswer == PresenceAnswerValue.late,
      )
      .length;

  /// Guardians who declared the child absent in advance (`ATT-04`).
  int get declaredAbsentCount => entries
      .where((entry) => entry.presenceAnswer == PresenceAnswerValue.no)
      .length;

  /// Guardians who did not answer at all.
  ///
  /// The number an educator actually acts on: these are the children whose
  /// whereabouts nobody has confirmed.
  int get noAnswerCount =>
      entries.where((entry) => entry.presenceAnswer == null).length;

  /// Rows carrying an un-synced mark.
  int get pendingCount => entries.where((entry) => entry.isPending).length;

  /// Rows whose mark was refused and needs a decision.
  List<AttendanceEntry> get conflicts =>
      entries.where((entry) => entry.hasConflict).toList(growable: false);

  /// Rows with no status at all yet — the ones "mark remaining present" fills.
  List<AttendanceEntry> get unmarked =>
      entries.where((entry) => entry.isUnmarked).toList(growable: false);

  /// Returns a copy with [entry] replacing the row for the same child.
  AttendanceSheet withEntry(AttendanceEntry entry) => AttendanceSheet(
    sessionId: sessionId,
    groupId: groupId,
    groupName: groupName,
    isFromCache: isFromCache,
    entries: [
      for (final existing in entries)
        if (existing.childId == entry.childId) entry else existing,
    ],
  );
}
