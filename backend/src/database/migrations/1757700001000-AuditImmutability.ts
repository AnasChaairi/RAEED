import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Makes the audit log genuinely append-only at the database level (`AUD-04`).
 *
 * `specs/10-security-and-privacy.md` is specific that this must hold "even
 * against a compromised or buggy app server, not just a well-behaved UI", and
 * `specs/11-testing-strategy.md`'s sixth non-negotiable case tests it against
 * the real grants rather than against application code paths.
 *
 * So the API connects as `raeed_app`, a role with INSERT and SELECT on
 * `audit_log_entry` and nothing else. An attacker who reaches SQL execution
 * through the API still cannot erase the record of what they did — the
 * permission simply is not there.
 *
 * The retention purge in `specs/10-security-and-privacy.md` deletes old entries
 * on a schedule. That runs as `raeed_retention`, a separate role used by
 * nothing else, so the everyday connection never carries delete rights.
 */
export class AuditImmutability1757700001000 implements MigrationInterface {
  name = 'AuditImmutability1757700001000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const database = await currentDatabase(queryRunner);

    // Roles are created only if absent so this migration is safe on a database
    // where an operator provisioned them by hand first.
    await queryRunner.query(`
      do $$
      begin
        if not exists (select from pg_roles where rolname = 'raeed_app') then
          create role raeed_app login password 'local_dev_only';
        end if;
        if not exists (select from pg_roles where rolname = 'raeed_retention') then
          create role raeed_retention login password 'local_dev_only';
        end if;
      end
      $$;
    `);

    await queryRunner.query(
      `grant connect on database "${database}" to raeed_app, raeed_retention`,
    );
    await queryRunner.query('grant usage on schema public to raeed_app, raeed_retention');

    // Everyday application rights across the schema.
    await queryRunner.query(`
      grant select, insert, update, delete
        on all tables in schema public to raeed_app
    `);
    await queryRunner.query(
      'grant usage, select on all sequences in schema public to raeed_app',
    );

    // The exception, and the whole point of this migration.
    await queryRunner.query('revoke update, delete on audit_log_entry from raeed_app');
    await queryRunner.query('grant insert, select on audit_log_entry to raeed_app');

    // Only the retention role may remove audit rows, and the purge logs itself,
    // so the log outlives what it describes deleting.
    await queryRunner.query('grant select, delete on audit_log_entry to raeed_retention');

    // Tables added by later migrations inherit the same defaults.
    await queryRunner.query(`
      alter default privileges in schema public
        grant select, insert, update, delete on tables to raeed_app
    `);
    await queryRunner.query(`
      alter default privileges in schema public
        grant usage, select on sequences to raeed_app
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Reverting restores UPDATE/DELETE on the audit log, which is the one
    // thing this migration exists to prevent. Left implemented so a local
    // developer can unwind it, but it is not something to run anywhere real.
    await queryRunner.query('grant update, delete on audit_log_entry to raeed_app');
  }
}

async function currentDatabase(queryRunner: QueryRunner): Promise<string> {
  const rows: Array<{ current_database: string }> = await queryRunner.query(
    'select current_database()',
  );
  return rows[0].current_database;
}
