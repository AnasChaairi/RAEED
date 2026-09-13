import 'api_error_code.dart';

/// The single failure type the rest of the app reasons about.
///
/// Data-layer implementations translate every transport, serialization and
/// API failure into one of these subtypes, so no `DioException` — or any other
/// dependency-specific error — ever escapes the data layer into application or
/// presentation code. Swapping the HTTP client stays a data-layer change.
///
/// These are thrown rather than returned: Riverpod's `AsyncValue` already
/// captures thrown errors with their stack traces, and wrapping every call in
/// a `Result` on top of that buys ceremony, not safety.
sealed class RaeedException implements Exception {
  const RaeedException({required this.message, this.cause, this.stackTrace});

  /// A developer-facing description. Never rendered to a user directly —
  /// presentation maps the exception to a localized string instead, because
  /// this text is not translated and may carry technical detail.
  final String message;

  /// The underlying error, kept for Sentry breadcrumbs.
  final Object? cause;

  /// The originating stack trace, where one was available.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// The device could not reach the API at all — no connectivity, DNS failure,
/// connection refused, or a timeout before any response arrived.
///
/// Distinct from [ApiException] on purpose: this is the case where a queued
/// retry is appropriate and the UI degrades to cached data, rather than
/// telling the user something went wrong.
final class NetworkException extends RaeedException {
  const NetworkException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// The API answered with a failure envelope.
///
/// Carries the parsed [code] from the catalog in `specs/04-api/conventions.md`
/// plus the raw [details] map, which for `validation.failed` holds the
/// per-field errors.
final class ApiException extends RaeedException {
  const ApiException({
    required this.code,
    required super.message,
    this.statusCode,
    this.details = const <String, Object?>{},
    super.cause,
    super.stackTrace,
  });

  /// The machine-readable error code. Branch on this, never on [message].
  final ApiErrorCode code;

  /// The HTTP status that accompanied the error, when one was available.
  final int? statusCode;

  /// The error's `details` object — field errors, the offending `child_id` for
  /// `memories.consent_blocked`, and so on.
  final Map<String, Object?> details;

  /// Whether this failure is the caller being outside their permission scope.
  ///
  /// Scope failures are terminal: retrying, refreshing the token, or asking
  /// again with the same identifiers will never succeed, so the UI shows a
  /// "not available to you" state rather than a retry affordance.
  bool get isScopeFailure => code == ApiErrorCode.scopeForbidden;

  @override
  String toString() =>
      'ApiException(${code.wireValue}, status: $statusCode): $message';
}

/// The access token was missing, expired, or rejected, and the refresh attempt
/// did not recover it.
///
/// Always ends the session and returns the user to `/login`.
final class UnauthenticatedException extends RaeedException {
  const UnauthenticatedException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// A response that did not match the contract in
/// `specs/04-api/openapi.yaml` — a missing required field, or a type the app
/// cannot decode.
///
/// Surfaced loudly in debug and reported to Sentry in release: it means the
/// client and the contract have drifted, which is a bug on one side or the
/// other, not a user-facing condition to paper over.
final class ContractException extends RaeedException {
  const ContractException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// A failure in on-device storage — the Drift database or secure storage.
final class LocalStorageException extends RaeedException {
  const LocalStorageException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}
