import '../domain/auth_repository.dart';

/// Rotates the stored refresh token for a new pair.
///
/// Almost every refresh in the app happens invisibly, inside
/// `AuthInterceptor`, when a 15-minute access token expires mid-use. This use
/// case exists for the explicit cases — a resume from background before making
/// a burst of requests, and the tests that assert rotation actually replaces
/// the stored pair rather than leaving the old refresh token usable.
///
/// Rotation means the previous refresh token stops working the moment this
/// succeeds (`specs/10-security-and-privacy.md`, `ACC-07`), so it must never
/// run concurrently with itself: two rotations racing would invalidate each
/// other and end a perfectly good session. The interceptor single-flights its
/// own refreshes; this one is single-flighted here.
class RefreshTokens {
  RefreshTokens(this._repository);

  final AuthRepository _repository;

  Future<bool>? _inFlight;

  /// Rotates the stored pair, returning false when there is no session left to
  /// refresh.
  ///
  /// Concurrent callers join the in-flight rotation rather than starting a
  /// second one.
  Future<bool> call() {
    final existing = _inFlight;
    if (existing != null) return existing;

    final attempt = _repository.refreshSession();
    _inFlight = attempt;
    return attempt.whenComplete(() => _inFlight = null);
  }
}
