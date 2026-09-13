// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_monitor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's connectivity monitor. Overridden in tests.

@ProviderFor(connectivityMonitor)
const connectivityMonitorProvider = ConnectivityMonitorProvider._();

/// The app's connectivity monitor. Overridden in tests.

final class ConnectivityMonitorProvider
    extends
        $FunctionalProvider<
          ConnectivityMonitor,
          ConnectivityMonitor,
          ConnectivityMonitor
        >
    with $Provider<ConnectivityMonitor> {
  /// The app's connectivity monitor. Overridden in tests.
  const ConnectivityMonitorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityMonitorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityMonitorHash();

  @$internal
  @override
  $ProviderElement<ConnectivityMonitor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityMonitor create(Ref ref) {
    return connectivityMonitor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityMonitor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityMonitor>(value),
    );
  }
}

String _$connectivityMonitorHash() =>
    r'3ca52e8bebb74e77a92f94ab57fdcedbb81c4dea';

/// The live connectivity status.
///
/// Starts optimistic: the attendance screen must not flash an offline banner
/// during the first frame while the platform channel answers, and a request
/// that turns out to fail will produce a [ConnectivityStatus.offline] anyway
/// through the repository's own error handling.

@ProviderFor(ConnectivityState)
const connectivityStateProvider = ConnectivityStateProvider._();

/// The live connectivity status.
///
/// Starts optimistic: the attendance screen must not flash an offline banner
/// during the first frame while the platform channel answers, and a request
/// that turns out to fail will produce a [ConnectivityStatus.offline] anyway
/// through the repository's own error handling.
final class ConnectivityStateProvider
    extends $NotifierProvider<ConnectivityState, ConnectivityStatus> {
  /// The live connectivity status.
  ///
  /// Starts optimistic: the attendance screen must not flash an offline banner
  /// during the first frame while the platform channel answers, and a request
  /// that turns out to fail will produce a [ConnectivityStatus.offline] anyway
  /// through the repository's own error handling.
  const ConnectivityStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStateHash();

  @$internal
  @override
  ConnectivityState create() => ConnectivityState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityStatus>(value),
    );
  }
}

String _$connectivityStateHash() => r'497091adee3976ca52779292f745500c4b386860';

/// The live connectivity status.
///
/// Starts optimistic: the attendance screen must not flash an offline banner
/// during the first frame while the platform channel answers, and a request
/// that turns out to fail will produce a [ConnectivityStatus.offline] anyway
/// through the repository's own error handling.

abstract class _$ConnectivityState extends $Notifier<ConnectivityStatus> {
  ConnectivityStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ConnectivityStatus, ConnectivityStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectivityStatus, ConnectivityStatus>,
              ConnectivityStatus,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
