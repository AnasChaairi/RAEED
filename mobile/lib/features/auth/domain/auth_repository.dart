import '../../../core/session/app_session.dart';
import 'moroccan_phone_number.dart';
import 'otp_policy.dart';

/// Everything the auth feature needs from the outside world.
///
/// Note what is *absent*: no method returns, accepts, or exposes a token.
/// Token custody is a data-layer concern — the implementation writes the pair
/// it was issued straight into the secure `TokenStore` and hands back a
/// [SessionUser]. Keeping tokens out of this interface means no use case, no
/// provider and no widget can hold one, so none of them can log one, pass one
/// into an analytics call, or put one in a route.
///
/// Every method throws a `RaeedException` subtype and nothing else:
/// `NetworkException` when the device cannot reach the server,
/// `ApiException(code: auth.otp_invalid | auth.otp_rate_limited)` for the two
/// outcomes the login flow treats as normal, `UnauthenticatedException` when a
/// session has ended.
abstract interface class AuthRepository {
  /// Asks the server to send a one-time code to [phone].
  ///
  /// Throws `ApiException(code: auth.otp_rate_limited)` when the number has
  /// spent its hourly budget (`specs/10-security-and-privacy.md`).
  Future<OtpRequestReceipt> requestOtp(MoroccanPhoneNumber phone);

  /// Exchanges a code for a session, persisting the issued tokens.
  ///
  /// Returns the signed-in user, ready to hand to
  /// `SessionController.onSignedIn`. Throws
  /// `ApiException(code: auth.otp_invalid)` for a wrong or expired code —
  /// which is an expected outcome, not an error state: the OTP screen stays
  /// put and shows it inline.
  Future<SessionUser> verifyOtp({
    required MoroccanPhoneNumber phone,
    required String code,
  });

  /// Rotates the stored refresh token and persists the new pair.
  ///
  /// Returns false when there was nothing to refresh or the refresh token has
  /// been revoked or expired — in which case the stored pair is cleared and
  /// the session is over.
  Future<bool> refreshSession();

  /// Loads the current user for the stored access token.
  ///
  /// Returns null when there is no usable session, which is how a cold start
  /// distinguishes "returning user" from "signed out".
  Future<SessionUser?> loadCurrentUser();

  /// Revokes this device's session server-side (`ACC-07`) and clears the
  /// stored tokens.
  ///
  /// The local clear happens whether or not the server call succeeds: a
  /// sign-out that fails because the device is offline must still sign the
  /// user out of *this* device, which is what they asked for.
  Future<void> signOut();
}
