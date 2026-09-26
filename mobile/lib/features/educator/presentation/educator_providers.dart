import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client_provider.dart';
import '../../executive/presentation/executive_providers.dart';
import '../data/educator_children_repository_api.dart';
import '../data/educator_memories_repository_api.dart';
import '../data/educator_repository_api.dart';
import '../data/sessions_repository_api.dart';
import '../domain/availability.dart';
import '../domain/educator_child.dart';
import '../domain/educator_children_repository.dart';
import '../domain/educator_group.dart';
import '../domain/educator_memories_repository.dart';
import '../domain/educator_repository.dart';
import '../domain/educator_session.dart';
import '../domain/memory_post.dart';
import '../domain/sessions_repository.dart';

part 'educator_providers.g.dart';

// --- Repositories ----------------------------------------------------------

@Riverpod(keepAlive: true)
EducatorRepository educatorRepository(Ref ref) =>
    ApiEducatorRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
SessionsRepository sessionsRepository(Ref ref) =>
    ApiSessionsRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
EducatorChildrenRepository educatorChildrenRepository(Ref ref) =>
    ApiEducatorChildrenRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
EducatorMemoriesRepository educatorMemoriesRepository(Ref ref) =>
    ApiEducatorMemoriesRepository(ref.watch(apiClientProvider));

// --- The shell --------------------------------------------------------------

enum EducatorTab {
  today('today'),
  sessions('sessions'),
  groups('groups'),
  messages('messages'),
  memories('memories');

  const EducatorTab(this.slug);

  /// The `?tab=` value.
  final String slug;

  static EducatorTab? fromSlug(String? slug) {
    if (slug == null) return null;
    for (final tab in values) {
      if (tab.slug == slug) return tab;
    }
    return null;
  }
}

/// Which tab the educator shell shows, held outside the widget so a card
/// or a deep link can select one without rebuilding the shell.
@Riverpod(keepAlive: true)
class EducatorTabController extends _$EducatorTabController {
  @override
  EducatorTab build() => EducatorTab.today;

  void select(EducatorTab tab) => state = tab;
}

// --- Today -----------------------------------------------------------------

@riverpod
class TodayController extends _$TodayController {
  @override
  Future<TodayView> build() =>
      ref.read(educatorRepositoryProvider).fetchToday();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(educatorRepositoryProvider).fetchToday(),
    );
  }

  /// "I have read this" — flips in place, then tells the server.
  Future<void> confirmRead() async {
    final current = state.value;
    final notice = current?.pinnedNotice;
    if (current == null || notice == null || notice.confirmed) return;
    state = AsyncData(current.withNotice(notice.confirmedNow()));
    await ref.read(educatorRepositoryProvider).confirmRead(notice.id);
  }
}

// --- Sessions ----------------------------------------------------------------

@riverpod
Future<List<SessionItem>> weekSessions(
  Ref ref, {
  required DateTime from,
  required DateTime to,
  String? groupId,
}) => ref
    .watch(sessionsRepositoryProvider)
    .fetchSessions(from: from, to: to, groupId: groupId);

@riverpod
Future<SessionDetail> sessionDetail(Ref ref, String sessionId) =>
    ref.watch(sessionsRepositoryProvider).fetchSession(sessionId);

@riverpod
Future<PresenceOverview> presenceOverview(Ref ref, String sessionId) =>
    ref.watch(sessionsRepositoryProvider).fetchPresence(sessionId);

@riverpod
Future<List<HomeworkItem>> groupHomework(Ref ref, String groupId) =>
    ref.watch(sessionsRepositoryProvider).fetchGroupHomework(groupId);

@riverpod
Future<List<RosterChild>> educatorRoster(Ref ref, String groupId) =>
    ref.watch(sessionsRepositoryProvider).fetchRoster(groupId);

// --- Children, posts, settings --------------------------------------------------

@riverpod
Future<EducatorChildProfile> educatorChildProfile(Ref ref, String childId) =>
    ref.watch(educatorChildrenRepositoryProvider).fetchProfile(childId);

@riverpod
Future<List<MyPost>> myPosts(Ref ref) =>
    ref.watch(educatorMemoriesRepositoryProvider).fetchMyPosts();

@riverpod
class AvailabilityController extends _$AvailabilityController {
  @override
  Future<AvailabilityWindow?> build() =>
      ref.read(educatorRepositoryProvider).fetchAvailability();

  Future<void> set(AvailabilityWindow window) async {
    state = AsyncData(window);
    state = AsyncData(
      await ref.read(educatorRepositoryProvider).setAvailability(window),
    );
  }
}

// --- Badges --------------------------------------------------------------------

/// The bottom-nav badges: sessions still without content, threads with
/// something new. Missing data counts as zero, never as a wait.
@riverpod
({int sessions, int messages}) educatorTabBadges(Ref ref) => (
  sessions:
      ref.watch(todayControllerProvider).value?.sessionsWithoutContent.length ??
      0,
  messages:
      ref
          .watch(conversationsControllerProvider)
          .value
          ?.where((thread) => thread.unreadCount > 0)
          .length ??
      0,
);
