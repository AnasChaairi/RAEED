import 'educator_group.dart';
import 'educator_session.dart';

/// Sessions, their content, homework and rosters (EDU-M-02, 04, 05, 06).
abstract interface class SessionsRepository {
  /// Sessions in [from, to); the server generates missing ones first.
  Future<List<SessionItem>> fetchSessions({
    required DateTime from,
    required DateTime to,
    String? groupId,
  });

  Future<SessionDetail> fetchSession(String sessionId);

  /// Adds an activity for one of the caller's groups; the group's guardians
  /// are told and it appears on the child's schedule.
  Future<SessionDetail> createActivity(ActivityDraft draft);

  Future<SessionDetail> updateContent(
    String sessionId,
    SessionContentDraft draft,
  );

  Future<SessionMaterial> addMaterial(
    String sessionId, {
    required MaterialKind kind,
    required String storageKey,
    String? title,
    MaterialVisibility visibility = MaterialVisibility.afterSession,
    int? sizeBytes,
  });

  Future<void> removeMaterial(String materialId);

  /// Cancels or moves; returns how many people were told.
  Future<({int notifiedCount, int guardianCount})> changeSession(
    String sessionId,
    CancelDraft draft,
  );

  /// Sends the summary once; `session.summary_already_sent` on a second try.
  Future<({DateTime sentAt, int familyCount})> sendSummary(
    String sessionId, {
    required String body,
    List<String> mediaKeys = const [],
  });

  Future<PresenceOverview> fetchPresence(String sessionId);

  /// One reminder; `presence.reminder_already_sent` on a second try.
  Future<int> remindUnanswered(String sessionId);

  Future<HomeworkItem> createHomework(String sessionId, HomeworkDraft draft);

  Future<List<HomeworkItem>> fetchGroupHomework(String groupId);

  Future<List<RosterChild>> fetchRoster(String groupId);
}
