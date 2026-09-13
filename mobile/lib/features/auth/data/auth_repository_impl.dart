import '../../../core/error/raeed_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/session/app_session.dart';
import '../../../core/session/token_store.dart';
import '../domain/auth_repository.dart';
import '../domain/moroccan_phone_number.dart';
import '../domain/otp_policy.dart';
import 'auth_dtos.dart';

/// The [AuthRepository] against the contract in `specs/04-api/openapi.yaml`.
///
/// Takes **two** clients, and the split is the point:
///
/// * [_anonymous] has no [AuthInterceptor]. `/auth/otp/*` and `/auth/refresh`
///   are `security: []` in the contract, and refreshing through an
///   interceptor whose job is to trigger refreshes would recurse.
/// * [_authenticated] carries the interceptor and is used for `/auth/me` and
///   `DELETE /auth/sessions/{deviceId}`, which need a bearer token and should
///   transparently survive a 15-minute access token expiring mid-call.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required ApiClient anonymous,
    required ApiClient authenticated,
    required TokenStore tokenStore,
    required AuthTokenRefresher refresher,
    DateTime Function() clock = DateTime.now,
  }) : _anonymous = anonymous,
       _authenticated = authenticated,
       _tokenStore = tokenStore,
       _refresher = refresher,
       _clock = clock;

  final ApiClient _anonymous;
  final ApiClient _authenticated;
  final TokenStore _tokenStore;

  /// The same rotation the interceptor uses, so an explicit refresh and an
  /// automatic one cannot drift apart.
  final AuthTokenRefresher _refresher;
  final DateTime Function() _clock;

  @override
  Future<OtpRequestReceipt> requestOtp(MoroccanPhoneNumber phone) async {
    // The E.164 number is in the body and nowhere else — not a query string,
    // not a path segment, both of which end up in server access logs.
    await _anonymous.post('/auth/otp/request', body: {'phone': phone.e164});

    return OtpRequestReceipt(
      phone: phone,
      requestedAt: _clock(),
      requestsMade: 1,
    );
  }

  @override
  Future<SessionUser> verifyOtp({
    required MoroccanPhoneNumber phone,
    required String code,
  }) async {
    final deviceId = await _tokenStore.deviceId();
    final response = await _anonymous.post(
      '/auth/otp/verify',
      body: {'phone': phone.e164, 'code': code, 'device_id': deviceId},
    );

    // Persist before anything else can observe the session: the very next call
    // is `/auth/me`, which needs the bearer token the interceptor reads from
    // here.
    await _tokenStore.write(authTokensFromJson(response));

    final user = await loadCurrentUser();
    if (user == null) {
      // Tokens that were just issued and are already rejected mean the
      // contract has drifted, not that the user did anything wrong. Do not
      // leave an unusable pair in the keystore.
      await _tokenStore.clear();
      throw const ContractException(
        message: 'Tokens were issued but /auth/me refused them.',
      );
    }
    return user;
  }

  @override
  Future<bool> refreshSession() async {
    final current = await _readTokensQuietly();
    if (current == null) return false;

    try {
      final rotated = await _refresher.refresh(current.refreshToken);
      await _tokenStore.write(rotated);
      return true;
    } on RaeedException {
      // A revoked or expired refresh token ends the session. Clearing here
      // means the next cold start does not retry a token that cannot work.
      await _tokenStore.clear();
      return false;
    }
  }

  @override
  Future<SessionUser?> loadCurrentUser() async {
    if (await _readTokensQuietly() == null) return null;
    try {
      final response = await _authenticated.getObject('/auth/me');
      return sessionUserFromJson(response);
    } on UnauthenticatedException {
      // The interceptor already tried to refresh and failed; the session is
      // over. Null rather than a throw, because a cold start with a stale
      // token is an ordinary "signed out", not an error to show anyone.
      await _tokenStore.clear();
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final deviceId = await _tokenStore.deviceId();
      await _authenticated.delete('/auth/sessions/$deviceId');
    } on RaeedException {
      // Offline, or the session was already revoked server-side. Either way
      // the user asked to be signed out of this device, and the local clear
      // below is what delivers that.
    } finally {
      await _tokenStore.clear();
    }
  }

  Future<AuthTokens?> _readTokensQuietly() async {
    try {
      return await _tokenStore.read();
    } on RaeedException {
      return null;
    }
  }
}

/// Rotates a refresh token for the [AuthInterceptor].
///
/// Lives in the data layer and takes the *anonymous* client, so a refresh
/// triggered by a 401 cannot itself be intercepted and trigger another
/// refresh. `POST /auth/refresh` is `security: []` in the contract precisely
/// so this is possible.
class ApiAuthTokenRefresher implements AuthTokenRefresher {
  const ApiAuthTokenRefresher({
    required ApiClient client,
    required TokenStore tokenStore,
  }) : _client = client,
       _tokenStore = tokenStore;

  final ApiClient _client;
  final TokenStore _tokenStore;

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    // The device id travels with the rotation because refresh tokens are
    // device-scoped (`ACC-07`): the server has to know which of the user's
    // sessions is being rotated, and a rotation for a revoked device must
    // fail rather than silently issue a fresh pair.
    final deviceId = await _tokenStore.deviceId();
    final response = await _client.post(
      '/auth/refresh',
      body: {'refresh_token': refreshToken, 'device_id': deviceId},
    );
    return authTokensFromJson(response);
  }
}
