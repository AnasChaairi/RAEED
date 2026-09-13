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
  readonly otp: {
    /** Empty in local development — codes go to the API's stdout instead. */
    readonly providerApiKey: string;
    readonly smsFallbackApiKey: string;
  };
  readonly fcmServiceAccountJson: string;
  readonly storage: {
    readonly driver: 'local' | 'ovh';
    readonly localRoot: string;
  };
  readonly sentryDsn: string;
  readonly hijriOffsetDays: number;
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
    otp: {
      providerApiKey: env.OTP_PROVIDER_API_KEY ?? '',
      smsFallbackApiKey: env.SMS_FALLBACK_PROVIDER_API_KEY ?? '',
    },
    fcmServiceAccountJson: env.FCM_SERVICE_ACCOUNT_JSON ?? '',
    storage: {
      driver: (env.STORAGE_DRIVER ?? 'local') as 'local' | 'ovh',
      localRoot: env.STORAGE_LOCAL_ROOT ?? '/var/lib/raeed/media',
    },
    sentryDsn: env.SENTRY_DSN ?? '',
    hijriOffsetDays: Number(env.HIJRI_OFFSET_DAYS ?? 0),
  };

  // Console OTP delivery is a development affordance. Outside development it
  // would mean codes are printed to a log nobody guards while the user waits
  // for an SMS that never arrives.
  if (!isDevelopment && config.otp.providerApiKey === '') {
    throw new Error(
      'Refusing to start: OTP_PROVIDER_API_KEY is required outside development.',
    );
  }

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

/** Whether OTP codes are delivered to stdout rather than by SMS. */
export function isConsoleOtpDelivery(config: AppConfig): boolean {
  return config.otp.providerApiKey === '';
}
