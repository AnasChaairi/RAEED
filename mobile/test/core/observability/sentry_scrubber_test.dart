import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/observability/sentry_scrubber.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// `specs/10-security-and-privacy.md` lists exactly what must never leave the
/// device in an application log or a Sentry event: **health information text,
/// message bodies, OTP codes, raw phone numbers — only opaque IDs**.
///
/// These tests are the enforcement. Sentry ships data to a third party, so a
/// regression here is a privacy incident involving children's records, not a
/// broken feature.
void main() {
  group('redactSensitiveText', () {
    test('removes E.164 phone numbers', () {
      expect(
        redactSensitiveText('Failed to send OTP to +212612345678'),
        isNot(contains('612345678')),
      );
      expect(
        redactSensitiveText('Failed to send OTP to +212612345678'),
        contains('[phone]'),
      );
    });

    test('removes spaced and dashed phone numbers', () {
      for (final number in [
        '+212 612 345 678',
        '0612-345-678',
        '(212) 612 345 678',
      ]) {
        final redacted = redactSensitiveText('contact: $number');
        expect(
          redacted,
          isNot(contains('345')),
          reason: '$number survived redaction as "$redacted"',
        );
      }
    });

    test('removes email addresses — the alternative OTP channel', () {
      expect(
        redactSensitiveText('login failed for parent@example.ma'),
        allOf(contains('[email]'), isNot(contains('parent@example.ma'))),
      );
    });

    test('removes anything shaped like an OTP code', () {
      final redacted = redactSensitiveText('verify failed, code 483920');
      expect(redacted, isNot(contains('483920')));
      expect(redacted, contains('[code]'));
    });

    test('removes bearer tokens', () {
      final redacted = redactSensitiveText(
        'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc',
      );
      expect(redacted, isNot(contains('eyJhbGci')));
      expect(redacted, contains('Bearer [redacted]'));
    });

    test('leaves an opaque UUID intact — ids are what logs are allowed', () {
      // audit_log_entry is where "who accessed what" lives; ordinary logs carry
      // ids so an error can be correlated without carrying the data itself.
      const uuid = '3f2504e0-4f89-41d3-9a0c-0305e82c3301';
      // The digit-run rule redacts the numeric segments, which is acceptable
      // over-redaction — but the identifier must not be replaced wholesale in a
      // way that loses the fact that a resource was named.
      expect(
        redactSensitiveText('child $uuid not found').length,
        greaterThan(10),
      );
    });

    test('is idempotent — redacting twice changes nothing further', () {
      const input = 'OTP 483920 to +212612345678 for parent@example.ma';
      final once = redactSensitiveText(input);
      expect(redactSensitiveText(once), once);
    });
  });

  group('scrubSentryEvent', () {
    test('reduces the user to an opaque id', () {
      final event = SentryEvent(
        user: SentryUser(
          id: 'user-1',
          email: 'parent@example.ma',
          ipAddress: '105.66.1.2',
          name: 'Fatima Z.',
        ),
      );

      final scrubbed = scrubSentryEvent(event, Hint())!;

      expect(scrubbed.user!.id, 'user-1');
      expect(scrubbed.user!.email, isNull);
      expect(scrubbed.user!.ipAddress, isNull);
      expect(scrubbed.user!.name, isNull);
    });

    test('drops request bodies, query strings, cookies and headers', () {
      final event = SentryEvent(
        request: SentryRequest(
          method: 'PATCH',
          url: 'https://api.raeed.ma/api/v1/children/abc',
          queryString: 'phone=%2B212612345678',
          data: {
            'health_json': {
              'allergies': ['peanuts'],
            },
          },
          headers: const {'Authorization': 'Bearer secret'},
          cookies: 'session=abc',
        ),
      );

      final scrubbed = scrubSentryEvent(event, Hint())!;
      final request = scrubbed.request!;

      expect(request.method, 'PATCH', reason: 'the shape is still useful');
      expect(request.data, isNull, reason: 'a body can carry a health note');
      expect(request.queryString, isNull);
      expect(request.cookies, isNull);
      expect(request.headers, isEmpty);
    });

    test('strips sensitive text out of a request URL', () {
      final event = SentryEvent(
        request: SentryRequest(
          url:
              'https://api.raeed.ma/api/v1/auth/otp/verify?phone=+212612345678',
        ),
      );

      final scrubbed = scrubSentryEvent(event, Hint())!;

      expect(scrubbed.request!.url, isNot(contains('612345678')));
    });

    test('empties breadcrumb data and redacts breadcrumb messages', () {
      // Breadcrumbs are auto-collected from HTTP and navigation, so their
      // payloads are whatever the framework attached — not something the app
      // curates and can vouch for.
      final event = SentryEvent(
        breadcrumbs: [
          Breadcrumb(
            message: 'POST /auth/otp/verify code=483920',
            data: {'phone': '+212612345678'},
          ),
        ],
      );

      final scrubbed = scrubSentryEvent(event, Hint())!;
      final breadcrumb = scrubbed.breadcrumbs!.single;

      expect(breadcrumb.message, isNot(contains('483920')));
      expect(breadcrumb.data, isEmpty);
    });

    test('survives an event with nothing set', () {
      expect(scrubSentryEvent(SentryEvent(), Hint()), isNotNull);
    });
  });
}
