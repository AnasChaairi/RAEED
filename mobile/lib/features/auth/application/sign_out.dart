import '../../../core/error/raeed_exception.dart';
import '../../../core/session/session_controller.dart';
import '../domain/auth_repository.dart';

/// Ends the session on this device.
///
/// `ACC-07` scopes refresh tokens per device and makes them individually
/// revocable, so signing out is a server call (`DELETE
/// /auth/sessions/{deviceId}`) and not merely a local wipe — a token left live
/// on a shared or lost phone is exactly the case that revocation exists for.
///
/// The local side happens regardless of the server's answer. Someone handing
/// their phone to a colleague and tapping sign-out has to end up signed out
/// even with no signal; the stored pair is cleared either way, and the
/// still-live server session expires on its own.
class SignOut {
  const SignOut({
    required AuthRepository repository,
    required SessionController session,
  }) : _repository = repository,
       _session = session;

  final AuthRepository _repository;
  final SessionController _session;

  Future<void> call() async {
    try {
      await _repository.signOut();
    } on RaeedException {
      // Swallowed, not rethrown. The user asked to be signed out of this
      // device and they are — surfacing "couldn't reach the server" on top of
      // a sign-out that visibly worked would read as a failure and invite them
      // to tap again. A server session that outlives the local wipe expires on
      // its own, and revocation can be re-attempted from another device.
      //
      // Only RaeedException is caught: a programming error here should still
      // surface rather than hide behind a sign-out.
    } finally {
      await _session.signOut();
    }
  }
}
