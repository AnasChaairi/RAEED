import 'package:sentry_flutter/sentry_flutter.dart';

/// Strips personal data out of an event before it leaves the device.
///
/// `specs/10-security-and-privacy.md` names exactly what must never reach
/// application logs or Sentry: **health information text, message bodies, OTP
/// codes, raw phone numbers — only opaque IDs**. `audit_log_entry` is the one
/// place "who accessed what" is recorded, precisely so ordinary logs do not
/// have to carry that weight.
///
/// This runs as Sentry's `beforeSend`, which is the last point before an event
/// is transmitted, so it catches data that arrived by any route: an exception
/// message, a breadcrumb, a request URL, a user context set elsewhere.
///
/// The redaction is deliberately blunt. A regex that tried to be clever about
/// which digits are a phone number and which are a session count would
/// eventually let one through, and the cost of over-redacting a stack trace is
/// a slightly harder debugging session — against the cost of a child's health
/// note sitting in a third-party error tracker.
SentryEvent? scrubSentryEvent(SentryEvent event, Hint hint) {
  return event
    ..user = _scrubUser(event.user)
    ..request = _scrubRequest(event.request)
    ..breadcrumbs = event.breadcrumbs?.map(_scrubBreadcrumb).toList();
}

/// Keeps only the opaque user id.
///
/// No phone, no email, no IP address — the id is enough to correlate an error
/// with an `audit_log_entry` row, which is where identity actually belongs.
SentryUser? _scrubUser(SentryUser? user) =>
    user == null ? null : SentryUser(id: user.id);

/// Keeps the request's shape, drops everything it carried.
SentryRequest? _scrubRequest(SentryRequest? request) {
  if (request == null) return null;
  // Bodies, query strings, cookies and headers are dropped wholesale by
  // omission: a query string carries ids, a body can carry a message or a
  // health note, and a header can carry the bearer token.
  return SentryRequest(
    method: request.method,
    url: redactSensitiveText(request.url ?? ''),
    headers: const {},
  );
}

/// Redacts a breadcrumb in place.
///
/// `data` is emptied rather than filtered: breadcrumbs are auto-collected from
/// HTTP calls and navigation, so their payloads are whatever the framework
/// decided to attach — not something this app curates and can vouch for.
Breadcrumb _scrubBreadcrumb(Breadcrumb breadcrumb) {
  final message = breadcrumb.message;
  return breadcrumb
    ..message = message == null ? null : redactSensitiveText(message)
    ..data = const <String, dynamic>{};
}

/// Replaces anything that looks like contact information or a code.
///
/// Exposed for testing and for the app's own logging helper, so both paths
/// redact identically.
String redactSensitiveText(String input) {
  var output = input;
  for (final pattern in _sensitivePatterns) {
    output = output.replaceAll(pattern.expression, pattern.replacement);
  }
  return output;
}

class _Redaction {
  const _Redaction(this.expression, this.replacement);

  final RegExp expression;
  final String replacement;
}

final List<_Redaction> _sensitivePatterns = [
  // E.164 and locally-formatted phone numbers, including spaced/dashed forms.
  _Redaction(RegExp(r'\+?\d[\d\s\-().]{7,}\d'), '[phone]'),
  // Email addresses — the alternative OTP channel.
  _Redaction(RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+'), '[email]'),
  // A bare 4–8 digit run, which is the shape of an OTP code.
  _Redaction(RegExp(r'\b\d{4,8}\b'), '[code]'),
  // Bearer tokens, in case one reaches a message or a URL.
  _Redaction(
    RegExp(r'Bearer\s+[\w\-._~+/]+=*', caseSensitive: false),
    'Bearer [redacted]',
  ),
];
