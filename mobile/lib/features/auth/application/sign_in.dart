import '../../../core/session/app_session.dart';
import '../../../core/session/session_controller.dart';
import '../domain/auth_repository.dart';
import '../domain/moroccan_phone_number.dart';
import '../domain/password_policy.dart';

/// Exchanges a phone number and password for a session.
///
/// Owns the one ordering that matters: tokens are persisted by the repository
/// *before* the session controller is told anyone is signed in. Announcing the
/// session first would leave a window in which the router has moved on to
/// `/consent` while the interceptor still has no token to attach, and every
/// request that screen makes would 401.
class SignIn {
  const SignIn({
    required AuthRepository repository,
    required SessionController session,
  }) : _repository = repository,
       _session = session;

  final AuthRepository _repository;
  final SessionController _session;

  /// Signs [phone] in with [password] and starts the session.
  ///
  /// Returns the signed-in user. Throws `ArgumentError` for a password that
  /// is not six letters or digits — the screen prevents that, and reaching
  /// the network with a malformed password would spend one of the server's
  /// attempts for nothing.
  Future<SessionUser> call({
    required MoroccanPhoneNumber phone,
    required String password,
  }) async {
    if (!PasswordPolicy.isWellFormed(password)) {
      // The password itself is never included: `specs/10-security-and-privacy.md`
      // lists passwords among what must never be logged, and an ArgumentError's
      // message is exactly the kind of thing that reaches a crash report.
      throw ArgumentError.value(
        '<redacted>',
        'password',
        'must be ${PasswordPolicy.length} letters or digits',
      );
    }

    final user = await _repository.signIn(phone: phone, password: password);
    await _session.onSignedIn(user);
    return user;
  }
}
