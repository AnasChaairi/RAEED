// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'educator_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(educatorRepository)
const educatorRepositoryProvider = EducatorRepositoryProvider._();

final class EducatorRepositoryProvider
    extends
        $FunctionalProvider<
          EducatorRepository,
          EducatorRepository,
          EducatorRepository
        >
    with $Provider<EducatorRepository> {
  const EducatorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'educatorRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$educatorRepositoryHash();

  @$internal
  @override
  $ProviderElement<EducatorRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EducatorRepository create(Ref ref) {
    return educatorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EducatorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EducatorRepository>(value),
    );
  }
}

String _$educatorRepositoryHash() =>
    r'3103971fca1c52d4d8610cf9676bf12feeda8bb6';

@ProviderFor(sessionsRepository)
const sessionsRepositoryProvider = SessionsRepositoryProvider._();

final class SessionsRepositoryProvider
    extends
        $FunctionalProvider<
          SessionsRepository,
          SessionsRepository,
          SessionsRepository
        >
    with $Provider<SessionsRepository> {
  const SessionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SessionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionsRepository create(Ref ref) {
    return sessionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionsRepository>(value),
    );
  }
}

String _$sessionsRepositoryHash() =>
    r'9b9d5dc0dd08d0852ed6cca291de3df2d5fe701d';

@ProviderFor(educatorChildrenRepository)
const educatorChildrenRepositoryProvider =
    EducatorChildrenRepositoryProvider._();

final class EducatorChildrenRepositoryProvider
    extends
        $FunctionalProvider<
          EducatorChildrenRepository,
          EducatorChildrenRepository,
          EducatorChildrenRepository
        >
    with $Provider<EducatorChildrenRepository> {
  const EducatorChildrenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'educatorChildrenRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$educatorChildrenRepositoryHash();

  @$internal
  @override
  $ProviderElement<EducatorChildrenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EducatorChildrenRepository create(Ref ref) {
    return educatorChildrenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EducatorChildrenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EducatorChildrenRepository>(value),
    );
  }
}

String _$educatorChildrenRepositoryHash() =>
    r'55cce4b10e76efb3a54ce3e0f87cf151eb312d8e';

@ProviderFor(educatorMemoriesRepository)
const educatorMemoriesRepositoryProvider =
    EducatorMemoriesRepositoryProvider._();

final class EducatorMemoriesRepositoryProvider
    extends
        $FunctionalProvider<
          EducatorMemoriesRepository,
          EducatorMemoriesRepository,
          EducatorMemoriesRepository
        >
    with $Provider<EducatorMemoriesRepository> {
  const EducatorMemoriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'educatorMemoriesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$educatorMemoriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<EducatorMemoriesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EducatorMemoriesRepository create(Ref ref) {
    return educatorMemoriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EducatorMemoriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EducatorMemoriesRepository>(value),
    );
  }
}

String _$educatorMemoriesRepositoryHash() =>
    r'b99b226c8a93d7b20003e05a5ef9ce0d0f0620a8';

/// Which tab the educator shell shows, held outside the widget so a card
/// or a deep link can select one without rebuilding the shell.

@ProviderFor(EducatorTabController)
const educatorTabControllerProvider = EducatorTabControllerProvider._();

/// Which tab the educator shell shows, held outside the widget so a card
/// or a deep link can select one without rebuilding the shell.
final class EducatorTabControllerProvider
    extends $NotifierProvider<EducatorTabController, EducatorTab> {
  /// Which tab the educator shell shows, held outside the widget so a card
  /// or a deep link can select one without rebuilding the shell.
  const EducatorTabControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'educatorTabControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$educatorTabControllerHash();

  @$internal
  @override
  EducatorTabController create() => EducatorTabController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EducatorTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EducatorTab>(value),
    );
  }
}

String _$educatorTabControllerHash() =>
    r'7cafddb68dec1f8a0cf0b1fdc08370ba8e58c43a';

/// Which tab the educator shell shows, held outside the widget so a card
/// or a deep link can select one without rebuilding the shell.

abstract class _$EducatorTabController extends $Notifier<EducatorTab> {
  EducatorTab build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EducatorTab, EducatorTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EducatorTab, EducatorTab>,
              EducatorTab,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TodayController)
const todayControllerProvider = TodayControllerProvider._();

final class TodayControllerProvider
    extends $AsyncNotifierProvider<TodayController, TodayView> {
  const TodayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayControllerHash();

  @$internal
  @override
  TodayController create() => TodayController();
}

String _$todayControllerHash() => r'5287611185bb3a3982d024f711f2539c80b4cd49';

abstract class _$TodayController extends $AsyncNotifier<TodayView> {
  FutureOr<TodayView> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<TodayView>, TodayView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodayView>, TodayView>,
              AsyncValue<TodayView>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(weekSessions)
const weekSessionsProvider = WeekSessionsFamily._();

final class WeekSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SessionItem>>,
          List<SessionItem>,
          FutureOr<List<SessionItem>>
        >
    with
        $FutureModifier<List<SessionItem>>,
        $FutureProvider<List<SessionItem>> {
  const WeekSessionsProvider._({
    required WeekSessionsFamily super.from,
    required ({DateTime from, DateTime to, String? groupId}) super.argument,
  }) : super(
         retry: null,
         name: r'weekSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weekSessionsHash();

  @override
  String toString() {
    return r'weekSessionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SessionItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SessionItem>> create(Ref ref) {
    final argument =
        this.argument as ({DateTime from, DateTime to, String? groupId});
    return weekSessions(
      ref,
      from: argument.from,
      to: argument.to,
      groupId: argument.groupId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WeekSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weekSessionsHash() => r'cbd787b86cea155b27f7267e3228cb446c4f784a';

final class WeekSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SessionItem>>,
          ({DateTime from, DateTime to, String? groupId})
        > {
  const WeekSessionsFamily._()
    : super(
        retry: null,
        name: r'weekSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeekSessionsProvider call({
    required DateTime from,
    required DateTime to,
    String? groupId,
  }) => WeekSessionsProvider._(
    argument: (from: from, to: to, groupId: groupId),
    from: this,
  );

  @override
  String toString() => r'weekSessionsProvider';
}

@ProviderFor(sessionDetail)
const sessionDetailProvider = SessionDetailFamily._();

final class SessionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionDetail>,
          SessionDetail,
          FutureOr<SessionDetail>
        >
    with $FutureModifier<SessionDetail>, $FutureProvider<SessionDetail> {
  const SessionDetailProvider._({
    required SessionDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionDetailHash();

  @override
  String toString() {
    return r'sessionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SessionDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SessionDetail> create(Ref ref) {
    final argument = this.argument as String;
    return sessionDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionDetailHash() => r'8ce60409208cb24b2b89dea2ad1d379e1096523b';

final class SessionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SessionDetail>, String> {
  const SessionDetailFamily._()
    : super(
        retry: null,
        name: r'sessionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionDetailProvider call(String sessionId) =>
      SessionDetailProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionDetailProvider';
}

@ProviderFor(presenceOverview)
const presenceOverviewProvider = PresenceOverviewFamily._();

final class PresenceOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<PresenceOverview>,
          PresenceOverview,
          FutureOr<PresenceOverview>
        >
    with $FutureModifier<PresenceOverview>, $FutureProvider<PresenceOverview> {
  const PresenceOverviewProvider._({
    required PresenceOverviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'presenceOverviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$presenceOverviewHash();

  @override
  String toString() {
    return r'presenceOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PresenceOverview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PresenceOverview> create(Ref ref) {
    final argument = this.argument as String;
    return presenceOverview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PresenceOverviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$presenceOverviewHash() => r'8116ae878eda75b922091e2ea2a356d8e44b9e29';

final class PresenceOverviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PresenceOverview>, String> {
  const PresenceOverviewFamily._()
    : super(
        retry: null,
        name: r'presenceOverviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PresenceOverviewProvider call(String sessionId) =>
      PresenceOverviewProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'presenceOverviewProvider';
}

@ProviderFor(groupHomework)
const groupHomeworkProvider = GroupHomeworkFamily._();

final class GroupHomeworkProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HomeworkItem>>,
          List<HomeworkItem>,
          FutureOr<List<HomeworkItem>>
        >
    with
        $FutureModifier<List<HomeworkItem>>,
        $FutureProvider<List<HomeworkItem>> {
  const GroupHomeworkProvider._({
    required GroupHomeworkFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupHomeworkProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupHomeworkHash();

  @override
  String toString() {
    return r'groupHomeworkProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HomeworkItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HomeworkItem>> create(Ref ref) {
    final argument = this.argument as String;
    return groupHomework(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupHomeworkProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupHomeworkHash() => r'926dc54ccd0f7fa7b2ee58d9a9f07a17da7912fb';

final class GroupHomeworkFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HomeworkItem>>, String> {
  const GroupHomeworkFamily._()
    : super(
        retry: null,
        name: r'groupHomeworkProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupHomeworkProvider call(String groupId) =>
      GroupHomeworkProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupHomeworkProvider';
}

@ProviderFor(educatorRoster)
const educatorRosterProvider = EducatorRosterFamily._();

final class EducatorRosterProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RosterChild>>,
          List<RosterChild>,
          FutureOr<List<RosterChild>>
        >
    with
        $FutureModifier<List<RosterChild>>,
        $FutureProvider<List<RosterChild>> {
  const EducatorRosterProvider._({
    required EducatorRosterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'educatorRosterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$educatorRosterHash();

  @override
  String toString() {
    return r'educatorRosterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RosterChild>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RosterChild>> create(Ref ref) {
    final argument = this.argument as String;
    return educatorRoster(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EducatorRosterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$educatorRosterHash() => r'cdc1faab772ced84dbe6ffc92b215d09148e0170';

final class EducatorRosterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RosterChild>>, String> {
  const EducatorRosterFamily._()
    : super(
        retry: null,
        name: r'educatorRosterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EducatorRosterProvider call(String groupId) =>
      EducatorRosterProvider._(argument: groupId, from: this);

  @override
  String toString() => r'educatorRosterProvider';
}

@ProviderFor(educatorChildProfile)
const educatorChildProfileProvider = EducatorChildProfileFamily._();

final class EducatorChildProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<EducatorChildProfile>,
          EducatorChildProfile,
          FutureOr<EducatorChildProfile>
        >
    with
        $FutureModifier<EducatorChildProfile>,
        $FutureProvider<EducatorChildProfile> {
  const EducatorChildProfileProvider._({
    required EducatorChildProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'educatorChildProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$educatorChildProfileHash();

  @override
  String toString() {
    return r'educatorChildProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EducatorChildProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EducatorChildProfile> create(Ref ref) {
    final argument = this.argument as String;
    return educatorChildProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EducatorChildProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$educatorChildProfileHash() =>
    r'd087ac37e7f76b1891a6f7fd7a49b667b5878078';

final class EducatorChildProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EducatorChildProfile>, String> {
  const EducatorChildProfileFamily._()
    : super(
        retry: null,
        name: r'educatorChildProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EducatorChildProfileProvider call(String childId) =>
      EducatorChildProfileProvider._(argument: childId, from: this);

  @override
  String toString() => r'educatorChildProfileProvider';
}

@ProviderFor(myPosts)
const myPostsProvider = MyPostsProvider._();

final class MyPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MyPost>>,
          List<MyPost>,
          FutureOr<List<MyPost>>
        >
    with $FutureModifier<List<MyPost>>, $FutureProvider<List<MyPost>> {
  const MyPostsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPostsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPostsHash();

  @$internal
  @override
  $FutureProviderElement<List<MyPost>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MyPost>> create(Ref ref) {
    return myPosts(ref);
  }
}

String _$myPostsHash() => r'9571bc199ae34cf91d42f3fa0b4121305e8e6f96';

@ProviderFor(AvailabilityController)
const availabilityControllerProvider = AvailabilityControllerProvider._();

final class AvailabilityControllerProvider
    extends
        $AsyncNotifierProvider<AvailabilityController, AvailabilityWindow?> {
  const AvailabilityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availabilityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availabilityControllerHash();

  @$internal
  @override
  AvailabilityController create() => AvailabilityController();
}

String _$availabilityControllerHash() =>
    r'9b052cc051f5ed39bb96d3954af969e102a1904b';

abstract class _$AvailabilityController
    extends $AsyncNotifier<AvailabilityWindow?> {
  FutureOr<AvailabilityWindow?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<AvailabilityWindow?>, AvailabilityWindow?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AvailabilityWindow?>, AvailabilityWindow?>,
              AsyncValue<AvailabilityWindow?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The bottom-nav badges: sessions still without content, threads with
/// something new. Missing data counts as zero, never as a wait.

@ProviderFor(educatorTabBadges)
const educatorTabBadgesProvider = EducatorTabBadgesProvider._();

/// The bottom-nav badges: sessions still without content, threads with
/// something new. Missing data counts as zero, never as a wait.

final class EducatorTabBadgesProvider
    extends
        $FunctionalProvider<
          ({int messages, int sessions}),
          ({int messages, int sessions}),
          ({int messages, int sessions})
        >
    with $Provider<({int messages, int sessions})> {
  /// The bottom-nav badges: sessions still without content, threads with
  /// something new. Missing data counts as zero, never as a wait.
  const EducatorTabBadgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'educatorTabBadgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$educatorTabBadgesHash();

  @$internal
  @override
  $ProviderElement<({int messages, int sessions})> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ({int messages, int sessions}) create(Ref ref) {
    return educatorTabBadges(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({int messages, int sessions}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({int messages, int sessions})>(
        value,
      ),
    );
  }
}

String _$educatorTabBadgesHash() => r'7128611ff91cea3db184db57bdfd436bd01378d2';
