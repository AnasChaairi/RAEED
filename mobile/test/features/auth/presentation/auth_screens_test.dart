import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/app.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/error/api_error_code.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/router/app_router.dart';
import 'package:raeed/core/session/app_session.dart';
import 'package:raeed/core/session/session_controller.dart';
import 'package:raeed/core/session/token_store.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/auth/domain/auth_repository.dart';
import 'package:raeed/features/auth/domain/consent.dart';
import 'package:raeed/features/auth/domain/consent_repository.dart';
import 'package:raeed/features/auth/domain/moroccan_phone_number.dart';
import 'package:raeed/features/auth/domain/otp_policy.dart';
import 'package:raeed/features/auth/presentation/auth_providers.dart';
import 'package:raeed/features/auth/presentation/consent_screen.dart';
import 'package:raeed/features/auth/presentation/login_screen.dart';
import 'package:raeed/features/auth/presentation/otp_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockConsentRepository extends Mock implements ConsentRepository {}

class _NoSessionBootstrapper implements SessionBootstrapper {
  const _NoSessionBootstrapper();

  @override
  Future<SessionUser?> loadCurrentUser() async => null;

  @override
  Future<bool> hasCompletedConsent(SessionUser user) async => false;
}

void main() {
  late _MockAuthRepository auth;
  late _MockConsentRepository consent;

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
    auth = _MockAuthRepository();
    consent = _MockConsentRepository();
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        appScreensProvider.overrideWithValue(appScreensTable),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        sessionBootstrapperProvider.overrideWithValue(
          const _NoSessionBootstrapper(),
        ),
        authRepositoryProvider.overrideWithValue(auth),
        consentRepositoryProvider.overrideWithValue(consent),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Pumps one screen directly, rather than through the router, so a test
  /// exercises the screen without also exercising every guard.
  Future<void> pumpScreen(
    WidgetTester tester,
    ProviderContainer container,
    Widget screen,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: supportedLocalesForTest,
          localizationsDelegates: AppL10n.localizationsDelegates,
          // The real theme, not a stock one: RaeedThemeExtension asserts its
          // own presence precisely so a widget cannot fall back to hardcoded
          // colours, and a test harness must not be the exception.
          theme: RaeedTheme.light(const Locale('ar')),
          home: screen,
        ),
      ),
    );
    await tester.pump();
  }

  group('LoginScreen', () {
    testWidgets('rejects an invalid number without calling the server', (
      tester,
    ) async {
      final container = buildContainer();
      await pumpScreen(tester, container, const LoginScreen());

      await tester.enterText(find.byType(TextField), '0512345678');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      final l10n = AppL10n.of(tester.element(find.byType(LoginScreen)));
      expect(find.text(l10n.loginPhoneInvalid), findsOneWidget);
      verifyNever(() => auth.requestOtp(any()));
    });

    testWidgets('accepts a valid number and requests a code', (tester) async {
      final container = buildContainer();
      when(() => auth.requestOtp(any())).thenAnswer(
        (invocation) async => OtpRequestReceipt(
          phone: invocation.positionalArguments.first as MoroccanPhoneNumber,
          requestedAt: DateTime.now(),
          requestsMade: 1,
        ),
      );

      await pumpScreen(tester, container, const LoginScreen());
      await tester.enterText(find.byType(TextField), '0612345678');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pumpAndSettle();

      final captured =
          verify(() => auth.requestOtp(captureAny())).captured.single
              as MoroccanPhoneNumber;
      expect(captured.e164, '+212612345678');
      expect(container.read(pendingOtpProvider), isNotNull);
    });

    testWidgets('surfaces a rate limit without leaving the screen', (
      tester,
    ) async {
      final container = buildContainer();
      when(() => auth.requestOtp(any())).thenThrow(
        const ApiException(
          code: ApiErrorCode.authOtpRateLimited,
          message: 'Too many.',
        ),
      );

      await pumpScreen(tester, container, const LoginScreen());
      await tester.enterText(find.byType(TextField), '0612345678');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(LoginScreen)));
      expect(find.text(l10n.otpRateLimited), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('shows the "accounts are created by the association" notice', (
      tester,
    ) async {
      // ACC-02: registration is Executive/Admin only, so there is no sign-up
      // link and the screen has to say why.
      final container = buildContainer();
      await pumpScreen(tester, container, const LoginScreen());

      final l10n = AppL10n.of(tester.element(find.byType(LoginScreen)));
      expect(find.text(l10n.loginNoAccountNotice), findsOneWidget);
    });
  });

  group('OtpScreen', () {
    /// Seeds a pending request so the screen has something to verify against.
    void seedPending(ProviderContainer container) {
      container
          .read(pendingOtpProvider.notifier)
          .begin(
            OtpRequestReceipt(
              phone: MoroccanPhoneNumber.tryParse('0612345678')!,
              requestedAt: DateTime.now(),
              requestsMade: 1,
            ),
          );
    }

    testWidgets('shows the number masked, never in full', (tester) async {
      final container = buildContainer();
      seedPending(container);
      await pumpScreen(tester, container, const OtpScreen());

      expect(find.textContaining('•'), findsWidgets);
      expect(
        find.textContaining('612345678'),
        findsNothing,
        reason: 'the full number must never be rendered',
      );
    });

    testWidgets('verifies automatically once the last digit lands', (
      tester,
    ) async {
      final container = buildContainer();
      seedPending(container);
      when(
        () => auth.verifyOtp(
          phone: any(named: 'phone'),
          code: any(named: 'code'),
        ),
      ).thenAnswer(
        (_) async => const SessionUser(
          id: 'user-1',
          roles: {RaeedRole.parent},
          displayName: 'Test',
        ),
      );

      await pumpScreen(tester, container, const OtpScreen());
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      verify(
        () => auth.verifyOtp(
          phone: any(named: 'phone'),
          code: '123456',
        ),
      ).called(1);
    });

    testWidgets('does not submit a partial code', (tester) async {
      final container = buildContainer();
      seedPending(container);

      await pumpScreen(tester, container, const OtpScreen());
      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();

      verifyNever(
        () => auth.verifyOtp(
          phone: any(named: 'phone'),
          code: any(named: 'code'),
        ),
      );
    });

    testWidgets('clears the field and shows an error on a wrong code', (
      tester,
    ) async {
      final container = buildContainer();
      seedPending(container);
      when(
        () => auth.verifyOtp(
          phone: any(named: 'phone'),
          code: any(named: 'code'),
        ),
      ).thenThrow(
        const ApiException(
          code: ApiErrorCode.authOtpInvalid,
          message: 'Wrong.',
        ),
      );

      await pumpScreen(tester, container, const OtpScreen());
      await tester.enterText(find.byType(TextField), '000000');
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(OtpScreen)));
      expect(find.text(l10n.otpInvalid), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
        reason: 'the field clears so the next attempt starts fresh',
      );
    });

    testWidgets('disables resend during the cooldown', (tester) async {
      final container = buildContainer();
      seedPending(container);
      await pumpScreen(tester, container, const OtpScreen());
      await tester.pump(const Duration(milliseconds: 100));

      final resend = tester.widget<TextButton>(find.byType(TextButton));
      expect(
        resend.onPressed,
        isNull,
        reason:
            'with only ${OtpPolicy.maxRequestsPerHour} requests an hour, a '
            'double tap should not spend two of them',
      );
    });
  });

  group('ConsentScreen', () {
    const requirement = ConsentRequirement(
      privacyPolicyAccepted: false,
      children: [
        ConsentChild(id: 'child-1', fullName: 'آدم'),
        ConsentChild(id: 'child-2', fullName: 'مريم'),
      ],
    );

    testWidgets('shows a skeleton while loading, never a bare spinner', (
      tester,
    ) async {
      final container = buildContainer();
      when(consent.loadRequirement).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1), () => requirement),
      );

      await pumpScreen(tester, container, const ConsentScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('every child starts at not-allowed', (tester) async {
      // The safeguarding default: tapping straight through must protect a
      // child, not publish them.
      final container = buildContainer();
      when(consent.loadRequirement).thenAnswer((_) async => requirement);

      await pumpScreen(tester, container, const ConsentScreen());
      await tester.pumpAndSettle();

      final groups = tester
          .widgetList<RadioGroup<ImageRightsLevel>>(
            find.byType(RadioGroup<ImageRightsLevel>),
          )
          .toList();
      expect(groups, hasLength(2));
      for (final group in groups) {
        expect(group.groupValue, ImageRightsLevel.notAllowed);
      }
    });

    testWidgets('submit stays disabled until the privacy policy is accepted', (
      tester,
    ) async {
      final container = buildContainer();
      when(consent.loadRequirement).thenAnswer((_) async => requirement);

      await pumpScreen(tester, container, const ConsentScreen());
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('submits an untouched child as not-allowed', (tester) async {
      final container = buildContainer();
      when(consent.loadRequirement).thenAnswer((_) async => requirement);
      when(() => consent.submit(any())).thenAnswer((_) async {});

      await pumpScreen(tester, container, const ConsentScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      // Two children push the submit button below a 600px viewport — the
      // screen scrolls by design, so the test scrolls with it.
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      final submitted =
          verify(() => consent.submit(captureAny())).captured.single
              as ConsentSubmission;
      expect(submitted.privacyPolicyAccepted, isTrue);
      expect(submitted.imageRights['child-1'], ImageRightsLevel.notAllowed);
      expect(submitted.imageRights['child-2'], ImageRightsLevel.notAllowed);
    });

    testWidgets('records a level the guardian actually chose', (tester) async {
      final container = buildContainer();
      when(consent.loadRequirement).thenAnswer((_) async => requirement);
      when(() => consent.submit(any())).thenAnswer((_) async {});

      await pumpScreen(tester, container, const ConsentScreen());
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(ConsentScreen)));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      // The first child's "allowed" option, scrolled into view first.
      await tester.ensureVisible(
        find.text(l10n.consentImageRightsAllowed).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.consentImageRightsAllowed).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      final submitted =
          verify(() => consent.submit(captureAny())).captured.single
              as ConsentSubmission;
      expect(submitted.imageRights['child-1'], ImageRightsLevel.allowed);
      expect(
        submitted.imageRights['child-2'],
        ImageRightsLevel.notAllowed,
        reason: 'choosing for one child must not change another',
      );
    });
  });
}

/// The locales the app ships, duplicated here to avoid importing the whole
/// locale controller into a widget test.
const List<Locale> supportedLocalesForTest = [
  Locale('ar'),
  Locale('fr'),
  Locale('en'),
];
