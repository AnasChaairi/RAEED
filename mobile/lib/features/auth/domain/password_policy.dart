/// The one shape a password may have (`specs/10-security-and-privacy.md`).
///
/// Exactly six characters, letters and digits only. Short enough for an
/// executive to hand over in person — which is how accounts are provisioned
/// (`ACC-02`) — and the server's throttle is what makes six characters hold.
/// The rule is mirrored here so the form can refuse an ill-shaped entry
/// without spending one of the server's attempts on it; the server remains
/// the enforcement point.
abstract final class PasswordPolicy {
  /// Length of every password, no more and no less.
  static const int length = 6;

  static final RegExp _shape = RegExp(r'^[A-Za-z0-9]{6}$');

  /// Whether [password] has the shape the server will accept.
  static bool isWellFormed(String password) => _shape.hasMatch(password);
}
