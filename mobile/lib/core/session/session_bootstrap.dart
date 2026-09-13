import 'app_session.dart';
import 'session_controller.dart';

/// The bootstrapper used before the `auth` feature is wired in.
///
/// Reports "no session", which lands every launch on `/login`. The app shell
/// (`RAEED-6`) ships before OTP sign-in (`RAEED-2`/`RAEED-3`), and this makes
/// that ordering explicit and safe: the shell is fully navigable and testable,
/// and there is no code path that could mistake an unwired bootstrapper for a
/// signed-in user.
///
/// Replaced by the auth implementation in `main.dart`'s provider overrides.
class UnauthenticatedSessionBootstrapper implements SessionBootstrapper {
  const UnauthenticatedSessionBootstrapper();

  @override
  Future<SessionUser?> loadCurrentUser() async => null;

  @override
  Future<bool> hasCompletedConsent(SessionUser user) async => false;
}
