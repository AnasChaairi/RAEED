/// Build-time configuration, supplied via `--dart-define`.
///
/// `specs/12-devops-and-environments.md` requires the mobile app to build
/// dev/staging/prod flavours from one codebase via `--dart-define`, and that
/// push notifications never cross environments. Reading configuration from
/// compile-time constants (rather than a bundled `.env` asset) means a release
/// build physically cannot be pointed at a different environment at runtime,
/// and no secret is readable by unzipping the APK.
library;

/// Which deployment the build talks to.
enum AppFlavor {
  /// Local `docker-compose` stack on a developer machine.
  dev,

  /// The shared staging deployment.
  staging,

  /// Production. Diagnostics are minimised and no debug affordance ships.
  prod;

  /// Parses the `RAEED_ENV` define, defaulting to [dev].
  static AppFlavor fromName(String value) => switch (value) {
    'prod' || 'production' => AppFlavor.prod,
    'staging' => AppFlavor.staging,
    _ => AppFlavor.dev,
  };

  /// Whether this flavour may show developer-only affordances.
  bool get isDebugFlavor => this != AppFlavor.prod;
}

/// Immutable, compile-time app configuration.
class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.apiBaseUrl,
    required this.sentryDsn,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  /// Builds the configuration from `--dart-define` values.
  ///
  /// Defaults target the local Docker Compose stack from
  /// `specs/12-devops-and-environments.md`, so a fresh checkout runs with no
  /// extra arguments. `10.0.2.2` is the host machine as seen from an Android
  /// emulator — `localhost` there is the emulator itself.
  factory AppEnvironment.fromDartDefines() {
    const flavorName = String.fromEnvironment('RAEED_ENV', defaultValue: 'dev');
    final flavor = AppFlavor.fromName(flavorName);

    const baseUrl = String.fromEnvironment('RAEED_API_BASE_URL');
    const sentryDsn = String.fromEnvironment('RAEED_SENTRY_DSN');

    return AppEnvironment(
      flavor: flavor,
      apiBaseUrl: baseUrl.isNotEmpty
          ? baseUrl
          : switch (flavor) {
              AppFlavor.dev => 'http://10.0.2.2:3000/api/v1',
              AppFlavor.staging => 'https://staging.raeed.ma/api/v1',
              AppFlavor.prod => 'https://api.raeed.ma/api/v1',
            },
      sentryDsn: sentryDsn,
      // Entry-level Android on a weak connection is the target device, per
      // `specs/11-testing-strategy.md`. These are deliberately patient — the
      // attendance screen queues offline rather than failing fast, so a slow
      // success beats a quick error.
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  /// Which deployment this build talks to.
  final AppFlavor flavor;

  /// Fully-qualified API root, including the `/api/v1` version prefix.
  ///
  /// The version lives in the path per `specs/04-api/conventions.md`; a
  /// breaking change bumps it to `/api/v2`.
  final String apiBaseUrl;

  /// Sentry DSN, or empty when error reporting is disabled for this build.
  final String sentryDsn;

  /// How long to wait for a connection before giving up.
  final Duration connectTimeout;

  /// How long to wait for a response body once connected.
  final Duration receiveTimeout;

  /// Whether crash/error reporting should be initialised.
  bool get isErrorReportingEnabled => sentryDsn.isNotEmpty;
}
