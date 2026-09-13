import 'reflect-metadata';
import { DataSource, DataSourceOptions } from 'typeorm';

import { loadConfig } from '../common/config/env';

/**
 * TypeORM configuration.
 *
 * `synchronize` is off and stays off. The schema is owned by
 * `specs/03-domain-model/schema.sql` and applied through migrations
 * (`specs/07-backend-spec.md`); letting TypeORM infer DDL from entity
 * decorators would quietly diverge from the spec and, on a bad day, drop a
 * column holding children's records because an annotation was mistyped.
 */
export function buildDataSourceOptions(
  { forMigrations = false }: { forMigrations?: boolean } = {},
): DataSourceOptions {
  const config = loadConfig();

  return {
    type: 'postgres',
    // The API connects as `raeed_app`, which has no UPDATE or DELETE on
    // `audit_log_entry` (`AUD-04`). Migrations need the owner role, because
    // creating tables and grants is exactly what the runtime role must not be
    // able to do.
    url: forMigrations ? config.migrationDatabaseUrl : config.databaseUrl,
    entities: [__dirname + '/../modules/**/*.entity.{ts,js}'],
    migrations: [__dirname + '/migrations/*.{ts,js}'],
    migrationsTableName: 'migrations',
    synchronize: false,
    // Timestamps are compared across a phone, the server and another phone —
    // the attendance conflict rule depends on it — so everything is UTC and
    // nothing is reinterpreted in the server's local zone.
    extra: { timezone: 'UTC' },
    logging: config.nodeEnv === 'development' ? ['error', 'warn'] : ['error'],
  };
}

/** Used by the TypeORM CLI for `migration:run` / `migration:revert`. */
export default new DataSource(buildDataSourceOptions({ forMigrations: true }));
