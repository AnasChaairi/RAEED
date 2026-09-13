// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The children repository.

@ProviderFor(childrenRepository)
const childrenRepositoryProvider = ChildrenRepositoryProvider._();

/// The children repository.

final class ChildrenRepositoryProvider
    extends
        $FunctionalProvider<
          ChildrenRepository,
          ChildrenRepository,
          ChildrenRepository
        >
    with $Provider<ChildrenRepository> {
  /// The children repository.
  const ChildrenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childrenRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childrenRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChildrenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChildrenRepository create(Ref ref) {
    return childrenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChildrenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChildrenRepository>(value),
    );
  }
}

String _$childrenRepositoryHash() =>
    r'cce54fc40e5039dbce33ef88722c96f36a1aff6e';

/// The announcements repository.

@ProviderFor(announcementsRepository)
const announcementsRepositoryProvider = AnnouncementsRepositoryProvider._();

/// The announcements repository.

final class AnnouncementsRepositoryProvider
    extends
        $FunctionalProvider<
          AnnouncementsRepository,
          AnnouncementsRepository,
          AnnouncementsRepository
        >
    with $Provider<AnnouncementsRepository> {
  /// The announcements repository.
  const AnnouncementsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnnouncementsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnnouncementsRepository create(Ref ref) {
    return announcementsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementsRepository>(value),
    );
  }
}

String _$announcementsRepositoryHash() =>
    r'6d18ec659eed63063c6be82b92f1f5983bc38bb6';

/// The last good home payload.
///
/// `keepAlive` so it survives the home screen being disposed — its whole
/// purpose is to still be there when a refresh fails.

@ProviderFor(homeSnapshotCache)
const homeSnapshotCacheProvider = HomeSnapshotCacheProvider._();

/// The last good home payload.
///
/// `keepAlive` so it survives the home screen being disposed — its whole
/// purpose is to still be there when a refresh fails.

final class HomeSnapshotCacheProvider
    extends
        $FunctionalProvider<
          HomeSnapshotCache,
          HomeSnapshotCache,
          HomeSnapshotCache
        >
    with $Provider<HomeSnapshotCache> {
  /// The last good home payload.
  ///
  /// `keepAlive` so it survives the home screen being disposed — its whole
  /// purpose is to still be there when a refresh fails.
  const HomeSnapshotCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeSnapshotCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeSnapshotCacheHash();

  @$internal
  @override
  $ProviderElement<HomeSnapshotCache> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeSnapshotCache create(Ref ref) {
    return homeSnapshotCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeSnapshotCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeSnapshotCache>(value),
    );
  }
}

String _$homeSnapshotCacheHash() => r'a7758a8eda7655e40eafb374c61d7727a8ae8d8f';

/// Which children this user can reach, decided by the ability model rather
/// than by a role string.

@ProviderFor(homeScope)
const homeScopeProvider = HomeScopeProvider._();

/// Which children this user can reach, decided by the ability model rather
/// than by a role string.

final class HomeScopeProvider
    extends $FunctionalProvider<HomeScope, HomeScope, HomeScope>
    with $Provider<HomeScope> {
  /// Which children this user can reach, decided by the ability model rather
  /// than by a role string.
  const HomeScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeScopeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeScopeHash();

  @$internal
  @override
  $ProviderElement<HomeScope> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeScope create(Ref ref) {
    return homeScope(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeScope value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeScope>(value),
    );
  }
}

String _$homeScopeHash() => r'08de95b8d76168c0d8d27215b5193295507e0b0f';

/// Loads the home payload, falling back to cache rather than to an error.
///
/// The screen spec is explicit: on error, show "cached last-known cards + a
/// subtle 'couldn't refresh' banner — degrades gracefully offline". A parent
/// opening the app on a weak connection wants yesterday's answer, not a retry
/// button. Only a failure with *no* cache behind it becomes an error state.

@ProviderFor(HomeController)
const homeControllerProvider = HomeControllerProvider._();

/// Loads the home payload, falling back to cache rather than to an error.
///
/// The screen spec is explicit: on error, show "cached last-known cards + a
/// subtle 'couldn't refresh' banner — degrades gracefully offline". A parent
/// opening the app on a weak connection wants yesterday's answer, not a retry
/// button. Only a failure with *no* cache behind it becomes an error state.
final class HomeControllerProvider
    extends $AsyncNotifierProvider<HomeController, HomeState> {
  /// Loads the home payload, falling back to cache rather than to an error.
  ///
  /// The screen spec is explicit: on error, show "cached last-known cards + a
  /// subtle 'couldn't refresh' banner — degrades gracefully offline". A parent
  /// opening the app on a weak connection wants yesterday's answer, not a retry
  /// button. Only a failure with *no* cache behind it becomes an error state.
  const HomeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeControllerHash();

  @$internal
  @override
  HomeController create() => HomeController();
}

String _$homeControllerHash() => r'1d3cf73cd8932a5a3b8ac1a1fd675b062aa828a0';

/// Loads the home payload, falling back to cache rather than to an error.
///
/// The screen spec is explicit: on error, show "cached last-known cards + a
/// subtle 'couldn't refresh' banner — degrades gracefully offline". A parent
/// opening the app on a weak connection wants yesterday's answer, not a retry
/// button. Only a failure with *no* cache behind it becomes an error state.

abstract class _$HomeController extends $AsyncNotifier<HomeState> {
  FutureOr<HomeState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<HomeState>, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HomeState>, HomeState>,
              AsyncValue<HomeState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// One child's full profile.
///
/// Keyed by id so navigating between two children does not serve the first
/// one's record for the second — which on a screen carrying health information
/// would be a safeguarding failure, not a caching bug.

@ProviderFor(childDetail)
const childDetailProvider = ChildDetailFamily._();

/// One child's full profile.
///
/// Keyed by id so navigating between two children does not serve the first
/// one's record for the second — which on a screen carrying health information
/// would be a safeguarding failure, not a caching bug.

final class ChildDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChildDetail>,
          ChildDetail,
          FutureOr<ChildDetail>
        >
    with $FutureModifier<ChildDetail>, $FutureProvider<ChildDetail> {
  /// One child's full profile.
  ///
  /// Keyed by id so navigating between two children does not serve the first
  /// one's record for the second — which on a screen carrying health information
  /// would be a safeguarding failure, not a caching bug.
  const ChildDetailProvider._({
    required ChildDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'childDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$childDetailHash();

  @override
  String toString() {
    return r'childDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChildDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChildDetail> create(Ref ref) {
    final argument = this.argument as String;
    return childDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$childDetailHash() => r'58d88b9182a3c7bb0087ed09ef79b841169e7814';

/// One child's full profile.
///
/// Keyed by id so navigating between two children does not serve the first
/// one's record for the second — which on a screen carrying health information
/// would be a safeguarding failure, not a caching bug.

final class ChildDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChildDetail>, String> {
  const ChildDetailFamily._()
    : super(
        retry: null,
        name: r'childDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One child's full profile.
  ///
  /// Keyed by id so navigating between two children does not serve the first
  /// one's record for the second — which on a screen carrying health information
  /// would be a safeguarding failure, not a caching bug.

  ChildDetailProvider call(String childId) =>
      ChildDetailProvider._(argument: childId, from: this);

  @override
  String toString() => r'childDetailProvider';
}
