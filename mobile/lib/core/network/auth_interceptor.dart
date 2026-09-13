import 'dart:async';

import 'package:dio/dio.dart';

import '../session/token_store.dart';

/// Exchanges a refresh token for a new pair.
///
/// Declared here, implemented in the `auth` feature's data layer. Without this
/// seam the interceptor would have to import the auth repository, and the auth
/// repository already imports the client the interceptor is attached to — a
/// cycle. The interceptor depends on the narrow capability it actually needs.
abstract interface class AuthTokenRefresher {
  /// Rotates [refreshToken], returning the new pair.
  ///
  /// Throws when the refresh token is revoked or expired, which ends the
  /// session.
  Future<AuthTokens> refresh(String refreshToken);
}

/// Called when the session can no longer be recovered.
typedef OnSessionExpired = FutureOr<void> Function();

/// Attaches the bearer token to every request, and transparently recovers from
/// an expired access token exactly once per request.
///
/// Access tokens last 15 minutes (`specs/10-security-and-privacy.md`), so a
/// user who leaves the app open through a session will hit an expiry mid-use.
/// Making them re-authenticate for that would be hostile; silently refreshing
/// and replaying the request is the behaviour the short expiry assumes.
///
/// Two properties matter and are both handled below:
///
/// * **Single-flight refresh.** A home screen fires several requests at once.
///   Without coordination each would refresh independently, and since refresh
///   tokens *rotate*, the second rotation would invalidate the first — logging
///   the user out during a successful refresh. All concurrent callers await one
///   in-flight refresh.
/// * **One retry, never a loop.** A request is replayed at most once. If the
///   replay also 401s, the session ends rather than recursing.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    required AuthTokenRefresher refresher,
    required OnSessionExpired onSessionExpired,
  }) : _tokenStore = tokenStore,
       _refresher = refresher,
       _onSessionExpired = onSessionExpired;

  final TokenStore _tokenStore;
  final AuthTokenRefresher _refresher;
  final OnSessionExpired _onSessionExpired;

  /// The in-flight refresh, if any. Non-null means "someone is already doing
  /// this; wait for them".
  Future<AuthTokens?>? _inFlightRefresh;

  /// Marks a request as already replayed, so a second 401 ends the session
  /// instead of retrying forever.
  static const String _retriedFlag = 'raeed.retried';

  /// Endpoints that must never carry a bearer token, per
  /// `specs/04-api/conventions.md`.
  static const Set<String> _anonymousPaths = {
    '/auth/otp/request',
    '/auth/otp/verify',
    '/auth/refresh',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAnonymous(options.path)) return handler.next(options);

    final tokens = await _readTokensQuietly();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;

    final isRecoverable =
        response.statusCode == 401 &&
        !_isAnonymous(options.path) &&
        options.extra[_retriedFlag] != true;
    if (!isRecoverable) return handler.next(response);

    final refreshed = await _refreshOnce();
    if (refreshed == null) {
      await _onSessionExpired();
      return handler.next(response);
    }

    try {
      final replayed = await _replay(options, refreshed);
      handler.resolve(replayed);
    } on DioException catch (error) {
      handler.next(error.response ?? response);
    } on Object {
      // The replay failed for a reason unrelated to auth; surface the original
      // 401 rather than masking it with a transport error.
      handler.next(response);
    }
  }

  /// Runs a refresh, or joins the one already running.
  Future<AuthTokens?> _refreshOnce() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing;

    final attempt = _performRefresh();
    _inFlightRefresh = attempt;
    return attempt.whenComplete(() => _inFlightRefresh = null);
  }

  Future<AuthTokens?> _performRefresh() async {
    final current = await _readTokensQuietly();
    if (current == null) return null;
    try {
      final rotated = await _refresher.refresh(current.refreshToken);
      await _tokenStore.write(rotated);
      return rotated;
    } on Object {
      // A revoked or expired refresh token is the end of the session. Clear it
      // so the next cold start does not retry a token that cannot work.
      await _tokenStore.clear();
      return null;
    }
  }

  /// Re-issues [options] with the new access token, flagged so it is not
  /// retried a second time.
  Future<Response<dynamic>> _replay(RequestOptions options, AuthTokens tokens) {
    final dio = Dio(
      BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
        validateStatus: options.validateStatus,
        responseType: options.responseType,
        contentType: options.contentType,
      ),
    );

    return dio.fetch<dynamic>(
      options.copyWith(
        headers: {
          ...options.headers,
          'Authorization': 'Bearer ${tokens.accessToken}',
        },
        extra: {...options.extra, _retriedFlag: true},
      ),
    );
  }

  Future<AuthTokens?> _readTokensQuietly() async {
    try {
      return await _tokenStore.read();
    } on Object {
      // An unreadable keystore is handled as "no session" — the request goes
      // out unauthenticated, gets a 401, and the user signs in again. Better
      // than crashing on every request.
      return null;
    }
  }

  bool _isAnonymous(String path) =>
      _anonymousPaths.any((anonymous) => path.endsWith(anonymous));
}
