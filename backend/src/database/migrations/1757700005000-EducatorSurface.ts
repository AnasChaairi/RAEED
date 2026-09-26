import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * What the educator's surface (EDU-M-01..10) writes that the schema had no
 * column for.
 *
 * - `session`: the end-of-session summary sent to guardians, and the trace of
 *   a cancellation or a reschedule (reason, the slot it moved from, who).
 * - `session (group_id, starts_at)` is unique among live rows, so generating
 *   sessions from a group's weekly schedule (`SES-02`) is idempotent.
 * - `material.title`, `homework.title`: the educator names what they add.
 * - `post.caption`, `post.media_json`: a post is one story with several
 *   photos, not one row per photo; `storage_key` keeps the first one so
 *   older readers keep working.
 * - `announcement.ack_required`: the "I have read this" request (`ANN-06`).
 *
 * `schema.sql` is updated to match.
 */
export class EducatorSurface1757700005000 implements MigrationInterface {
  name = 'EducatorSurface1757700005000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      alter table session
        add column if not exists summary text,
        add column if not exists summary_sent_at timestamptz,
        add column if not exists cancel_reason text,
        add column if not exists rescheduled_from timestamptz,
        add column if not exists changed_by uuid references app_user(id),
        add column if not exists changed_at timestamptz
    `);
    await queryRunner.query(
      `create unique index if not exists session_group_start_uidx
         on session (group_id, starts_at) where deleted_at is null`,
    );
    await queryRunner.query('alter table material add column if not exists title text');
    await queryRunner.query('alter table homework add column if not exists title text');
    await queryRunner.query(`
      alter table post
        add column if not exists caption text,
        add column if not exists media_json jsonb not null default '[]'::jsonb
    `);
    await queryRunner.query(
      'alter table announcement add column if not exists ack_required boolean not null default false',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('alter table announcement drop column if exists ack_required');
    await queryRunner.query('alter table post drop column if exists media_json, drop column if exists caption');
    await queryRunner.query('alter table homework drop column if exists title');
    await queryRunner.query('alter table material drop column if exists title');
    await queryRunner.query('drop index if exists session_group_start_uidx');
    await queryRunner.query(`
      alter table session
        drop column if exists changed_at,
        drop column if exists changed_by,
        drop column if exists rescheduled_from,
        drop column if exists cancel_reason,
        drop column if exists summary_sent_at,
        drop column if exists summary
    `);
  }
}
