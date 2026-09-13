import '../../core/error/api_error_code.dart';
import '../../core/error/raeed_exception.dart';
import '../../core/l10n/generated/app_localizations.dart';

/// A failure, translated for a person to read.
class PresentedFailure {
  const PresentedFailure({
    required this.title,
    required this.body,
    required this.isRetryable,
  });

  /// A short headline.
  final String title;

  /// One sentence explaining what to do next.
  final String body;

  /// Whether offering a retry makes sense.
  ///
  /// False for permission and contract failures: retrying the identical
  /// request will fail identically, and a retry button that never works
  /// teaches people to distrust the app.
  final bool isRetryable;
}

/// Turns a thrown error into something a user can read.
///
/// Centralised so no screen invents its own wording for a failure, and so the
/// rules about *what may be shown* hold everywhere at once:
///
/// * The server's `message` is never rendered. It is not translated into the
///   user's locale, and for an error like `attendance.already_recorded` it can
///   name another educator — surfacing staff names into a parent's UI is not
///   something a screen should be able to do by accident.
/// * An unexpected error is described generically. Exception text can carry
///   health information, a message body, or a phone number, none of which may
///   leave the device's logs (`specs/10-security-and-privacy.md`) let alone
///   appear on screen.
PresentedFailure presentFailure(Object error, AppL10n l10n) => switch (error) {
  NetworkException() => PresentedFailure(
    title: l10n.errorNetworkTitle,
    body: l10n.errorNetworkBody,
    isRetryable: true,
  ),
  UnauthenticatedException() => PresentedFailure(
    title: l10n.errorSessionExpiredTitle,
    body: l10n.errorSessionExpiredBody,
    isRetryable: false,
  ),
  ContractException() => PresentedFailure(
    title: l10n.errorContractTitle,
    body: l10n.errorContractBody,
    isRetryable: false,
  ),
  ApiException(code: ApiErrorCode.scopeForbidden) => PresentedFailure(
    title: l10n.errorForbiddenTitle,
    body: l10n.errorForbiddenBody,
    isRetryable: false,
  ),
  ApiException(code: ApiErrorCode.authOtpInvalid) => PresentedFailure(
    title: l10n.errorGenericTitle,
    body: l10n.otpInvalid,
    isRetryable: true,
  ),
  ApiException(code: ApiErrorCode.authOtpRateLimited) => PresentedFailure(
    title: l10n.errorGenericTitle,
    body: l10n.otpRateLimited,
    isRetryable: false,
  ),
  _ => PresentedFailure(
    title: l10n.errorGenericTitle,
    body: l10n.errorGenericBody,
    isRetryable: true,
  ),
};
