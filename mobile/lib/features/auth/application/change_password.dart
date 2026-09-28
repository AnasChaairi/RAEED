import '../domain/auth_repository.dart';
import '../domain/password_policy.dart';

/// Replaces the signed-in user's password.
///
/// Thin on purpose: the server checks the current password and owns the
/// rule. What lives here is the refusal to send an ill-shaped new password —
/// the form prevents it, and the server would only answer with a validation
/// error the user has already been shown.
class ChangePassword {
  const ChangePassword(this._repository);

  final AuthRepository _repository;

  /// Throws `ArgumentError` for a new password that is not six letters or
  /// digits; otherwise whatever the repository throws
  /// (`auth.invalid_credentials` for a wrong current password).
  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!PasswordPolicy.isWellFormed(newPassword)) {
      // Never the value itself: passwords must not reach a crash report.
      throw ArgumentError.value(
        '<redacted>',
        'newPassword',
        'must be ${PasswordPolicy.length} letters or digits',
      );
    }
    await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
