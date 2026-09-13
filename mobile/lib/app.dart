import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/l10n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/session/app_session.dart';
import 'core/session/session_controller.dart';
import 'core/theme/raeed_theme.dart';
import 'features/attendance/presentation/attendance_screen.dart';
import 'features/auth/presentation/consent_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/otp_screen.dart';
import 'features/children/presentation/child_profile_screen.dart';
import 'features/children/presentation/home_screen.dart';
import 'shared/widgets/not_found_screen.dart';
import 'shared/widgets/placeholder_screen.dart';
import 'shared/widgets/splash_screen.dart';

/// The app's root widget.
///
/// Holds three responsibilities and no more: theme, locale, and the router.
/// Everything else is reached through providers, so this widget does not grow
/// as features land.
class RaeedApp extends ConsumerWidget {
  const RaeedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final status = ref.watch(
      sessionControllerProvider.select((session) => session.status),
    );

    // While the session is unknown there is nothing to route to, and mounting
    // the router would make it evaluate redirects against a session that does
    // not exist yet. Show the splash and mount the router once we know.
    if (status == SessionStatus.unknown) {
      return _UnroutedApp(locale: locale, child: const SplashScreen());
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppL10n.of(context).appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,
      theme: RaeedTheme.light(locale),
      darkTheme: RaeedTheme.dark(locale),
      builder: applyTextScaleCeiling,
    );
  }
}

/// A [MaterialApp] with no router, for the pre-routing splash.
class _UnroutedApp extends StatelessWidget {
  const _UnroutedApp({required this.locale, required this.child});

  final Locale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: supportedLocales,
    localizationsDelegates: AppL10n.localizationsDelegates,
    theme: RaeedTheme.light(locale),
    darkTheme: RaeedTheme.dark(locale),
    home: child,
  );
}

/// The largest text scale the app honours.
///
/// Exposed so the scaling tests assert the clamp itself rather than a
/// screen's tolerance for one particular size.
const double maxTextScaleFactor = 1.6;

/// Caps text scaling at [maxTextScaleFactor].
///
/// `specs/11-testing-strategy.md` requires the app to hold up at 130%+ text
/// scaling, and it does — but Android allows up to 2.0×, at which the
/// attendance screen's one-tap chips stop fitting on a small phone at all. A
/// ceiling degrades gracefully; no ceiling produces a screen an educator
/// cannot use. The floor is untouched: shrinking text is always honoured.
Widget applyTextScaleCeiling(BuildContext context, Widget? child) {
  final mediaQuery = MediaQuery.of(context);
  return MediaQuery(
    data: mediaQuery.copyWith(
      textScaler: mediaQuery.textScaler.clamp(
        maxScaleFactor: maxTextScaleFactor,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

/// The screens the router renders.
///
/// Routes whose feature has not shipped yet render a [PlaceholderScreen]
/// naming the ticket that will replace them, so the routing table, its guards
/// and every deep link are exercisable from the first commit.
final AppScreens appScreensTable = AppScreens(
  splash: (context, state) => const SplashScreen(),
  login: (context, state) => const LoginScreen(),
  otp: (context, state) => const OtpScreen(),
  consent: (context, state) => const ConsentScreen(),
  home: (context, state) => const HomeScreen(),
  child: (context, state) => ChildProfileScreen(
    childId: state.pathParameters['childId'] ?? '',
    // The sub-tab is the last path segment when one is present.
    initialTab: ChildProfileTab.fromSlug(
      state.uri.pathSegments.length > 2 ? state.uri.pathSegments.last : null,
    ),
  ),
  group: (context, state) => PlaceholderScreen(
    title: 'Group ${state.pathParameters['groupId'] ?? ''}',
    ticket: 'RAEED-8',
  ),
  attendance: (context, state) => AttendanceScreen(
    sessionId: state.pathParameters['sessionId'] ?? '',
    groupId: state.pathParameters['groupId'] ?? '',
  ),
  conversation: (context, state) =>
      const PlaceholderScreen(title: 'Conversation', ticket: 'Epic E'),
  memories: (context, state) =>
      const PlaceholderScreen(title: 'Memories Wall', ticket: 'Epic F'),
  memoriesCompose: (context, state) =>
      const PlaceholderScreen(title: 'New post', ticket: 'Epic F'),
  announcementCompose: (context, state) =>
      const PlaceholderScreen(title: 'New announcement', ticket: 'Epic E'),
  dashboard: (context, state) =>
      const PlaceholderScreen(title: 'Dashboard', ticket: 'Epic G'),
  notFound: (context, state) => const NotFoundScreen(),
);

/// Convenience for tests and previews: the route the app opens on.
const String initialRoute = AppRoutes.home;
