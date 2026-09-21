import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/raeed_exception.dart';
import '../../../core/network/api_client_provider.dart';
import '../../children/domain/child.dart';
import '../../children/presentation/home_providers.dart';
import '../application/executive_tab_badges.dart';
import '../application/order_alerts.dart';
import '../data/attendance_review_repository_api.dart';
import '../data/dashboard_repository_api.dart';
import '../data/executive_announcements_repository_api.dart';
import '../data/groups_repository_api.dart';
import '../data/memories_review_repository_api.dart';
import '../data/messages_repository_api.dart';
import '../data/notifications_repository_api.dart';
import '../domain/announcement_draft.dart';
import '../domain/attendance_review.dart';
import '../domain/attendance_review_repository.dart';
import '../domain/conversation.dart';
import '../domain/dashboard_overview.dart';
import '../domain/dashboard_repository.dart';
import '../domain/executive_announcements_repository.dart';
import '../domain/executive_group.dart';
import '../domain/groups_repository.dart';
import '../domain/memories_review.dart';
import '../domain/memories_review_repository.dart';
import '../domain/messages_repository.dart';
import '../domain/notification_item.dart';
import '../domain/notifications_repository.dart';

part 'executive_providers.g.dart';

// --- Repositories ----------------------------------------------------------

@Riverpod(keepAlive: true)
DashboardRepository dashboardRepository(Ref ref) =>
    ApiDashboardRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
DashboardSnapshotCache dashboardSnapshotCache(Ref ref) =>
    DashboardSnapshotCache();

@Riverpod(keepAlive: true)
GroupsRepository groupsRepository(Ref ref) =>
    ApiGroupsRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
ExecutiveAnnouncementsRepository executiveAnnouncementsRepository(Ref ref) =>
    ApiExecutiveAnnouncementsRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
MessagesRepository messagesRepository(Ref ref) =>
    ApiMessagesRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
MemoriesReviewRepository memoriesReviewRepository(Ref ref) =>
    ApiMemoriesReviewRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) =>
    ApiNotificationsRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AttendanceReviewRepository attendanceReviewRepository(Ref ref) =>
    ApiAttendanceReviewRepository(ref.watch(apiClientProvider));

// --- The shell --------------------------------------------------------------

/// The five tabs of the executive shell, in nav order.
enum ExecutiveTab {
  dashboard('dashboard'),
  announcements('announcements'),
  messages('messages'),
  memories('memories'),
  groups('groups');

  const ExecutiveTab(this.slug);

  /// The `?tab=` value.
  final String slug;

  static ExecutiveTab? fromSlug(String? slug) {
    for (final tab in ExecutiveTab.values) {
      if (tab.slug == slug) return tab;
    }
    return null;
  }

  /// Where an alert's destination lands.
  static ExecutiveTab? forDestination(AlertDestination destination) =>
      switch (destination) {
        AlertDestination.groups => ExecutiveTab.groups,
        AlertDestination.memories => ExecutiveTab.memories,
        AlertDestination.messages => ExecutiveTab.messages,
        AlertDestination.announcements => ExecutiveTab.announcements,
        AlertDestination.notifications => null,
      };
}

/// Which tab the shell shows.
///
/// Held outside the shell widget so an alert card, a push, or a deep link
/// can select a tab without rebuilding the shell from a new route.
@Riverpod(keepAlive: true)
class ExecutiveTabController extends _$ExecutiveTabController {
  @override
  ExecutiveTab build() => ExecutiveTab.dashboard;

  void select(ExecutiveTab tab) => state = tab;
}

// --- Dashboard --------------------------------------------------------------

/// Why the dashboard is showing an older overview.
enum DashboardStaleness { offline, refreshFailed }

/// What the dashboard shows, and whether it is fresh.
class DashboardState {
  const DashboardState({required this.overview, this.staleness});

  final DashboardOverview overview;
  final DashboardStaleness? staleness;

  bool get isStale => staleness != null;

  /// Alerts in scan order — see `orderAlerts`.
  List<DashboardAlert> get alerts => orderAlerts(overview.alerts);
}

/// Loads the overview, falling back to the last good one rather than an
/// error — the executive checking "is anything wrong" on a weak connection
/// wants the answer from ten minutes ago, clearly dated, not a retry button.
@riverpod
class DashboardController extends _$DashboardController {
  @override
  Future<DashboardState> build() => _load();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<DashboardState> _load() async {
    final cache = ref.read(dashboardSnapshotCacheProvider);
    try {
      final overview = await ref
          .read(dashboardRepositoryProvider)
          .fetchOverview();
      cache.save(overview);
      return DashboardState(overview: overview);
    } on RaeedException catch (error) {
      final cached = cache.snapshot;
      if (cached == null) rethrow;
      return DashboardState(
        overview: cached,
        staleness: error is NetworkException
            ? DashboardStaleness.offline
            : DashboardStaleness.refreshFailed,
      );
    }
  }
}

// --- Announcements ----------------------------------------------------------

@riverpod
class AnnouncementsController extends _$AnnouncementsController {
  @override
  Future<List<ExecutiveAnnouncement>> build() async {
    final page = await ref
        .read(executiveAnnouncementsRepositoryProvider)
        .fetchAnnouncements();
    return page.items;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final page = await ref
          .read(executiveAnnouncementsRepositoryProvider)
          .fetchAnnouncements();
      return page.items;
    });
  }
}

/// How many people each audience reaches.
@riverpod
Future<AudienceReach> audienceReach(Ref ref) =>
    ref.watch(executiveAnnouncementsRepositoryProvider).fetchReach();

/// Publishes a draft and refreshes the list.
@riverpod
Future<String> Function(AnnouncementDraft draft) publishAnnouncement(Ref ref) =>
    (draft) async {
      final id = await ref
          .read(executiveAnnouncementsRepositoryProvider)
          .publish(draft);
      ref.invalidate(announcementsControllerProvider);
      return id;
    };

// --- Messages ---------------------------------------------------------------

@riverpod
class ConversationsController extends _$ConversationsController {
  @override
  Future<List<ConversationSummary>> build() =>
      ref.read(messagesRepositoryProvider).fetchConversations();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(messagesRepositoryProvider).fetchConversations(),
    );
  }
}

/// A thread's header and messages together — the oversight notice in the
/// header must be on screen before a single message is, so they load as one.
class ConversationState {
  const ConversationState({required this.detail, required this.messages});

  final ConversationDetail detail;
  final List<ChatMessage> messages;

  ConversationState withMessages(List<ChatMessage> messages) =>
      ConversationState(detail: detail, messages: messages);
}

@riverpod
class ConversationController extends _$ConversationController {
  @override
  Future<ConversationState> build(String conversationId) async {
    final repository = ref.read(messagesRepositoryProvider);
    final detail = await repository.fetchConversation(conversationId);
    final messages = await repository.fetchMessages(conversationId);
    return ConversationState(detail: detail, messages: messages);
  }

  /// Hides [message]. The bubble becomes the hidden stub immediately and
  /// stays so — hiding is logged and reversible server-side, not a local
  /// filter.
  Future<void> hide(ChatMessage message, {required String byName}) async {
    final current = state.value;
    if (current == null) return;
    await ref.read(messagesRepositoryProvider).hideMessage(message.id);
    state = AsyncData(
      current.withMessages([
        for (final existing in current.messages)
          if (existing.id == message.id)
            existing.hiddenBy(name: byName, at: DateTime.now().toUtc())
          else
            existing,
      ]),
    );
  }

  Future<void> dismissReport(ChatMessage message) async {
    final current = state.value;
    final report = message.report;
    if (current == null || report == null) return;
    await ref.read(messagesRepositoryProvider).dismissReport(report.id);
    state = AsyncData(
      current.withMessages([
        for (final existing in current.messages)
          if (existing.id == message.id) existing.withoutReport() else existing,
      ]),
    );
  }

  Future<void> send(String body) async {
    final current = state.value;
    if (current == null || body.trim().isEmpty) return;
    final sent = await ref
        .read(messagesRepositoryProvider)
        .sendText(conversationId, body);
    state = AsyncData(current.withMessages([...current.messages, sent]));
  }
}

// --- Memories review ----------------------------------------------------------

@riverpod
class ReviewQueueController extends _$ReviewQueueController {
  @override
  Future<ReviewQueue> build() =>
      ref.read(memoriesReviewRepositoryProvider).fetchQueue();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(memoriesReviewRepositoryProvider).fetchQueue(),
    );
  }

  Future<void> approve(ReviewPost post) async {
    await ref.read(memoriesReviewRepositoryProvider).approve(post.id);
    _advancePast(post);
  }

  Future<void> hide(ReviewPost post) async {
    await ref.read(memoriesReviewRepositoryProvider).hide(post.id);
    _advancePast(post);
  }

  void _advancePast(ReviewPost post) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.without(post.id));
  }
}

@riverpod
Future<List<MemoriesAlbum>> memoriesAlbums(Ref ref) =>
    ref.watch(memoriesReviewRepositoryProvider).fetchAlbums();

// --- Groups -------------------------------------------------------------------

@riverpod
Future<List<ExecutiveGroup>> executiveGroups(Ref ref) =>
    ref.watch(groupsRepositoryProvider).fetchGroups();

@riverpod
Future<ExecutiveGroup> executiveGroup(Ref ref, String groupId) =>
    ref.watch(groupsRepositoryProvider).fetchGroup(groupId);

@riverpod
Future<List<GroupSession>> groupSessions(Ref ref, String groupId) =>
    ref.watch(groupsRepositoryProvider).fetchSessions(groupId);

/// The children in a group — `GET /children?group_id=`, already contracted.
@riverpod
Future<List<Child>> groupRoster(Ref ref, String groupId) async {
  final page = await ref
      .watch(childrenRepositoryProvider)
      .fetchChildren(groupId: groupId);
  return page.items;
}

// --- Attendance review --------------------------------------------------------

@riverpod
class AttendanceReviewController extends _$AttendanceReviewController {
  @override
  Future<AttendanceReviewSheet> build(String sessionId, String groupId) => ref
      .read(attendanceReviewRepositoryProvider)
      .fetchSheet(sessionId: sessionId, groupId: groupId);

  /// Saves a correction, then re-reads the sheet so the trail shown is the
  /// server's record of what happened — never a row this device invented.
  Future<void> correct(AttendanceCorrectionDraft draft) async {
    final repository = ref.read(attendanceReviewRepositoryProvider);
    await repository.correct(sessionId: sessionId, draft: draft);
    state = AsyncData(
      await repository.fetchSheet(sessionId: sessionId, groupId: groupId),
    );
  }
}

// --- Notifications ------------------------------------------------------------

@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  Future<List<NotificationItem>> build() =>
      ref.read(notificationsRepositoryProvider).fetchNotifications();

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;
    await ref.read(notificationsRepositoryProvider).markAllRead();
    state = AsyncData([
      for (final item in current)
        NotificationItem(
          id: item.id,
          kind: item.kind,
          title: item.title,
          body: item.body,
          sentAt: item.sentAt,
          isRead: true,
          destination: item.destination,
        ),
    ]);
  }
}

// --- Badges ---------------------------------------------------------------------

/// The bottom-nav badges, from whatever has loaded so far.
///
/// Reads `.value` rather than awaiting: a badge that waited for every tab's
/// data would appear all at once, late, and a failed tab would blank the
/// others. Missing data simply counts as zero.
@riverpod
ExecutiveTabBadges executiveTabBadges(Ref ref) => ExecutiveTabBadges.from(
  overview: ref.watch(dashboardControllerProvider).value?.overview,
  queue: ref.watch(reviewQueueControllerProvider).value,
  conversations: ref.watch(conversationsControllerProvider).value,
);
