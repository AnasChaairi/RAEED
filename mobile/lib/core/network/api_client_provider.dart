import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_environment.dart';
import '../session/session_controller.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

part 'api_client_provider.g.dart';

/// The build-time environment.
///
/// A provider rather than a global constant so a test can point the app at a
/// stub server without a `--dart-define`.
@Riverpod(keepAlive: true)
AppEnvironment appEnvironment(Ref ref) => AppEnvironment.fromDartDefines();

/// A client with **no** auth interceptor.
///
/// `/auth/otp/request`, `/auth/otp/verify` and `/auth/refresh` are
/// `security: []` in `specs/04-api/openapi.yaml`. Refreshing through the
/// interceptor whose whole job is to trigger refreshes would recurse, so the
/// refresh call in particular must go out on a client that cannot intercept
/// it.
@Riverpod(keepAlive: true)
ApiClient anonymousApiClient(Ref ref) =>
    ApiClient(environment: ref.watch(appEnvironmentProvider));

/// Rotates refresh tokens.
///
/// Declared here and overridden at app composition with the `auth` feature's
/// implementation, for the same reason as `sessionBootstrapperProvider`: the
/// interceptor is core infrastructure, but rotating a token is an API call
/// that belongs to a feature. The narrow seam keeps the dependency pointing
/// inward.
///
/// The default throws rather than returning a no-op refresher, which would
/// look like a working app that silently signs everyone out after fifteen
/// minutes.
@Riverpod(keepAlive: true)
AuthTokenRefresher authTokenRefresher(Ref ref) => throw UnimplementedError(
  'authTokenRefresherProvider must be overridden at app composition with the '
  'auth feature implementation. See lib/main.dart.',
);

/// The app's authenticated [ApiClient] — what every feature outside `auth`
/// should use.
///
/// `keepAlive` because the underlying `dio` instance carries the auth
/// interceptor and its connection pool; rebuilding it per screen would drop
/// warm connections on a network where a warm connection is the difference
/// between a card that loads and one that times out.
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final client = ApiClient(environment: ref.watch(appEnvironmentProvider));

  client.raw.interceptors.add(
    AuthInterceptor(
      tokenStore: ref.watch(tokenStoreProvider),
      refresher: ref.watch(authTokenRefresherProvider),
      // Reads the controller lazily: an expiry can arrive at any point in the
      // app's life, and holding a reference at construction would pin whatever
      // instance existed then.
      onSessionExpired: () =>
          ref.read(sessionControllerProvider.notifier).onSessionExpired(),
    ),
  );

  return client;
}
