/**
 * Environment configuration, validated once at boot.
 *
 * The variable list is `specs/07-backend-spec.md`'s. Validation happens here,
 * eagerly, rather than at each use site: a missing DATABASE_URL should stop the
 * process with one clear message, not surface as a connection error during the
 * first request a parent makes.
 */
export type NodeEnvironment = 'development' | 'test' | 'staging' | 'production';

export interface AppConfig {
  readonly nodeEnv: NodeEnvironment;
  readonly port: number;
  /** The API's own connection — the restricted `raeed_app` role. */
  readonly databaseUrl: string;
  /** The owner connection, used only by the migration CLI. */
  readonly migrationDatabaseUrl: string;
  readonly redisUrl: string;
  readonly jwt: {
    readonly accessSecret: string;
    readonly refreshSecret: string;
    readonly accessTtl: string;
    readonly refreshTtl: string;
  };
  readonly sms: {
    /** Empty until a provider is wired up; critical alerts then have no SMS fallback. */
    readonly fallbackApiKey: string;
  };
  readonly fcmServiceAccountJson: string;
  readonly storage: {
    readonly driver: 'local' | 'ovh';
    readonly localRoot: string;
  };
  readonly sentryDsn: string;
  readonly hijriOffsetDays: number;
  /** ATT-03: when the presence question goes out, and how long parents have. */
  readonly presence: {
    /** Hour of the day before the session, in the association's time zone. */
    readonly sendHour: number;
    /** The deadline sits this many hours before the session starts. */
    readonly deadlineHoursBefore: number;
    /** The one reminder goes to unanswered guardians this long before the deadline. */
    readonly reminderHoursBefore: number;
    /** How often the scheduler looks. */
    readonly tickMinutes: number;
  };
}

/** Placeholder secrets that must never reach a deployed environment. */
const DEVELOPMENT_PLACEHOLDERS = new Set([
  'dev-only-access-secret-change-me',
  'dev-only-refresh-secret-change-me',
]);

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const nodeEnv = (env.NODE_ENV ?? 'development') as NodeEnvironment;
  const isDevelopment = nodeEnv === 'development' || nodeEnv === 'test';

  const accessSecret = required(env, 'JWT_ACCESS_SECRET');
  const refreshSecret = required(env, 'JWT_REFRESH_SECRET');

  // A placeholder secret outside development would mean every deployed token
  // is forgeable by anyone who has read this repository.
  if (!isDevelopment) {
    for (const secret of [accessSecret, refreshSecret]) {
      if (DEVELOPMENT_PLACEHOLDERS.has(secret)) {
        throw new Error(
          'Refusing to start: JWT secrets are still the development ' +
            'placeholders from infrastructure/.env.example.',
        );
      }
    }
  }

  const config: AppConfig = {
    nodeEnv,
    port: Number(env.PORT ?? 3000),
    databaseUrl: required(env, 'DATABASE_URL'),
    // Migrations create tables and grants, which the restricted runtime role
    // deliberately cannot do. Falling back to DATABASE_URL keeps a bare
    // checkout working; a deployed environment sets both.
    migrationDatabaseUrl:
      env.MIGRATION_DATABASE_URL ?? required(env, 'DATABASE_URL'),
    redisUrl: required(env, 'REDIS_URL'),
    jwt: {
      accessSecret,
      refreshSecret,
      // 15 minutes, per specs/10-security-and-privacy.md. Short enough that a
      // stolen access token ages out quickly; the rotating refresh token is
      // what keeps that from being hostile to the user.
      accessTtl: env.JWT_ACCESS_TTL ?? '15m',
      refreshTtl: env.JWT_REFRESH_TTL ?? '30d',
    },
    sms: {
      fallbackApiKey: env.SMS_FALLBACK_PROVIDER_API_KEY ?? '',
    },
    fcmServiceAccountJson: env.FCM_SERVICE_ACCOUNT_JSON ?? '',
    storage: {
      driver: (env.STORAGE_DRIVER ?? 'local') as 'local' | 'ovh',
      // Local development writes next to the checkout; a deployed environment
      // sets the mounted path explicitly.
      localRoot: env.STORAGE_LOCAL_ROOT ?? (isDevelopment ? 'storage' : '/var/lib/raeed/media'),
    },
    sentryDsn: env.SENTRY_DSN ?? '',
    hijriOffsetDays: Number(env.HIJRI_OFFSET_DAYS ?? 0),
    presence: presenceSettings(env),
  };

  return config;
}

function required(env: NodeJS.ProcessEnv, key: string): string {
  const value = env[key];
  if (value === undefined || value === '') {
    throw new Error(
      `Missing required environment variable ${key}. ` +
        'Copy infrastructure/.env.example to infrastructure/.env.local.',
    );
  }
  return value;
}

/**
 * The presence-confirmation timings on their own (ATT-03). Nothing here is
 * required, so the scheduler can read them without the rest of the
 * configuration — and so can a unit test.
 */
export function presenceSettings(env: NodeJS.ProcessEnv = process.env): AppConfig['presence'] {
  return {
    sendHour: Number(env.PRESENCE_SEND_HOUR ?? 18),
    deadlineHoursBefore: Number(env.PRESENCE_DEADLINE_HOURS_BEFORE ?? 2),
    reminderHoursBefore: Number(env.PRESENCE_REMINDER_HOURS_BEFORE ?? 3),
    tickMinutes: Number(env.PRESENCE_TICK_MINUTES ?? 5),
  };
}
