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
import 'package:raeed/features/auth/presentation/auth_providers.dart';
import 'package:raeed/features/auth/presentation/change_password_screen.dart';
import 'package:raeed/features/auth/presentation/consent_screen.dart';
import 'package:raeed/features/auth/presentation/login_screen.dart';

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
    Future<void> fill(
      WidgetTester tester,
      String phone,
      String password,
    ) async {
      await tester.enterText(find.byKey(const Key('login-phone')), phone);
      await tester.enterText(find.byKey(const Key('login-password')), password);
    }

    testWidgets('rejects an invalid number without calling the server', (
      tester,
    ) async {
      final container = buildContainer();
      await pumpScreen(tester, container, const LoginScreen());

      await fill(tester, '0512345678', 'raeed1');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();

      final l10n = AppL10n.of(tester.element(find.byType(LoginScreen)));
      expect(find.text(l10n.loginPhoneInvalid), findsOneWidget);
      verifyNever(
        () => auth.signIn(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('rejects an ill-shaped password without calling the server', (
      tester,
    ) async {
      final container = buildContainer();
      await pumpScreen(tester, container, const LoginScreen());

      await fill(tester, '0612345678', 'abc');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();

      final l10n = AppL10n.of(tester.element(find.byType(LoginScreen)));
      expect(find.text(l10n.loginPasswordInvalid), findsOneWidget);
      verifyNever(
        () => auth.signIn(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('signs in with the E.164 number and the password', (
      tester,
    ) async {
      final container = buildContainer();
      when(
        () => auth.signIn(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const SessionUser(
          id: 'u1',
          roles: {RaeedRole.parent},
          displayName: 'سعاد',
        ),
      );

      await pumpScreen(tester, container, const LoginScreen());
      await fill(tester, '0612345678', 'raeed1');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();
      await tester.pumpAndSettle();

      final captured = verify(
        () => auth.signIn(
          phone: captureAny(named: 'phone'),
          password: captureAny(named: 'password'),
        ),
      ).captured;
      expect((captured[0] as MoroccanPhoneNumber).e164, '+212612345678');
      expect(captured[1], 'raeed1');
      expect(container.read(sessionControllerProvider).isAuthenticated, isTrue);
    });

    testWidgets('a wrong password stays on the screen with the message', (
      tester,
    ) async {
      final container = buildContainer();
      when(
        () => auth.signIn(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ApiException(
          code: ApiErrorCode.authInvalidCredentials,
          message: 'Wrong.',
        ),
      );

      await pumpScreen(tester, container, const LoginScreen());
      await fill(tester, '0612345678', 'raeed2');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(LoginScreen)));
      expect(find.text(l10n.loginInvalidCredentials), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(container.read(sessionControllerProvider).user, isNull);
    });

    testWidgets('surfaces a lock-out without leaving the screen', (
      tester,
    ) async {
      final container = buildContainer();
      when(
        () => auth.signIn(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ApiException(
          code: ApiErrorCode.authRateLimited,
          message: 'Too many.',
        ),
      );

      await pumpScreen(tester, container, const LoginScreen());
      await fill(tester, '0612345678', 'raeed1');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(LoginScreen)));
      expect(find.text(l10n.loginRateLimited), findsOneWidget);
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

  group('ChangePasswordScreen', () {
    Future<void> fill(
      WidgetTester tester, {
      required String current,
      required String next,
      required String confirm,
    }) async {
      await tester.enterText(find.byKey(const Key('pwd-current')), current);
      await tester.enterText(find.byKey(const Key('pwd-new')), next);
      await tester.enterText(find.byKey(const Key('pwd-confirm')), confirm);
    }

    testWidgets('refuses a mismatch without calling the server', (
      tester,
    ) async {
      final container = buildContainer();
      await pumpScreen(tester, container, const ChangePasswordScreen());

      await fill(tester, current: 'raeed1', next: 'new123', confirm: 'new124');
      await tester.tap(find.byKey(const Key('pwd-submit')));
      await tester.pump();

      final l10n = AppL10n.of(
        tester.element(find.byType(ChangePasswordScreen)),
      );
      expect(find.text(l10n.pwdMismatch), findsOneWidget);
      verifyNever(
        () => auth.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    testWidgets('a wrong current password is shown under that field', (
      tester,
    ) async {
      final container = buildContainer();
      when(
        () => auth.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(
        const ApiException(
          code: ApiErrorCode.authInvalidCredentials,
          message: 'Wrong.',
        ),
      );
      await pumpScreen(tester, container, const ChangePasswordScreen());

      await fill(tester, current: 'wrong1', next: 'new123', confirm: 'new123');
      await tester.tap(find.byKey(const Key('pwd-submit')));
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(
        tester.element(find.byType(ChangePasswordScreen)),
      );
      expect(find.text(l10n.pwdWrongCurrent), findsOneWidget);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets('sends the current and the new password', (tester) async {
      final container = buildContainer();
      when(
        () => auth.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});
      await pumpScreen(tester, container, const ChangePasswordScreen());

      await fill(tester, current: 'raeed1', next: 'new123', confirm: 'new123');
      await tester.tap(find.byKey(const Key('pwd-submit')));
      await tester.pump();

      verify(
        () => auth.changePassword(
          currentPassword: 'raeed1',
          newPassword: 'new123',
        ),
      ).called(1);
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
