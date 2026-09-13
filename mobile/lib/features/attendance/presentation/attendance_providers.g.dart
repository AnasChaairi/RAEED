// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The attendance repository.

@ProviderFor(attendanceRepository)
const attendanceRepositoryProvider = AttendanceRepositoryProvider._();

/// The attendance repository.

final class AttendanceRepositoryProvider
    extends
        $FunctionalProvider<
          AttendanceRepository,
          AttendanceRepository,
          AttendanceRepository
        >
    with $Provider<AttendanceRepository> {
  /// The attendance repository.
  const AttendanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttendanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendanceRepository create(Ref ref) {
    return attendanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceRepository>(value),
    );
  }
}

String _$attendanceRepositoryHash() =>
    r'9dd01c21df9eca0f283f91a07fcfeee570ecc3b2';

/// The presence repository.

@ProviderFor(presenceRepository)
const presenceRepositoryProvider = PresenceRepositoryProvider._();

/// The presence repository.

final class PresenceRepositoryProvider
    extends
        $FunctionalProvider<
          PresenceRepository,
          PresenceRepository,
          PresenceRepository
        >
    with $Provider<PresenceRepository> {
  /// The presence repository.
  const PresenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presenceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<PresenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PresenceRepository create(Ref ref) {
    return presenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresenceRepository>(value),
    );
  }
}

String _$presenceRepositoryHash() =>
    r'3909658a39dda4e984f3a1ee19c0095934b8c213';

/// How many writes are waiting to reach the server.
///
/// Surfaced so an educator can see that the group they marked in a basement
/// hall has not synced yet — a silent queue is indistinguishable from a lost
/// one.

@ProviderFor(pendingWriteCount)
const pendingWriteCountProvider = PendingWriteCountProvider._();

/// How many writes are waiting to reach the server.
///
/// Surfaced so an educator can see that the group they marked in a basement
/// hall has not synced yet — a silent queue is indistinguishable from a lost
/// one.

final class PendingWriteCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// How many writes are waiting to reach the server.
  ///
  /// Surfaced so an educator can see that the group they marked in a basement
  /// hall has not synced yet — a silent queue is indistinguishable from a lost
  /// one.
  const PendingWriteCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingWriteCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingWriteCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return pendingWriteCount(ref);
  }
}

String _$pendingWriteCountHash() => r'236d33d2d406492342001cd90c99a7a33e4c6dbe';

/// Confirmations the guardian has not answered.
///
/// Read by the Home card so an unanswered confirmation survives a missed push.

@ProviderFor(unansweredConfirmations)
const unansweredConfirmationsProvider = UnansweredConfirmationsProvider._();

/// Confirmations the guardian has not answered.
///
/// Read by the Home card so an unanswered confirmation survives a missed push.

final class UnansweredConfirmationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PendingPresenceConfirmation>>,
          List<PendingPresenceConfirmation>,
          Stream<List<PendingPresenceConfirmation>>
        >
    with
        $FutureModifier<List<PendingPresenceConfirmation>>,
        $StreamProvider<List<PendingPresenceConfirmation>> {
  /// Confirmations the guardian has not answered.
  ///
  /// Read by the Home card so an unanswered confirmation survives a missed push.
  const UnansweredConfirmationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unansweredConfirmationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unansweredConfirmationsHash();

  @$internal
  @override
  $StreamProviderElement<List<PendingPresenceConfirmation>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PendingPresenceConfirmation>> create(Ref ref) {
    return unansweredConfirmations(ref);
  }
}

String _$unansweredConfirmationsHash() =>
    r'cb3dba7de25e1c326654183581ba3ec2ea554120';

/// The attendance sheet for one session, kept live as writes queue and drain.

@ProviderFor(AttendanceSheetController)
const attendanceSheetControllerProvider = AttendanceSheetControllerFamily._();

/// The attendance sheet for one session, kept live as writes queue and drain.
final class AttendanceSheetControllerProvider
    extends
        $StreamNotifierProvider<AttendanceSheetController, AttendanceSheet> {
  /// The attendance sheet for one session, kept live as writes queue and drain.
  const AttendanceSheetControllerProvider._({
    required AttendanceSheetControllerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'attendanceSheetControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendanceSheetControllerHash();

  @override
  String toString() {
    return r'attendanceSheetControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  AttendanceSheetController create() => AttendanceSheetController();

  @override
  bool operator ==(Object other) {
    return other is AttendanceSheetControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendanceSheetControllerHash() =>
    r'399b094aae035417ca36310c83779c8ac55ae7c7';

/// The attendance sheet for one session, kept live as writes queue and drain.

final class AttendanceSheetControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AttendanceSheetController,
          AsyncValue<AttendanceSheet>,
          AttendanceSheet,
          Stream<AttendanceSheet>,
          (String, String)
        > {
  const AttendanceSheetControllerFamily._()
    : super(
        retry: null,
        name: r'attendanceSheetControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The attendance sheet for one session, kept live as writes queue and drain.

  AttendanceSheetControllerProvider call(String sessionId, String groupId) =>
      AttendanceSheetControllerProvider._(
        argument: (sessionId, groupId),
        from: this,
      );

  @override
  String toString() => r'attendanceSheetControllerProvider';
}

/// The attendance sheet for one session, kept live as writes queue and drain.

abstract class _$AttendanceSheetController
    extends $StreamNotifier<AttendanceSheet> {
  late final _$args = ref.$arg as (String, String);
  String get sessionId => _$args.$1;
  String get groupId => _$args.$2;

  Stream<AttendanceSheet> build(String sessionId, String groupId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2);
    final ref = this.ref as $Ref<AsyncValue<AttendanceSheet>, AttendanceSheet>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AttendanceSheet>, AttendanceSheet>,
              AsyncValue<AttendanceSheet>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Submits a guardian's presence answer.

@ProviderFor(submitPresenceAnswer)
const submitPresenceAnswerProvider = SubmitPresenceAnswerProvider._();

/// Submits a guardian's presence answer.

final class SubmitPresenceAnswerProvider
    extends
        $FunctionalProvider<
          Future<void> Function(PresenceAnswerDraft),
          Future<void> Function(PresenceAnswerDraft),
          Future<void> Function(PresenceAnswerDraft)
        >
    with $Provider<Future<void> Function(PresenceAnswerDraft)> {
  /// Submits a guardian's presence answer.
  const SubmitPresenceAnswerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submitPresenceAnswerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submitPresenceAnswerHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function(PresenceAnswerDraft)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function(PresenceAnswerDraft) create(Ref ref) {
    return submitPresenceAnswer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function(PresenceAnswerDraft) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Future<void> Function(PresenceAnswerDraft)>(value),
    );
  }
}

String _$submitPresenceAnswerHash() =>
    r'eb46fa0f70546d2bd54cdf76272d80c277c8c97d';
