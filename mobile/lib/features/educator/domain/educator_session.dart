/// Sessions as the educator works them (EDU-M-01, 02, 04, 05).
library;

import 'package:meta/meta.dart';

import '../../children/domain/session_kind.dart';
import '../../executive/domain/executive_group.dart' show SessionStatus;

export '../../children/domain/session_kind.dart';
export '../../executive/domain/executive_group.dart' show SessionStatus;

/// A named group, as sessions carry it.
@immutable
class SessionGroupRef {
  const SessionGroupRef({required this.id, required this.name});

  final String id;
  final String name;
}

/// One session in a list: the week view, Today, a group's sessions.
@immutable
class SessionItem {
  const SessionItem({
    required this.id,
    required this.group,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.isCustomized,
    required this.hasContent,
    required this.materialCount,
    required this.homeworkCount,
    required this.attendanceRecorded,
    required this.summarySent,
    this.title,
    this.theme,
    this.place,
    this.rescheduledFrom,
    this.coEducatorNames = const [],
    this.kind = SessionKind.session,
  });

  final String id;
  final SessionGroupRef group;
  final String? title;
  final String? theme;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? place;
  final SessionStatus status;

  /// True once an educator touched it — protects it from regeneration.
  final bool isCustomized;

  /// Whether anyone gave it a title or objectives yet.
  final bool hasContent;
  final int materialCount;
  final int homeworkCount;
  final bool attendanceRecorded;
  final bool summarySent;

  /// The slot it moved away from, when it was rescheduled.
  final DateTime? rescheduledFrom;

  /// Everyone leading the group, the caller included.
  final List<String> coEducatorNames;

  /// The weekly حصة, or an activity added by hand.
  final SessionKind kind;

  bool get isCancelled => status == SessionStatus.cancelled;

  /// How the row reads at [now] — the chip on every session list.
  SessionState stateAt(DateTime now) {
    if (isCancelled) return SessionState.cancelled;
    if (rescheduledFrom != null && startsAt.isAfter(now)) {
      return SessionState.rescheduled;
    }
    if (endsAt.isBefore(now)) return SessionState.ended;
    if (!hasContent) return SessionState.noContent;
    if (startsAt.difference(now) <= const Duration(minutes: 60) &&
        startsAt.isAfter(now)) {
      return SessionState.soon;
    }
    if (!startsAt.isAfter(now)) return SessionState.live;
    return SessionState.upcoming;
  }
}

enum SessionState {
  ended,
  live,
  soon,
  upcoming,
  noContent,
  cancelled,
  rescheduled,
}

enum MaterialKind { document, image, audio, video, link }

enum MaterialVisibility { beforeSession, afterSession, staffOnly }

@immutable
class SessionMaterial {
  const SessionMaterial({
    required this.id,
    required this.kind,
    required this.storageKey,
    required this.visibility,
    this.title,
    this.url,
    this.sizeBytes,
  });

  final String id;
  final MaterialKind kind;
  final String? title;
  final String storageKey;
  final String? url;
  final MaterialVisibility visibility;
  final int? sizeBytes;

  SessionMaterial withVisibility(MaterialVisibility visibility) =>
      SessionMaterial(
        id: id,
        kind: kind,
        storageKey: storageKey,
        visibility: visibility,
        title: title,
        url: url,
        sizeBytes: sizeBytes,
      );
}

/// Homework, with the self-reported done count (`HWK-03`).
@immutable
class HomeworkItem {
  const HomeworkItem({
    required this.id,
    required this.sessionId,
    required this.instructions,
    required this.dueAt,
    required this.targetCount,
    required this.doneCount,
    required this.createdAt,
    this.title,
    this.targetChildIds,
    this.attachmentUrl,
    this.sessionStartsAt,
  });

  final String id;
  final String sessionId;
  final String? title;
  final String instructions;
  final DateTime dueAt;

  /// Null = the whole group.
  final List<String>? targetChildIds;
  final int targetCount;
  final int doneCount;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? sessionStartsAt;

  bool get isWholeGroup => targetChildIds == null;
  bool isOpenAt(DateTime now) => !dueAt.isBefore(now);
  double get doneShare => targetCount == 0 ? 0 : doneCount / targetCount;
}

/// What the guardians answered.
@immutable
class PresenceTallies {
  const PresenceTallies({
    required this.yes,
    required this.late,
    required this.no,
    required this.none,
    this.sent = true,
  });

  static const PresenceTallies empty = PresenceTallies(
    yes: 0,
    late: 0,
    no: 0,
    none: 0,
    sent: false,
  );

  final int yes;
  final int late;
  final int no;
  final int none;

  /// Whether a confirmation was sent at all.
  final bool sent;

  int get expected => yes + late;
  int get total => yes + late + no + none;
}

@immutable
class SessionAttendanceCounts {
  const SessionAttendanceCounts({
    required this.recorded,
    required this.present,
    required this.late,
    required this.excused,
    required this.absent,
  });

  static const SessionAttendanceCounts none = SessionAttendanceCounts(
    recorded: false,
    present: 0,
    late: 0,
    excused: 0,
    absent: 0,
  );

  final bool recorded;
  final int present;
  final int late;
  final int excused;
  final int absent;
}

/// One session in full.
@immutable
class SessionDetail {
  const SessionDetail({
    required this.item,
    required this.enrolledCount,
    required this.guardianCount,
    required this.familyCount,
    required this.materials,
    required this.homework,
    required this.attendance,
    this.objectives,
    this.cancelReason,
    this.changedByName,
    this.presence,
    this.summary,
    this.summarySentAt,
  });

  final SessionItem item;
  final String? objectives;
  final String? cancelReason;
  final String? changedByName;
  final int enrolledCount;
  final int guardianCount;
  final int familyCount;
  final List<SessionMaterial> materials;
  final List<HomeworkItem> homework;
  final SessionAttendanceCounts attendance;
  final PresenceTallies? presence;
  final String? summary;
  final DateTime? summarySentAt;

  String get id => item.id;
}

enum PresenceAnswerKind { none, no, late, yes }

@immutable
class PresenceChild {
  const PresenceChild({required this.id, required this.fullName, this.reason});

  final String id;
  final String fullName;
  final String? reason;
}

@immutable
class PresenceGroup {
  const PresenceGroup({required this.answer, required this.children});

  final PresenceAnswerKind answer;
  final List<PresenceChild> children;
}

/// EDU-M-02: who is coming, who declined and why, who never answered.
@immutable
class PresenceOverview {
  const PresenceOverview({
    required this.sessionId,
    required this.enrolledCount,
    required this.tallies,
    required this.groups,
    this.sentAt,
    this.deadlineAt,
    this.reminderSentAt,
  });

  final String sessionId;
  final DateTime? sentAt;
  final DateTime? deadlineAt;
  final DateTime? reminderSentAt;
  final int enrolledCount;
  final PresenceTallies tallies;
  final List<PresenceGroup> groups;

  bool get wasSent => sentAt != null;
  bool get reminderSent => reminderSentAt != null;
}

/// The Today card's session, with what Today needs beside it.
@immutable
class NextSession {
  const NextSession({
    required this.item,
    required this.enrolledCount,
    required this.attendance,
    this.presence,
  });

  final SessionItem item;
  final int enrolledCount;
  final PresenceTallies? presence;
  final SessionAttendanceCounts attendance;
}

/// The pinned notice from management, with the caller's acknowledgement.
@immutable
class PinnedNotice {
  const PinnedNotice({
    required this.id,
    required this.title,
    required this.ackRequired,
    required this.confirmed,
    this.body,
  });

  final String id;
  final String title;
  final String? body;
  final bool ackRequired;
  final bool confirmed;

  PinnedNotice confirmedNow() => PinnedNotice(
    id: id,
    title: title,
    body: body,
    ackRequired: ackRequired,
    confirmed: true,
  );
}

/// EDU-M-01.
@immutable
class TodayView {
  const TodayView({
    required this.date,
    required this.todaySessions,
    required this.sessionsWithoutContent,
    this.nextSession,
    this.pinnedNotice,
  });

  final DateTime date;
  final NextSession? nextSession;
  final List<SessionItem> todaySessions;
  final List<SessionItem> sessionsWithoutContent;
  final PinnedNotice? pinnedNotice;

  TodayView withNotice(PinnedNotice? notice) => TodayView(
    date: date,
    nextSession: nextSession,
    todaySessions: todaySessions,
    sessionsWithoutContent: sessionsWithoutContent,
    pinnedNotice: notice,
  );
}

// --- Drafts -----------------------------------------------------------------

/// What the content screen edits.
@immutable
class SessionContentDraft {
  const SessionContentDraft({
    this.title = '',
    this.theme,
    this.objectives = '',
    this.visibility = const {},
  });

  factory SessionContentDraft.fromDetail(SessionDetail detail) =>
      SessionContentDraft(
        title: detail.item.title ?? '',
        theme: detail.item.theme,
        objectives: detail.objectives ?? '',
        visibility: {
          for (final material in detail.materials)
            material.id: material.visibility,
        },
      );

  final String title;
  final String? theme;
  final String objectives;

  /// Material id → the visibility chosen on screen.
  final Map<String, MaterialVisibility> visibility;

  SessionContentDraft copyWith({
    String? title,
    String? theme,
    String? objectives,
    Map<String, MaterialVisibility>? visibility,
  }) => SessionContentDraft(
    title: title ?? this.title,
    theme: theme ?? this.theme,
    objectives: objectives ?? this.objectives,
    visibility: visibility ?? this.visibility,
  );
}

enum CancelMode { cancel, reschedule }

@immutable
class CancelDraft {
  const CancelDraft({
    this.mode = CancelMode.cancel,
    this.reason = '',
    this.startsAt,
    this.endsAt,
    this.place,
  });

  final CancelMode mode;
  final String reason;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? place;

  bool get isComplete =>
      reason.trim().isNotEmpty &&
      (mode == CancelMode.cancel || (startsAt != null && endsAt != null));

  CancelDraft copyWith({
    CancelMode? mode,
    String? reason,
    DateTime? startsAt,
    DateTime? endsAt,
    String? place,
  }) => CancelDraft(
    mode: mode ?? this.mode,
    reason: reason ?? this.reason,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    place: place ?? this.place,
  );
}

@immutable
class HomeworkDraft {
  const HomeworkDraft({
    this.title = '',
    this.instructions = '',
    this.dueAt,
    this.targetChildIds,
    this.attachmentKey,
  });

  final String title;
  final String instructions;
  final DateTime? dueAt;

  /// Null = the whole group; an empty set = "specific" with nobody picked yet.
  final Set<String>? targetChildIds;
  final String? attachmentKey;

  bool get isWholeGroup => targetChildIds == null;
  bool get isComplete =>
      instructions.trim().isNotEmpty &&
      dueAt != null &&
      (targetChildIds == null || targetChildIds!.isNotEmpty);

  HomeworkDraft copyWith({
    String? title,
    String? instructions,
    DateTime? dueAt,
    Set<String>? targetChildIds,
    bool wholeGroup = false,
    String? attachmentKey,
  }) => HomeworkDraft(
    title: title ?? this.title,
    instructions: instructions ?? this.instructions,
    dueAt: dueAt ?? this.dueAt,
    targetChildIds: wholeGroup ? null : (targetChildIds ?? this.targetChildIds),
    attachmentKey: attachmentKey ?? this.attachmentKey,
  );
}

/// The three ways a material can be seen (`MAT-01`).
extension MaterialVisibilityWire on MaterialVisibility {
  String get wireValue => switch (this) {
    MaterialVisibility.beforeSession => 'before_session',
    MaterialVisibility.afterSession => 'after_session',
    MaterialVisibility.staffOnly => 'staff_only',
  };
}

extension MaterialKindWire on MaterialKind {
  String get wireValue => name;
}

/// An activity the educator is adding for one of their groups (EDU-M-03).
@immutable
class ActivityDraft {
  const ActivityDraft({
    this.groupId,
    this.kind = SessionKind.sport,
    this.day,
    this.startsAt = '16:00',
    this.endsAt = '18:00',
    this.title = '',
    this.place = '',
    this.objectives = '',
  });

  final String? groupId;
  final SessionKind kind;

  /// The date; the times are "HH:mm" on it.
  final DateTime? day;
  final String startsAt;
  final String endsAt;
  final String title;
  final String place;
  final String objectives;

  bool get isComplete =>
      groupId != null &&
      day != null &&
      endsAt.compareTo(startsAt) > 0 &&
      title.trim().length >= 2;

  DateTime? get startsAtDateTime => _at(startsAt);
  DateTime? get endsAtDateTime => _at(endsAt);

  DateTime? _at(String hhmm) {
    final day = this.day;
    if (day == null) return null;
    final parts = hhmm.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.tryParse(parts.first) ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  ActivityDraft copyWith({
    String? groupId,
    SessionKind? kind,
    DateTime? day,
    String? startsAt,
    String? endsAt,
    String? title,
    String? place,
    String? objectives,
  }) => ActivityDraft(
    groupId: groupId ?? this.groupId,
    kind: kind ?? this.kind,
    day: day ?? this.day,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    title: title ?? this.title,
    place: place ?? this.place,
    objectives: objectives ?? this.objectives,
  );
}
