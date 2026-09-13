import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/raeed_exception.dart';
import '../../../core/network/api_client_provider.dart';
import '../../../core/session/session_controller.dart';
import '../application/home_scope.dart';
import '../application/select_pinned_announcements.dart';
import '../data/announcements_repository_api.dart';
import '../data/children_repository_api.dart';
import '../data/home_snapshot_cache.dart';
import '../domain/announcement.dart';
import '../domain/announcements_repository.dart';
import '../domain/child.dart';
import '../domain/child_detail.dart';
import '../domain/children_repository.dart';

part 'home_providers.g.dart';

/// The children repository.
@Riverpod(keepAlive: true)
ChildrenRepository childrenRepository(Ref ref) =>
    ApiChildrenRepository(ref.watch(apiClientProvider));

/// The announcements repository.
@Riverpod(keepAlive: true)
AnnouncementsRepository announcementsRepository(Ref ref) =>
    ApiAnnouncementsRepository(ref.watch(apiClientProvider));

/// The last good home payload.
///
/// `keepAlive` so it survives the home screen being disposed — its whole
/// purpose is to still be there when a refresh fails.
@Riverpod(keepAlive: true)
HomeSnapshotCache homeSnapshotCache(Ref ref) => HomeSnapshotCache();

/// Which children this user can reach, decided by the ability model rather
/// than by a role string.
@riverpod
HomeScope homeScope(Ref ref) => resolveHomeScope(ref.watch(abilityProvider));

/// What the home screen shows, and why it might be stale.
class HomeState {
  const HomeState({
    required this.children,
    required this.announcements,
    required this.staleness,
  });

  /// One card per child.
  final List<Child> children;

  /// The pinned/active announcements strip.
  final List<Announcement> announcements;

  /// Null when this is fresh from the server; set when it came from cache.
  final HomeStaleness? staleness;

  /// Whether the screen is showing cached rather than live data.
  bool get isStale => staleness != null;

  /// Whether the empty state applies — no children at all, freshly confirmed.
  ///
  /// `specs/06-mobile-app-spec.md` says this "should not occur
  /// post-onboarding; if it does, it signals a data problem". It is therefore
  /// only claimed on *fresh* data: an empty cache is not evidence of anything.
  bool get isGenuinelyEmpty => children.isEmpty && !isStale;
}

/// Why the home screen is showing cached data.
enum HomeStaleness {
  /// The device could not reach the server.
  offline,

  /// The server was reachable but the refresh failed.
  refreshFailed,
}

/// Loads the home payload, falling back to cache rather than to an error.
///
/// The screen spec is explicit: on error, show "cached last-known cards + a
/// subtle 'couldn't refresh' banner — degrades gracefully offline". A parent
/// opening the app on a weak connection wants yesterday's answer, not a retry
/// button. Only a failure with *no* cache behind it becomes an error state.
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeState> build() => _load();

  /// Re-fetches, used by pull-to-refresh.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<HomeState> _load() async {
    final scope = ref.read(homeScopeProvider);
    if (scope == HomeScope.none) {
      return const HomeState(children: [], announcements: [], staleness: null);
    }

    final cache = ref.read(homeSnapshotCacheProvider);

    try {
      final children = await ref
          .read(childrenRepositoryProvider)
          .fetchChildren();
      final announcements = await ref
          .read(announcementsRepositoryProvider)
          .fetchAnnouncements();

      final now = DateTime.now();
      final visible = selectPinnedAnnouncements(announcements.items, now);

      cache.save(
        children: children.items,
        announcements: visible,
        fetchedAt: now.toUtc(),
      );

      return HomeState(
        children: children.items,
        announcements: visible,
        staleness: null,
      );
    } on RaeedException catch (error) {
      final cached = cache.snapshot;
      if (cached == null) rethrow;

      return HomeState(
        children: cached.children,
        announcements: cached.announcements,
        staleness: error is NetworkException
            ? HomeStaleness.offline
            : HomeStaleness.refreshFailed,
      );
    }
  }
}

/// One child's full profile.
///
/// Keyed by id so navigating between two children does not serve the first
/// one's record for the second — which on a screen carrying health information
/// would be a safeguarding failure, not a caching bug.
@riverpod
Future<ChildDetail> childDetail(Ref ref, String childId) =>
    ref.watch(childrenRepositoryProvider).fetchChild(childId);
