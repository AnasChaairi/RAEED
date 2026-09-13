/// The server's error-code catalog, as a closed Dart type.
///
/// Every failure the API returns carries a stable, machine-readable `code`
/// (`specs/04-api/conventions.md`). The app branches on these codes — never on
/// the human-readable `message`, which is localized server-side and may change
/// wording without notice.
///
/// Codes the app does not know about become [ApiErrorCode.unknown] rather than
/// throwing: a backend that ships a new code must never crash an older mobile
/// build, since the mobile release cadence sets the deprecation window, not the
/// backend's.
library;

/// A code from the API's error catalog.
enum ApiErrorCode {
  /// `auth.otp_invalid` — wrong or expired one-time code (401).
  authOtpInvalid('auth.otp_invalid'),

  /// `auth.otp_rate_limited` — too many OTP requests for this number (429).
  authOtpRateLimited('auth.otp_rate_limited'),

  /// `scope.forbidden` — authenticated, but the resource is outside the
  /// caller's ability scope (403).
  ///
  /// The app must treat this as final, never as something to retry with
  /// different parameters.
  scopeForbidden('scope.forbidden'),

  /// `attendance.conflict` — the incoming `recorded_at_client` predates the
  /// server's current record for that child (409).
  ///
  /// Raised by the offline sync path when two devices marked the same child.
  /// The loser is surfaced to the educator, never silently discarded.
  attendanceConflict('attendance.conflict'),

  /// `attendance.unknown_child` — the child is not enrolled in this session's
  /// group (422).
  attendanceUnknownChild('attendance.unknown_child'),

  /// `memories.consent_blocked` — a tagged child's current image-rights level
  /// is `not_allowed` (422).
  memoriesConsentBlocked('memories.consent_blocked'),

  /// `children.last_guardian` — refused to unlink a child's only remaining
  /// guardian (409).
  childrenLastGuardian('children.last_guardian'),

  /// `validation.failed` — DTO-level schema validation failure (422); the
  /// `details` map carries the per-field errors.
  validationFailed('validation.failed'),

  /// A code this build does not recognise, or a transport-level failure with
  /// no code at all.
  unknown('unknown');

  const ApiErrorCode(this.wireValue);

  /// The exact string the API sends.
  final String wireValue;

  /// Resolves a wire value to a known code, falling back to [unknown].
  static ApiErrorCode fromWire(String? value) {
    if (value == null) return ApiErrorCode.unknown;
    for (final code in ApiErrorCode.values) {
      if (code.wireValue == value) return code;
    }
    return ApiErrorCode.unknown;
  }
}
