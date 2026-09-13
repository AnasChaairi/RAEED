import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/config/app_environment.dart';
import 'core/network/api_client_provider.dart';
import 'core/observability/sentry_scrubber.dart';
import 'core/router/app_router.dart';
import 'core/session/session_controller.dart';
import 'features/auth/presentation/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromDartDefines();

  // RAEED is portrait-only. The attendance list, the child cards and the
  // Memories Wall are all vertical lists read one-handed; a landscape layout
  // would be a second set of screens to maintain for no one's benefit.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final container = ProviderContainer(
    overrides: [
      appScreensProvider.overrideWithValue(appScreensTable),
      // The two seams `core` declares and the `auth` feature fills: restoring a
      // session on cold start, and rotating a refresh token. Both are API calls
      // that belong to a feature, wired here so `core` never imports one.
      sessionBootstrapperProvider.overrideWith(
        (ref) => ref.watch(authSessionBootstrapperProvider),
      ),
      authTokenRefresherProvider.overrideWith(
        (ref) => ref.watch(apiAuthTokenRefresherProvider),
      ),
    ],
  );

  final app = UncontrolledProviderScope(
    container: container,
    child: const RaeedApp(),
  );

  if (!environment.isErrorReportingEnabled) {
    runApp(app);
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = environment.sentryDsn;
    options.environment = environment.flavor.name;
    // Never send the user's identity or request/response bodies. RAEED's
    // payloads carry health information, message bodies and phone numbers,
    // none of which may leave the device (specs/10-security-and-privacy.md).
    options.sendDefaultPii = false;
    options.beforeSend = scrubSentryEvent;
    options.tracesSampleRate = environment.flavor == AppFlavor.prod ? 0.1 : 1.0;
    options.debug = kDebugMode;
  }, appRunner: () => runApp(app));
}
