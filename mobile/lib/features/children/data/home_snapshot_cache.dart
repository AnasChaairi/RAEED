import 'package:meta/meta.dart';

import '../domain/announcement.dart';
import '../domain/child.dart';

/// The last home payload that loaded successfully.
@immutable
class HomeSnapshot {
  const HomeSnapshot({
    required this.children,
    required this.announcements,
    required this.fetchedAt,
  });

  /// The child cards as last seen.
  final List<Child> children;

  /// The announcements as last seen.
  final List<Announcement> announcements;

  /// When this snapshot was taken, in UTC.
  final DateTime fetchedAt;
}

/// Holds the last-known home payload so a failed refresh can still render.
///
/// `specs/06-mobile-app-spec.md` requires Parent Home to degrade to "cached
/// last-known cards + a subtle 'couldn't refresh' banner" rather than an error
/// screen — a parent on a weak connection still needs to see which group their
/// child is in and when the next session is.
///
/// **In memory, for the lifetime of the session, deliberately.** Two reasons:
///
/// * Durable caching belongs to the offline work in
///   `specs/02-architecture.md`, whose scope is the attendance and presence
///   queue (`RAEED-16`/`RAEED-17`) and whose store is Drift. Adding a second,
///   parallel persistence mechanism here would leave two caches to invalidate.
/// * Children's names, groups and health flags written to disk are data at
///   rest under `specs/10-security-and-privacy.md`. Persisting them is a
///   decision to take with that spec open, not a side effect of a home screen.
///
/// The practical consequence is honest and bounded: a cold start with no
/// connection shows the error state, while a refresh failure mid-session shows
/// the cards plus the banner. The first is unavoidable without durable
/// storage; the second is the case the spec actually describes.
class HomeSnapshotCache {
  HomeSnapshot? _snapshot;

  /// The last successful payload, or null if none has loaded this session.
  HomeSnapshot? get snapshot => _snapshot;

  /// Records a successful load.
  void save({
    required List<Child> children,
    required List<Announcement> announcements,
    required DateTime fetchedAt,
  }) => _snapshot = HomeSnapshot(
    children: List.unmodifiable(children),
    announcements: List.unmodifiable(announcements),
    fetchedAt: fetchedAt.toUtc(),
  );

  /// Drops the snapshot.
  ///
  /// Called on sign-out: the next user to sign in on this device must never
  /// see the previous user's children flash on screen while their own load.
  void clear() => _snapshot = null;
}
