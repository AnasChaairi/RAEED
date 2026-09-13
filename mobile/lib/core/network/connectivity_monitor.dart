import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_monitor.g.dart';

/// Whether the device believes it has a network path.
enum ConnectivityStatus {
  /// A network interface is up. Says nothing about whether the RAEED server is
  /// actually reachable — only `NetworkException` answers that.
  online,

  /// No interface at all.
  offline;

  /// Whether this status permits attempting a request.
  bool get isOnline => this == ConnectivityStatus.online;
}

/// Reports connectivity transitions.
///
/// An interface rather than `connectivity_plus` directly, for two reasons: the
/// plugin needs a platform channel that a widget test does not have, and the
/// sync drain's whole behaviour is "what happens on reconnect", which has to be
/// driveable from a test without a real radio.
abstract interface class ConnectivityMonitor {
  /// The current status.
  Future<ConnectivityStatus> current();

  /// Emits on every change.
  Stream<ConnectivityStatus> get changes;
}

/// [ConnectivityMonitor] backed by `connectivity_plus`.
class PlatformConnectivityMonitor implements ConnectivityMonitor {
  PlatformConnectivityMonitor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<ConnectivityStatus> current() async =>
      _statusOf(await _connectivity.checkConnectivity());

  @override
  Stream<ConnectivityStatus> get changes =>
      _connectivity.onConnectivityChanged.map(_statusOf).distinct();

  static ConnectivityStatus _statusOf(List<ConnectivityResult> results) =>
      results.every((result) => result == ConnectivityResult.none)
      ? ConnectivityStatus.offline
      : ConnectivityStatus.online;
}

/// An always-on monitor, for tests and for platforms without the plugin.
class AlwaysOnlineConnectivityMonitor implements ConnectivityMonitor {
  const AlwaysOnlineConnectivityMonitor();

  @override
  Future<ConnectivityStatus> current() async => ConnectivityStatus.online;

  @override
  Stream<ConnectivityStatus> get changes => const Stream.empty();
}

/// The app's connectivity monitor. Overridden in tests.
@Riverpod(keepAlive: true)
ConnectivityMonitor connectivityMonitor(Ref ref) {
  final monitor = PlatformConnectivityMonitor();
  return monitor;
}

/// The live connectivity status.
///
/// Starts optimistic: the attendance screen must not flash an offline banner
/// during the first frame while the platform channel answers, and a request
/// that turns out to fail will produce a [ConnectivityStatus.offline] anyway
/// through the repository's own error handling.
@Riverpod(keepAlive: true)
class ConnectivityState extends _$ConnectivityState {
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  ConnectivityStatus build() {
    final monitor = ref.watch(connectivityMonitorProvider);
    unawaited(monitor.current().then((status) => state = status));
    _subscription = monitor.changes.listen((status) => state = status);
    ref.onDispose(() => unawaited(_subscription?.cancel()));
    return ConnectivityStatus.online;
  }

  /// Overrides the reported status.
  ///
  /// Called when a request fails with `NetworkException` even though the radio
  /// claims to be up — a captive portal or a dead uplink looks online to the
  /// platform and offline to the app, and the app's view is the useful one.
  void reportOffline() => state = ConnectivityStatus.offline;

  /// Records that a request just succeeded, which is the only proof of reach.
  void reportOnline() => state = ConnectivityStatus.online;
}
