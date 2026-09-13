import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_environment.dart';
import 'api_client.dart';

part 'api_client_provider.g.dart';

/// The build-time environment.
///
/// A provider rather than a global constant so a test can point the app at a
/// stub server without a `--dart-define`.
@Riverpod(keepAlive: true)
AppEnvironment appEnvironment(Ref ref) => AppEnvironment.fromDartDefines();

/// The app's single [ApiClient].
///
/// `keepAlive` because the underlying `dio` instance carries the auth
/// interceptor and its connection pool; rebuilding it per screen would drop
/// warm connections on a network where warm connections are the difference
/// between a card that loads and one that times out.
///
/// Constructed from configuration rather than thrown-until-overridden, unlike
/// `sessionBootstrapperProvider`: there is exactly one correct client for a
/// given build, so making composition remember to wire it up would be pure
/// ceremony. Tests override it with a client built over a stub adapter.
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) =>
    ApiClient(environment: ref.watch(appEnvironmentProvider));
