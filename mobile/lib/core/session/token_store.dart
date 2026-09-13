import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

import '../error/raeed_exception.dart';

/// A token pair as issued by `POST /auth/otp/verify` and rotated by
/// `POST /auth/refresh`.
@immutable
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  /// 15-minute JWT (`specs/10-security-and-privacy.md`).
  final String accessToken;

  /// Rotating, device-scoped refresh token. Individually revocable via
  /// `DELETE /auth/sessions/{deviceId}` (`ACC-07`).
  final String refreshToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokens &&
          other.accessToken == accessToken &&
          other.refreshToken == refreshToken;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);

  /// Never prints the tokens themselves.
  @override
  String toString() => 'AuthTokens(access: <redacted>, refresh: <redacted>)';
}

/// Persists the token pair in Keychain (iOS) / Keystore-backed
/// `EncryptedSharedPreferences` (Android).
///
/// Tokens are the one secret the app holds. They never touch
/// `SharedPreferences`, a file, or a log line —
/// `specs/10-security-and-privacy.md` lists raw phone numbers and OTP codes
/// among what must never be logged, and a bearer token is strictly worse than
/// either.
///
/// The device id is stored alongside them because `ACC-07` scopes refresh
/// tokens per device: revoking one device has to name it.
abstract interface class TokenStore {
  /// Reads the stored pair, or null if there is none.
  Future<AuthTokens?> read();

  /// Replaces the stored pair.
  Future<void> write(AuthTokens tokens);

  /// Clears the pair. Called on sign-out and on an unrecoverable 401.
  Future<void> clear();

  /// The stable per-install device id, generating and persisting one on first
  /// call.
  Future<String> deviceId();
}

/// The production [TokenStore], backed by `flutter_secure_storage`.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              // The tokens are not needed before first unlock, and this is
              // the least permissive class that still survives a reboot.
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'raeed.auth.access_token';
  static const String _refreshKey = 'raeed.auth.refresh_token';
  static const String _deviceKey = 'raeed.auth.device_id';

  @override
  Future<AuthTokens?> read() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      if (access == null || refresh == null) return null;
      return AuthTokens(accessToken: access, refreshToken: refresh);
    } on Object catch (error, stackTrace) {
      // A corrupt or inaccessible keystore must not wedge the app on the
      // splash screen forever — treat it as "no session" and let the user sign
      // in again.
      throw LocalStorageException(
        message: 'Could not read the stored session.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    try {
      await _storage.write(key: _accessKey, value: tokens.accessToken);
      await _storage.write(key: _refreshKey, value: tokens.refreshToken);
    } on Object catch (error, stackTrace) {
      throw LocalStorageException(
        message: 'Could not persist the session.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clear() async {
    // Deliberately does not clear the device id: the same install keeps its
    // identity across sign-outs, so a revoked device stays revoked rather than
    // reappearing as a new one on the next login.
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  @override
  Future<String> deviceId() async {
    final existing = await _storage.read(key: _deviceKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _generateDeviceId();
    await _storage.write(key: _deviceKey, value: generated);
    return generated;
  }

  /// A random v4-shaped identifier.
  ///
  /// Deliberately not a hardware id: `specs/10-security-and-privacy.md` keeps
  /// the app free of device fingerprinting, and a per-install random value is
  /// all `ACC-07` needs to revoke one device.
  String _generateDeviceId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = now.hashCode ^ identityHashCode(this);
    final hex =
        '${now.toRadixString(16)}${random.toUnsigned(32).toRadixString(16)}'
            .padRight(32, '0')
            .substring(0, 32);
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-4'
        '${hex.substring(13, 16)}-a${hex.substring(17, 20)}-${hex.substring(20, 32)}';
  }
}

/// An in-memory [TokenStore] for tests and widget previews.
///
/// Keeps tests off the platform channel, which is not available in a
/// `flutter test` environment.
class InMemoryTokenStore implements TokenStore {
  InMemoryTokenStore({AuthTokens? initial, String deviceId = 'test-device'})
    : _tokens = initial,
      _deviceId = deviceId;

  AuthTokens? _tokens;
  final String _deviceId;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;

  @override
  Future<String> deviceId() async => _deviceId;
}
