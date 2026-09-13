import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Resolves a contradiction between two parts of the spec.
 *
 * `specs/03-domain-model/schema.sql` puts `unique (session_id, child_id)` on
 * `attendance_record`, while `specs/13-roadmap-and-tickets.md` (RAEED-17) and
 * `specs/03-domain-model/entities.md` both require that a correction "creates a
 * new row with `corrected_from` set, not an update-in-place", so that the
 * attendance trail is queryable without joining `audit_log_entry`.
 *
 * Those cannot both hold: a second row for the same child in the same session
 * is exactly what the unique constraint forbids. Implementing it as written
 * produced a foreign-key violation the first time a mark was corrected, because
 * the only way to satisfy the constraint is to delete the row the new one is
 * supposed to point at.
 *
 * The resolution keeps both intents:
 *
 * - `superseded_at` marks a row as no longer current. The corrected row keeps
 *   its original `status`, `recorded_by`, `recorded_at` and
 *   `recorded_at_client` untouched — nothing about what was recorded is
 *   rewritten, which is what "not an update-in-place" is protecting.
 * - The uniqueness rule becomes *partial*: at most one **current** record per
 *   child per session. That is the invariant the original constraint was
 *   reaching for; applying it to superseded rows as well is what made history
 *   impossible.
 *
 * `schema.sql` is updated to match, so the spec and the database agree again.
 */
export class AttendanceCorrectionHistory1757700002000
  implements MigrationInterface
{
  name = 'AttendanceCorrectionHistory1757700002000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      alter table attendance_record
        add column if not exists superseded_at timestamptz
    `);

    // The constraint name Postgres generates for an inline `unique (...)`.
    await queryRunner.query(`
      alter table attendance_record
        drop constraint if exists attendance_record_session_id_child_id_key
    `);

    await queryRunner.query(`
      create unique index if not exists attendance_record_current_unique
        on attendance_record (session_id, child_id)
        where superseded_at is null
    `);

    // The correction chain is walked from the newest row backwards, so the
    // lookup is by `corrected_from`.
    await queryRunner.query(`
      create index if not exists attendance_record_corrected_from_idx
        on attendance_record (corrected_from)
        where corrected_from is not null
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Restoring the total constraint would fail against any session that has a
    // correction in it, which is the point of the migration. Superseded rows
    // are dropped first, and that loses history — so this is a local-only
    // escape hatch, not something to run where real marks exist.
    await queryRunner.query(
      'delete from attendance_record where superseded_at is not null',
    );
    await queryRunner.query(
      'drop index if exists attendance_record_current_unique',
    );
    await queryRunner.query(
      'drop index if exists attendance_record_corrected_from_idx',
    );
    await queryRunner.query(`
      alter table attendance_record
        add constraint attendance_record_session_id_child_id_key
        unique (session_id, child_id)
    `);
    await queryRunner.query(
      'alter table attendance_record drop column if exists superseded_at',
    );
  }
}
