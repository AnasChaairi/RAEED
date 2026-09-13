import '../../../core/error/raeed_exception.dart';
import '../../../core/session/app_session.dart';
import '../../../core/session/session_controller.dart';
import '../domain/auth_repository.dart';
import '../domain/consent_repository.dart';

/// Restores a returning user's session on cold start (`RAEED-3`).
///
/// Replaces `UnauthenticatedSessionBootstrapper`, which always answered "no
/// session" while the app shell shipped ahead of sign-in.
///
/// The consent answer is the delicate half. It must be **server-resolved**,
/// never cached or inferred: `consent_record` is append-only, two guardians of
/// the same child can hold different levels, and the most-restrictive-wins
/// resolution lives in the backend (`specs/03-domain-model/entities.md`). A
/// client that remembered "this user consented last time" would walk straight
/// past a consent that was since downgraded.
class AuthSessionBootstrapper implements SessionBootstrapper {
  const AuthSessionBootstrapper({
    required AuthRepository auth,
    required ConsentRepository consent,
  }) : _auth = auth,
       _consent = consent;

  final AuthRepository _auth;
  final ConsentRepository _consent;

  @override
  Future<SessionUser?> loadCurrentUser() => _auth.loadCurrentUser();

  @override
  Future<bool> hasCompletedConsent(SessionUser user) async {
    try {
      final requirement = await _consent.loadRequirement();
      return requirement.isSatisfied;
    } on NetworkException {
      // Offline at launch. Answering "yes" would open the whole app on an
      // unverified consent; answering "no" holds the user on `/consent`, which
      // shows its own offline state and a retry. Between wrongly opening
      // children's data and wrongly showing a consent screen, the consent
      // screen is the failure worth having.
      return false;
    }
  }
}
