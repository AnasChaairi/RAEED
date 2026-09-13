import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/app.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/l10n/locale_controller.dart';
import 'package:raeed/core/router/app_router.dart';
import 'package:raeed/core/router/app_routes.dart';
import 'package:raeed/core/session/app_session.dart';
import 'package:raeed/core/session/session_bootstrap.dart';
import 'package:raeed/core/session/session_controller.dart';
import 'package:raeed/core/session/token_store.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/auth/presentation/consent_screen.dart';
import 'package:raeed/features/auth/presentation/login_screen.dart';

/// Widget-level checks on the app shell (`RAEED-6`): the routing table and its
/// guards, RTL-by-default, the theme reaching widgets, and the 130%+ text
/// scaling pass required by `specs/11-testing-strategy.md`.
void main() {
  /// Builds the app with a session already resolved, so tests do not race the
  /// splash screen.
  Future<void> pumpApp(
    WidgetTester tester, {
    SessionStatus status = SessionStatus.active,
    Set<RaeedRole> roles = const {RaeedRole.parent},
    Set<String> groups = const {},
    Locale? locale,
    String? initialLocation,
  }) async {
    final container = ProviderContainer(
      overrides: [
        appScreensProvider.overrideWithValue(appScreensTable),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        sessionBootstrapperProvider.overrideWithValue(
          const UnauthenticatedSessionBootstrapper(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Drive the controller to the state under test rather than stubbing the
    // provider, so the real transition logic is exercised.
    if (status != SessionStatus.signedOut) {
      await container
          .read(sessionControllerProvider.notifier)
          .onSignedIn(
            SessionUser(
              id: 'user-1',
              roles: roles,
              displayName: 'Test User',
              reachableChildIds: const {'child-1'},
              reachableGroupIds: groups,
            ),
          );
      if (status == SessionStatus.active) {
        container.read(sessionControllerProvider.notifier).onConsentCompleted();
      }
    } else {
      await container.read(sessionControllerProvider.notifier).signOut();
    }

    if (locale != null) {
      container.read(localeControllerProvider.notifier).setLocale(locale);
    }
    if (initialLocation != null) {
      container.read(appRouterProvider).go(initialLocation);
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RaeedApp()),
    );
    await tester.pumpAndSettle();
  }

  group('directionality', () {
    testWidgets('Arabic is the default and lays out right-to-left', (
      tester,
    ) async {
      await pumpApp(tester);

      final context = tester.element(find.byType(Scaffold).first);
      expect(Localizations.localeOf(context).languageCode, 'ar');
      expect(
        Directionality.of(context),
        TextDirection.rtl,
        reason: 'every layout mirrors under Directionality for Arabic',
      );
    });

    testWidgets('French lays out left-to-right', (tester) async {
      await pumpApp(tester, locale: const Locale('fr'));

      final context = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(context), TextDirection.ltr);
    });

    testWidgets('all three locales resolve their strings', (tester) async {
      for (final locale in supportedLocales) {
        await pumpApp(tester, locale: locale);
        final context = tester.element(find.byType(Scaffold).first);
        expect(
          AppL10n.of(context).appName,
          isNotEmpty,
          reason: '${locale.languageCode} must have strings',
        );
      }
    });
  });

  group('theme', () {
    testWidgets('design tokens reach widgets through the extension', (
      tester,
    ) async {
      await pumpApp(tester);

      final context = tester.element(find.byType(Scaffold).first);
      expect(context.palette.primary, isNotNull);
      expect(context.type.body.fontSize, 16);
      expect(
        context.type.readingFamily,
        'Amiri',
        reason: 'Arabic body copy is set in Amiri',
      );
    });

    testWidgets('the Latin locale switches the reading face to Lora', (
      tester,
    ) async {
      await pumpApp(tester, locale: const Locale('fr'));

      final context = tester.element(find.byType(Scaffold).first);
      expect(context.type.readingFamily, 'Lora');
    });
  });

  group('routing guards', () {
    testWidgets('a signed-out user lands on login', (tester) async {
      await pumpApp(tester, status: SessionStatus.signedOut);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('an unconsented user is held at the consent screen', (
      tester,
    ) async {
      await pumpApp(
        tester,
        status: SessionStatus.awaitingConsent,
        initialLocation: AppRoutes.home,
      );
      expect(
        find.byType(ConsentScreen),
        findsOneWidget,
        reason: 'ACC-06 blocks everything past /consent',
      );
    });

    testWidgets('a consented parent reaches home', (tester) async {
      await pumpApp(tester);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('a parent asking for the dashboard is sent home', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.dashboard);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('an executive reaches the dashboard', (tester) async {
      await pumpApp(
        tester,
        roles: {RaeedRole.executive},
        initialLocation: AppRoutes.dashboard,
      );
      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('a deep link to a child profile resolves its id', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.childPath('child-42'));
      expect(find.text('Child child-42'), findsWidgets);
    });

    testWidgets('an unknown deep link shows the not-found screen', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: '/this/route/does/not/exist');

      final context = tester.element(find.byType(Scaffold).first);
      expect(find.text(AppL10n.of(context).notFoundTitle), findsWidgets);
    });
  });

  group('accessibility', () {
    testWidgets('renders without overflow at 130% text scaling', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: _wrapForScaling(const _ScalingProbe()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('clamps a 200% request down to the supported ceiling', (
      tester,
    ) async {
      // Android permits 2.0×, at which the attendance screen's one-tap chips
      // stop fitting on a small phone at all. The app clamps rather than
      // letting the screen become unusable; this asserts the clamp, not one
      // screen's tolerance for one size.
      late TextScaler effective;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: supportedLocales,
            localizationsDelegates: AppL10n.localizationsDelegates,
            theme: RaeedTheme.light(const Locale('ar')),
            builder: applyTextScaleCeiling,
            home: Builder(
              builder: (context) {
                effective = MediaQuery.textScalerOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(effective.scale(10), 10 * maxTextScaleFactor);
    });

    testWidgets(
      'never scales text up beyond the ceiling, but still scales down',
      (tester) async {
        late TextScaler effective;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(0.8)),
            child: MaterialApp(
              locale: const Locale('ar'),
              supportedLocales: supportedLocales,
              localizationsDelegates: AppL10n.localizationsDelegates,
              theme: RaeedTheme.light(const Locale('ar')),
              builder: applyTextScaleCeiling,
              home: Builder(
                builder: (context) {
                  effective = MediaQuery.textScalerOf(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        expect(
          effective.scale(10),
          8,
          reason:
              'shrinking text is always honoured; only the ceiling is capped',
        );
      },
    );
  });
}

Widget _wrapForScaling(Widget child) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: supportedLocales,
  localizationsDelegates: AppL10n.localizationsDelegates,
  theme: RaeedTheme.light(const Locale('ar')),
  home: child,
);

/// A screen dense enough to catch an overflow: a title, body copy and a
/// full-width primary action, which is the shape most RAEED screens take.
class _ScalingProbe extends StatelessWidget {
  const _ScalingProbe();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(l10n.consentTitle, style: context.type.h1),
            Text(l10n.consentIntro, style: context.type.body),
            const Spacer(),
            FilledButton(onPressed: () {}, child: Text(l10n.consentSubmit)),
          ],
        ),
      ),
    );
  }
}
