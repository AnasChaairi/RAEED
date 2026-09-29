/// Wire → domain for the educator surface (EDU-M-01..10).
library;

import '../../../core/network/api_envelope.dart';
import '../../executive/data/executive_child_dto.dart' show imageRightsFromWire;
import '../../executive/data/wire_helpers.dart';
import '../domain/availability.dart';
import '../domain/educator_child.dart';
import '../domain/educator_group.dart';
import '../domain/educator_session.dart';
import '../domain/memory_post.dart';

const Map<String, SessionStatus> _sessionStatusByWire = {
  'planned': SessionStatus.planned,
  'delivered': SessionStatus.delivered,
  'cancelled': SessionStatus.cancelled,
};

const Map<String, MaterialKind> _materialKindByWire = {
  'document': MaterialKind.document,
  'image': MaterialKind.image,
  'audio': MaterialKind.audio,
  'video': MaterialKind.video,
  'link': MaterialKind.link,
};

const Map<String, MaterialVisibility> _visibilityByWire = {
  'before_session': MaterialVisibility.beforeSession,
  'after_session': MaterialVisibility.afterSession,
  'staff_only': MaterialVisibility.staffOnly,
};

const Map<String, PresenceAnswerKind> _answerByWire = {
  'none': PresenceAnswerKind.none,
  'no': PresenceAnswerKind.no,
  'late': PresenceAnswerKind.late,
  'yes': PresenceAnswerKind.yes,
};

const Map<String, PostState> _postStateByWire = {
  'pending': PostState.pending,
  'published': PostState.published,
  'edit_requested': PostState.editRequested,
};

const Map<String, MediaKind> _mediaKindByWire = {
  'image': MediaKind.image,
  'audio': MediaKind.audio,
  'video': MediaKind.video,
  'document': MediaKind.document,
};

SessionItem sessionItemFromJson(Map<String, Object?> json) {
  final group = objectOrNull(json['group']);
  return SessionItem(
    id: requireField<String>(json, 'id'),
    group: SessionGroupRef(
      id: stringOrNull(group?['id']) ?? stringOrNull(json['group_id']) ?? '',
      name:
          stringOrNull(group?['name']) ??
          stringOrNull(json['group_name']) ??
          '',
    ),
    title: stringOrNull(json['title']),
    theme: stringOrNull(json['theme']),
    startsAt: requireDateTime(json, 'starts_at'),
    endsAt: requireDateTime(json, 'ends_at'),
    place: stringOrNull(json['place']),
    status: enumFromWire(
      json['status'],
      _sessionStatusByWire,
      fallback: SessionStatus.planned,
    ),
    isCustomized: boolOr(json['is_customized'], false),
    hasContent: boolOr(
      json['has_content'],
      stringOrNull(json['title']) != null,
    ),
    materialCount: intOrNull(json['material_count']) ?? 0,
    homeworkCount: intOrNull(json['homework_count']) ?? 0,
    attendanceRecorded: boolOr(json['attendance_recorded'], false),
    summarySent: boolOr(json['summary_sent'], false),
    rescheduledFrom: dateOrNull(json['rescheduled_from']),
    coEducatorNames: stringList(json['co_educator_names']),
    kind: SessionKind.fromWire(stringOrNull(json['kind'])),
  );
}

/// The `POST /sessions` body.
Map<String, Object?> activityDraftToJson(ActivityDraft draft) => {
  'group_id': draft.groupId,
  'kind': draft.kind.wireValue,
  'starts_at': draft.startsAtDateTime!.toUtc().toIso8601String(),
  'ends_at': draft.endsAtDateTime!.toUtc().toIso8601String(),
  'title': draft.title.trim(),
  if (draft.place.trim().isNotEmpty) 'place': draft.place.trim(),
  if (draft.objectives.trim().isNotEmpty) 'objectives': draft.objectives.trim(),
};

SessionMaterial materialFromJson(Map<String, Object?> json) => SessionMaterial(
  id: requireField<String>(json, 'id'),
  kind: enumFromWire(
    json['kind'],
    _materialKindByWire,
    fallback: MaterialKind.document,
  ),
  title: stringOrNull(json['title']),
  storageKey: stringOrNull(json['storage_key']) ?? '',
  url: stringOrNull(json['url']),
  visibility: enumFromWire(
    json['visibility'],
    _visibilityByWire,
    fallback: MaterialVisibility.afterSession,
  ),
  sizeBytes: intOrNull(json['size_bytes']),
);

HomeworkItem homeworkFromJson(Map<String, Object?> json) {
  final targets = json['target_child_ids'];
  return HomeworkItem(
    id: requireField<String>(json, 'id'),
    sessionId: stringOrNull(json['session_id']) ?? '',
    title: stringOrNull(json['title']),
    instructions: stringOrNull(json['instructions']) ?? '',
    dueAt: requireDateTime(json, 'due_at'),
    targetChildIds: targets is List ? stringList(targets) : null,
    targetCount: intOrNull(json['target_count']) ?? 0,
    doneCount: intOrNull(json['done_count']) ?? 0,
    attachmentUrl: stringOrNull(json['attachment_url']),
    createdAt: dateOrNull(json['created_at']) ?? DateTime.now(),
    sessionStartsAt: dateOrNull(json['session_starts_at']),
  );
}

PresenceTallies? talliesOrNull(Map<String, Object?>? json) => json == null
    ? null
    : PresenceTallies(
        yes: intOrNull(json['yes']) ?? 0,
        late: intOrNull(json['late']) ?? 0,
        no: intOrNull(json['no']) ?? 0,
        none: intOrNull(json['none']) ?? 0,
        sent: boolOr(json['sent'], true),
      );

SessionAttendanceCounts attendanceCountsFromJson(Map<String, Object?>? json) =>
    json == null
    ? SessionAttendanceCounts.none
    : SessionAttendanceCounts(
        recorded: boolOr(json['recorded'], false),
        present: intOrNull(json['present']) ?? 0,
        late: intOrNull(json['late']) ?? 0,
        excused: intOrNull(json['excused']) ?? 0,
        absent: intOrNull(json['absent']) ?? 0,
      );

SessionDetail sessionDetailFromJson(Map<String, Object?> json) {
  final summary = objectOrNull(json['summary']);
  return SessionDetail(
    item: sessionItemFromJson(json),
    objectives: stringOrNull(json['objectives']),
    cancelReason: stringOrNull(json['cancel_reason']),
    changedByName: stringOrNull(json['changed_by_name']),
    enrolledCount: intOrNull(json['enrolled_count']) ?? 0,
    guardianCount: intOrNull(json['guardian_count']) ?? 0,
    familyCount: intOrNull(json['family_count']) ?? 0,
    materials: [
      for (final material in objectList(json['materials'], field: 'materials'))
        materialFromJson(material),
    ],
    homework: [
      for (final homework in objectList(json['homework'], field: 'homework'))
        homeworkFromJson(homework),
    ],
    attendance: attendanceCountsFromJson(objectOrNull(json['attendance'])),
    presence: talliesOrNull(objectOrNull(json['presence'])),
    summary: stringOrNull(summary?['body']),
    summarySentAt: dateOrNull(summary?['sent_at']),
  );
}

PresenceOverview presenceOverviewFromJson(Map<String, Object?> json) =>
    PresenceOverview(
      sessionId: requireField<String>(json, 'session_id'),
      sentAt: dateOrNull(json['sent_at']),
      deadlineAt: dateOrNull(json['deadline_at']),
      reminderSentAt: dateOrNull(json['reminder_sent_at']),
      enrolledCount: intOrNull(json['enrolled_count']) ?? 0,
      tallies:
          talliesOrNull(objectOrNull(json['tallies'])) ?? PresenceTallies.empty,
      groups: [
        for (final group in objectList(json['groups'], field: 'groups'))
          PresenceGroup(
            answer: enumFromWire(
              group['answer'],
              _answerByWire,
              fallback: PresenceAnswerKind.none,
            ),
            children: [
              for (final child in objectList(
                group['children'],
                field: 'children',
              ))
                PresenceChild(
                  id: stringOrNull(child['id']) ?? '',
                  fullName: stringOrNull(child['full_name']) ?? '',
                  reason: stringOrNull(child['reason']),
                ),
            ],
          ),
      ],
    );

TodayView todayFromJson(Map<String, Object?> json) {
  final next = objectOrNull(json['next_session']);
  final notice = objectOrNull(json['pinned_announcement']);
  return TodayView(
    date: dateOrNull(json['date']) ?? DateTime.now(),
    nextSession: next == null
        ? null
        : NextSession(
            item: sessionItemFromJson(next),
            enrolledCount: intOrNull(next['enrolled_count']) ?? 0,
            presence: talliesOrNull(objectOrNull(next['presence'])),
            attendance: attendanceCountsFromJson(
              objectOrNull(next['attendance']),
            ),
          ),
    todaySessions: [
      for (final item in objectList(
        json['today_sessions'],
        field: 'today_sessions',
      ))
        sessionItemFromJson(item),
    ],
    sessionsWithoutContent: [
      for (final item in objectList(
        json['sessions_without_content'],
        field: 'sessions_without_content',
      ))
        sessionItemFromJson(item),
    ],
    pinnedNotice: notice == null
        ? null
        : PinnedNotice(
            id: stringOrNull(notice['id']) ?? '',
            title: stringOrNull(notice['title']) ?? '',
            body: stringOrNull(notice['body']),
            ackRequired: boolOr(notice['ack_required'], false),
            confirmed: boolOr(notice['confirmed'], false),
          ),
  );
}

RosterChild rosterChildFromJson(Map<String, Object?> json) {
  final attendance = objectOrNull(json['attendance']);
  return RosterChild(
    id: requireField<String>(json, 'id'),
    fullName: requireField<String>(json, 'full_name'),
    photoUrl: stringOrNull(json['photo_url']),
    hasHealthAlert: boolOr(json['health_alert'], false),
    imageRights: imageRightsFromWire(json['image_rights_level']),
    present: intOrNull(attendance?['present']) ?? 0,
    expected: intOrNull(attendance?['expected']) ?? 0,
    consecutiveAbsences: intOrNull(json['consecutive_absences']) ?? 0,
    isNew: boolOr(json['is_new'], false),
  );
}

EducatorChildProfile educatorChildFromJson(Map<String, Object?> json) {
  final group = objectOrNull(json['group']);
  final attendance = objectOrNull(json['season_attendance']);
  final homework = objectOrNull(json['homework']);
  return EducatorChildProfile(
    id: requireField<String>(json, 'id'),
    fullName: requireField<String>(json, 'full_name'),
    dateOfBirth: dateOrNull(json['dob']),
    schoolLevel: stringOrNull(json['school_level']),
    group: group == null
        ? null
        : ChildGroupRef(
            id: stringOrNull(group['id']) ?? '',
            name: stringOrNull(group['name']) ?? '',
          ),
    hasHealthAlert: boolOr(json['health_alert'], false),
    imageRights: imageRightsFromWire(json['image_rights_level']),
    seasonAttendance: attendance == null
        ? null
        : AttendanceRatio(
            present: intOrNull(attendance['present']) ?? 0,
            expected: intOrNull(attendance['expected']) ?? 0,
          ),
    homeworkDone: intOrNull(homework?['done']) ?? 0,
    homeworkTotal: intOrNull(homework?['total']) ?? 0,
    guardians: [
      for (final guardian in objectList(json['guardians'], field: 'guardians'))
        EducatorGuardian(
          id: stringOrNull(guardian['id']) ?? '',
          displayName: stringOrNull(guardian['display_name']) ?? '',
          relationship: stringOrNull(guardian['relationship']) ?? '',
          account: stringOrNull(guardian['account']) == 'active'
              ? AccountStatus.active
              : AccountStatus.pending,
          isEmergencyContact: boolOr(guardian['is_emergency_contact'], false),
        ),
    ],
    conversationId: stringOrNull(json['conversation_id']),
  );
}

EmergencyCall emergencyCallFromJson(Map<String, Object?> json) => EmergencyCall(
  guardianName: stringOrNull(json['display_name']) ?? '',
  phone: stringOrNull(json['phone']),
  recordedAt: dateOrNull(json['recorded_at']) ?? DateTime.now(),
);

MyPost myPostFromJson(Map<String, Object?> json) {
  final album = objectOrNull(json['album']);
  return MyPost(
    id: requireField<String>(json, 'id'),
    albumTitle: stringOrNull(album?['title']) ?? '',
    albumGroupName: stringOrNull(album?['group_name']),
    caption: stringOrNull(json['caption']),
    mediaCount: intOrNull(json['media_count']) ?? 1,
    thumbnailUrl: stringOrNull(json['thumbnail_url']),
    tagCount: intOrNull(json['tag_count']) ?? 0,
    createdAt: dateOrNull(json['created_at']) ?? DateTime.now(),
    state: enumFromWire(
      json['state'],
      _postStateByWire,
      fallback: PostState.pending,
    ),
  );
}

MediaUpload mediaUploadFromJson(Map<String, Object?> json) => MediaUpload(
  storageKey: requireField<String>(json, 'storage_key'),
  url: stringOrNull(json['url']) ?? '',
  kind: enumFromWire(
    json['kind'],
    _mediaKindByWire,
    fallback: MediaKind.document,
  ),
  name: stringOrNull(json['name']) ?? '',
  sizeBytes: intOrNull(json['size_bytes']) ?? 0,
);

AvailabilityWindow? availabilityOrNull(Object? value) {
  final json = objectOrNull(value);
  final start = stringOrNull(json?['start']);
  final end = stringOrNull(json?['end']);
  return start == null || end == null
      ? null
      : AvailabilityWindow(start: start, end: end);
}
