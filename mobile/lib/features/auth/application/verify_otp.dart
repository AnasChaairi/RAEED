import '../../../core/session/app_session.dart';
import '../../../core/session/session_controller.dart';
import '../domain/auth_repository.dart';
import '../domain/moroccan_phone_number.dart';
import '../domain/otp_policy.dart';

/// Exchanges a one-time code for a session.
///
/// Owns the one ordering that matters: tokens are persisted by the repository
/// *before* the session controller is told anyone is signed in. Announcing the
/// session first would leave a window in which the router has moved on to
/// `/consent` while the interceptor still has no token to attach, and every
/// request that screen makes would 401.
class VerifyOtp {
  const VerifyOtp({
    required AuthRepository repository,
    required SessionController session,
  }) : _repository = repository,
       _session = session;

  final AuthRepository _repository;
  final SessionController _session;

  /// Verifies [code] for [phone] and starts the session.
  ///
  /// Returns the signed-in user. Throws `ArgumentError` for a code that is not
  /// six digits — the screen prevents that, and reaching the network with a
  /// malformed code would spend an attempt against the server's verify limit
  /// for nothing.
  Future<SessionUser> call({
    required MoroccanPhoneNumber phone,
    required String code,
  }) async {
    if (!OtpPolicy.isWellFormedCode(code)) {
      // The code itself is never included: `specs/10-security-and-privacy.md`
      // lists OTP codes among what must never be logged, and an ArgumentError's
      // message is exactly the kind of thing that reaches a crash report.
      throw ArgumentError.value(
        '<redacted>',
        'code',
        'must be ${OtpPolicy.codeLength} digits',
      );
    }

    final user = await _repository.verifyOtp(phone: phone, code: code);
    await _session.onSignedIn(user);
    return user;
  }
}
