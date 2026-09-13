import '../domain/auth_repository.dart';
import '../domain/moroccan_phone_number.dart';
import '../domain/otp_policy.dart';

/// Sends a one-time code to a phone number.
///
/// Thin on purpose. The one piece of judgement it holds is the local
/// rate-limit budget: the server owns the real limit
/// (`specs/10-security-and-privacy.md`, five requests per hour per number),
/// and this refuses to spend a request the app already knows will be refused,
/// so a user tapping "resend" repeatedly gets an immediate, explanatory
/// refusal instead of burning their remaining attempts on round trips.
class RequestOtp {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  /// Requests a code for [phone].
  ///
  /// [previous] is the receipt from an earlier request for the same number, if
  /// any — passing it carries the request count forward so the hourly budget
  /// is tracked across a resend. Throws
  /// `ApiException(code: auth.otp_rate_limited)` without touching the network
  /// when that budget is already spent.
  Future<OtpRequestReceipt> call(
    MoroccanPhoneNumber phone, {
    OtpRequestReceipt? previous,
  }) async {
    final carried = previous != null && previous.phone == phone
        ? previous
        : null;

    if (carried != null && carried.hasExhaustedLocalBudget) {
      throw const LocalOtpRateLimit();
    }

    final receipt = await _repository.requestOtp(phone);
    // The repository reports a fresh receipt; splice the carried count onto it
    // so a resend does not reset the budget back to one.
    return carried == null ? receipt : carried.resent(receipt.requestedAt);
  }
}

/// Raised when the app's own count says the hourly OTP budget is spent.
///
/// Distinct from the server's `auth.otp_rate_limited` so the difference is
/// visible in a stack trace, but presented identically — from the user's side
/// there is no difference, and inventing a second wording for the same
/// situation would be confusing.
class LocalOtpRateLimit implements Exception {
  const LocalOtpRateLimit();

  @override
  String toString() =>
      'LocalOtpRateLimit: ${OtpPolicy.maxRequestsPerHour} requests already '
      'made within ${OtpPolicy.rateLimitWindow.inHours}h';
}
