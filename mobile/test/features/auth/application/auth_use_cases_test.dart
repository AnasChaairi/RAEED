import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/error/api_error_code.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/core/session/app_session.dart';
import 'package:raeed/core/session/session_controller.dart';
import 'package:raeed/core/session/token_store.dart';
import 'package:raeed/features/auth/application/capture_consent.dart';
import 'package:raeed/features/auth/application/refresh_tokens.dart';
import 'package:raeed/features/auth/application/request_otp.dart';
import 'package:raeed/features/auth/application/sign_out.dart';
import 'package:raeed/features/auth/application/verify_otp.dart';
import 'package:raeed/features/auth/domain/auth_repository.dart';
import 'package:raeed/features/auth/domain/consent.dart';
import 'package:raeed/features/auth/domain/consent_repository.dart';
import 'package:raeed/features/auth/domain/moroccan_phone_number.dart';
import 'package:raeed/features/auth/domain/otp_policy.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockConsentRepository extends Mock implements ConsentRepository {}

/// Reports "no stored session", so `SessionController.build`'s restore resolves
/// to signed-out instead of throwing on the unfilled seam.
class _NoSessionBootstrapper implements SessionBootstrapper {
  const _NoSessionBootstrapper();

  @override
  Future<SessionUser?> loadCurrentUser() async => null;

  @override
  Future<bool> hasCompletedConsent(SessionUser user) async => false;
}

void main() {
  late MoroccanPhoneNumber phone;
  late SessionUser user;

  setUpAll(() {
    registerFallbackValue(MoroccanPhoneNumber.tryParse('0600000000')!);
    registerFallbackValue(
      const ConsentSubmission(
        privacyPolicyAccepted: true,
        imageRights: <String, ImageRightsLevel>{},
      ),
    );
  });

  setUp(() {
    phone = MoroccanPhoneNumber.tryParse('0612345678')!;
    user = const SessionUser(
      id: 'user-1',
      roles: {RaeedRole.parent},
      displayName: 'Test Parent',
      reachableChildIds: {'child-1'},
    );
  });

  /// A container with the session controller wired to an in-memory store, so
  /// the use cases drive the real controller rather than a stub of it.
  ProviderContainer containerWithSession() {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        sessionBootstrapperProvider.overrideWithValue(
          const _NoSessionBootstrapper(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('RequestOtp', () {
    test('sends a code and returns a receipt', () async {
      final repository = _MockAuthRepository();
      final receipt = OtpRequestReceipt(
        phone: phone,
        requestedAt: DateTime(2026, 9, 13, 10),
        requestsMade: 1,
      );
      when(() => repository.requestOtp(phone)).thenAnswer((_) async => receipt);

      final result = await RequestOtp(repository)(phone);

      expect(result.phone, phone);
      expect(result.requestsMade, 1);
      verify(() => repository.requestOtp(phone)).called(1);
    });

    test('carries the request count across a resend', () async {
      // The hourly budget is five; a resend that reset the count to one would
      // let the app walk the user into a 429 it could have predicted.
      final repository = _MockAuthRepository();
      final previous = OtpRequestReceipt(
        phone: phone,
        requestedAt: DateTime(2026, 9, 13, 10),
        requestsMade: 2,
      );
      when(() => repository.requestOtp(phone)).thenAnswer(
        (_) async => OtpRequestReceipt(
          phone: phone,
          requestedAt: DateTime(2026, 9, 13, 10, 1),
          requestsMade: 1,
        ),
      );

      final result = await RequestOtp(repository)(phone, previous: previous);

      expect(result.requestsMade, 3);
    });

    test(
      'refuses without a round trip once the local budget is spent',
      () async {
        final repository = _MockAuthRepository();
        final spent = OtpRequestReceipt(
          phone: phone,
          requestedAt: DateTime(2026, 9, 13, 10),
          requestsMade: OtpPolicy.maxRequestsPerHour,
        );

        await expectLater(
          RequestOtp(repository)(phone, previous: spent),
          throwsA(isA<LocalOtpRateLimit>()),
        );
        verifyNever(() => repository.requestOtp(any()));
      },
    );

    test('does not carry a count across a different number', () async {
      final repository = _MockAuthRepository();
      final other = MoroccanPhoneNumber.tryParse('0612345679')!;
      final spent = OtpRequestReceipt(
        phone: other,
        requestedAt: DateTime(2026, 9, 13, 10),
        requestsMade: OtpPolicy.maxRequestsPerHour,
      );
      when(() => repository.requestOtp(phone)).thenAnswer(
        (_) async => OtpRequestReceipt(
          phone: phone,
          requestedAt: DateTime(2026, 9, 13, 10, 1),
          requestsMade: 1,
        ),
      );

      final result = await RequestOtp(repository)(phone, previous: spent);

      expect(
        result.requestsMade,
        1,
        reason: "one number's spent budget must not block another",
      );
    });

    test('propagates the server rate limit', () async {
      final repository = _MockAuthRepository();
      when(() => repository.requestOtp(phone)).thenThrow(
        const ApiException(
          code: ApiErrorCode.authOtpRateLimited,
          message: 'Too many.',
        ),
      );

      await expectLater(
        RequestOtp(repository)(phone),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.authOtpRateLimited,
          ),
        ),
      );
    });
  });

  group('VerifyOtp', () {
    test('starts the session on success', () async {
      final container = containerWithSession();
      final repository = _MockAuthRepository();
      when(() => repository.verifyOtp(phone: phone, code: '123456'))
          .thenAnswer((_) async => user);

      final verify = VerifyOtp(
        repository: repository,
        session: container.read(sessionControllerProvider.notifier),
      );
      await verify(phone: phone, code: '123456');

      final session = container.read(sessionControllerProvider);
      expect(session.user, user);
      expect(session.isAuthenticated, isTrue);
    });

    test(
      'rejects a malformed code without spending a server attempt',
      () async {
        final container = containerWithSession();
        final repository = _MockAuthRepository();
        final verify = VerifyOtp(
          repository: repository,
          session: container.read(sessionControllerProvider.notifier),
        );

        for (final code in <String>['', '123', '12345', '1234567', 'abcdef']) {
          await expectLater(
            verify(phone: phone, code: code),
            throwsA(isA<ArgumentError>()),
            reason: '"$code" is not a well-formed code',
          );
        }
        verifyNever(
          () => repository.verifyOtp(
            phone: any(named: 'phone'),
            code: any(named: 'code'),
          ),
        );
      },
    );

    test('never puts the code in the error it throws', () async {
      // specs/10-security-and-privacy.md lists OTP codes among what must never
      // be logged, and an ArgumentError's message reaches crash reports.
      final container = containerWithSession();
      final verify = VerifyOtp(
        repository: _MockAuthRepository(),
        session: container.read(sessionControllerProvider.notifier),
      );

      try {
        await verify(phone: phone, code: '999');
        fail('expected an ArgumentError');
      } on ArgumentError catch (error) {
        expect(error.toString(), isNot(contains('999')));
        expect(error.toString(), contains('redacted'));
      }
    });

    test('leaves the session untouched when the code is wrong', () async {
      final container = containerWithSession();
      final repository = _MockAuthRepository();
      when(() => repository.verifyOtp(phone: phone, code: '123456')).thenThrow(
        const ApiException(
          code: ApiErrorCode.authOtpInvalid,
          message: 'Wrong code.',
        ),
      );

      final verify = VerifyOtp(
        repository: repository,
        session: container.read(sessionControllerProvider.notifier),
      );

      await expectLater(
        verify(phone: phone, code: '123456'),
        throwsA(isA<ApiException>()),
      );
      expect(container.read(sessionControllerProvider).user, isNull);
    });
  });

  group('CaptureConsent', () {
    late ConsentRequirement requirement;

    setUp(() {
      requirement = const ConsentRequirement(
        privacyPolicyAccepted: false,
        children: [
          ConsentChild(id: 'child-1', fullName: 'آدم'),
          ConsentChild(id: 'child-2', fullName: 'مريم'),
        ],
      );
    });

    test('submits every displayed child, defaulting untouched ones to '
        'not-allowed', () async {
      // The safeguarding default. A guardian who scrolls past a child must not
      // thereby publish them.
      final container = containerWithSession();
      final repository = _MockConsentRepository();
      when(() => repository.submit(any())).thenAnswer((_) async {});

      await CaptureConsent(
        repository: repository,
        session: container.read(sessionControllerProvider.notifier),
      )(
        requirement: requirement,
        submission: const ConsentSubmission(
          privacyPolicyAccepted: true,
          // Only child-1 was touched.
          imageRights: {'child-1': ImageRightsLevel.allowed},
        ),
      );

      final captured =
          verify(() => repository.submit(captureAny())).captured.single
              as ConsentSubmission;
      expect(captured.imageRights['child-1'], ImageRightsLevel.allowed);
      expect(
        captured.imageRights['child-2'],
        ImageRightsLevel.notAllowed,
        reason: 'an untouched child is protected, not published',
      );
      expect(captured.imageRights.length, 2);
    });

    test('refuses to send an unaccepted privacy policy', () async {
      final container = containerWithSession();
      final repository = _MockConsentRepository();

      await expectLater(
        CaptureConsent(
          repository: repository,
          session: container.read(sessionControllerProvider.notifier),
        )(
          requirement: requirement,
          submission: const ConsentSubmission(
            privacyPolicyAccepted: false,
            imageRights: {},
          ),
        ),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => repository.submit(any()));
    });

    test('unlocks the session only after the server accepts', () async {
      final container = containerWithSession();
      final repository = _MockConsentRepository();
      when(() => repository.submit(any()))
          .thenThrow(const NetworkException(message: 'offline'));

      // Drive the session to awaiting-consent first.
      await container.read(sessionControllerProvider.notifier).onSignedIn(user);

      await expectLater(
        CaptureConsent(
          repository: repository,
          session: container.read(sessionControllerProvider.notifier),
        )(
          requirement: requirement,
          submission: const ConsentSubmission(
            privacyPolicyAccepted: true,
            imageRights: {},
          ),
        ),
        throwsA(isA<NetworkException>()),
      );

      expect(
        container.read(sessionControllerProvider).isActive,
        isFalse,
        reason:
            'an optimistic unlock would open the app on a consent that '
            'was never recorded',
      );
    });
  });

  group('RefreshTokens', () {
    test('collapses concurrent refreshes into one rotation', () async {
      // Refresh tokens rotate, so two simultaneous rotations would invalidate
      // each other and sign the user out mid-session.
      final repository = _MockAuthRepository();
      var calls = 0;
      when(repository.refreshSession).thenAnswer((_) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return true;
      });

      final refresh = RefreshTokens(repository);
      final results = await Future.wait([refresh(), refresh(), refresh()]);

      expect(results, everyElement(isTrue));
      expect(calls, 1, reason: 'three callers, one rotation');
    });

    test('allows a fresh attempt after the first completes', () async {
      final repository = _MockAuthRepository();
      when(repository.refreshSession).thenAnswer((_) async => true);

      final refresh = RefreshTokens(repository);
      await refresh();
      await refresh();

      verify(repository.refreshSession).called(2);
    });
  });

  group('SignOut', () {
    test('ends the session', () async {
      final container = containerWithSession();
      final repository = _MockAuthRepository();
      when(repository.signOut).thenAnswer((_) async {});
      await container.read(sessionControllerProvider.notifier).onSignedIn(user);

      await SignOut(
        repository: repository,
        session: container.read(sessionControllerProvider.notifier),
      )();

      expect(
        container.read(sessionControllerProvider).isAuthenticated,
        isFalse,
      );
    });

    test('signs out locally even when the server call fails', () async {
      // Offline sign-out must still sign the user out of *this* device, which
      // is what they asked for.
      final container = containerWithSession();
      final repository = _MockAuthRepository();
      when(repository.signOut)
          .thenThrow(const NetworkException(message: 'offline'));
      await container.read(sessionControllerProvider.notifier).onSignedIn(user);

      await SignOut(
        repository: repository,
        session: container.read(sessionControllerProvider.notifier),
      )();

      expect(
        container.read(sessionControllerProvider).isAuthenticated,
        isFalse,
      );
    });
  });
}
