/// The OTP rules from `specs/10-security-and-privacy.md`, as constants the UI
/// can read.
///
/// **These are not the enforcement point.** Per `CLAUDE.md`, business logic is
/// never duplicated between mobile and backend: the server applies the per-IP
/// and per-number rate limits, decides whether a code is still valid, and is
/// the only thing that can answer `auth.otp_rate_limited`. What lives here is
/// the *shape* of those rules, so the app can render an honest countdown and
/// stop a user from burning their fourth and fifth attempt on a double-tap —
/// and so that when the server does refuse, the refusal is not a surprise.
library;

import 'package:meta/meta.dart';

import 'moroccan_phone_number.dart';

/// The OTP parameters, mirroring `specs/10-security-and-privacy.md`.
abstract final class OtpPolicy {
  /// A code is six digits.
  static const int codeLength = 6;

  /// A code is valid for five minutes from issue.
  static const Duration expiry = Duration(minutes: 5);

  /// At most five requests per hour per number. The server enforces it; the
  /// app counts alongside so the resend affordance can disable itself instead
  /// of walking the user into a 429.
  static const int maxRequestsPerHour = 5;

  /// The window the [maxRequestsPerHour] budget is measured over.
  static const Duration rateLimitWindow = Duration(hours: 1);

  /// How long the resend action stays disabled after a request.
  ///
  /// Not in the spec — a UX guard rail. With only five requests an hour, a
  /// user who taps "resend" three times while the first SMS is in flight has
  /// spent most of their budget on one delivery.
  static const Duration resendCooldown = Duration(seconds: 60);

  /// Whether [code] is shaped like a code the server could accept.
  ///
  /// Only a length-and-digits check: whether the code is *correct* is a server
  /// question, answered by `auth.otp_invalid`.
  static bool isWellFormedCode(String code) =>
      code.length == codeLength && RegExp(r'^\d+$').hasMatch(code);
}

/// The outcome of a successful `POST /auth/otp/request`.
///
/// Carries no code and no delivery metadata — the app is told only that a code
/// was sent, and when it may ask again.
@immutable
class OtpRequestReceipt {
  const OtpRequestReceipt({
    required this.phone,
    required this.requestedAt,
    required this.requestsMade,
  });

  /// Where the code was sent. Rendered only through
  /// [MoroccanPhoneNumber.masked].
  final MoroccanPhoneNumber phone;

  /// When the request was accepted, by the device's clock.
  final DateTime requestedAt;

  /// How many requests this device has made for [phone] within the current
  /// [OtpPolicy.rateLimitWindow], including this one.
  final int requestsMade;

  /// When the code stops being accepted.
  DateTime get expiresAt => requestedAt.add(OtpPolicy.expiry);

  /// The earliest moment a resend should be offered.
  DateTime get resendAvailableAt => requestedAt.add(OtpPolicy.resendCooldown);

  /// Whether this device has spent the hourly budget for [phone].
  ///
  /// A client-side count, so it is only ever advisory — a user who reinstalls
  /// or switches devices resets it, and the server does not.
  bool get hasExhaustedLocalBudget =>
      requestsMade >= OtpPolicy.maxRequestsPerHour;

  /// Seconds left on the resend cooldown at [now], floored at zero.
  int resendCountdownSeconds(DateTime now) {
    final remaining = resendAvailableAt.difference(now).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// A copy recording one more request at [at].
  OtpRequestReceipt resent(DateTime at) => OtpRequestReceipt(
    phone: phone,
    requestedAt: at,
    requestsMade: requestsMade + 1,
  );
}
