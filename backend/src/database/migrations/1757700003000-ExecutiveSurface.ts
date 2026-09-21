import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * What the executive mobile surface needs from the schema
 * (`specs/06-mobile-app-spec.md`, EXEC-M-01..07).
 *
 * Three additions, each the smallest that makes a screen truthful:
 *
 * - `notification` — the in-app notification centre
 *   (`specs/09-notifications-spec.md`: "the center is the source of truth,
 *   push is just the interrupt"). One row per recipient per event, with the
 *   kind the centre filters on and the tab a tap should open.
 * - `message_report.resolved_*` — a report is closed by hiding the message or
 *   by dismissing it, and the executive who did so is recorded on the row
 *   itself so the thread can say "closed by …" without joining the audit log.
 * - `attendance_record.note` — the reason an executive gave when correcting a
 *   mark ("the mother called at 11:30"). Free text on the record, because the
 *   correction sheet shows it in the trail beneath the child.
 *
 * `schema.sql` is updated to match, so the spec and the database agree.
 */
export class ExecutiveSurface1757700003000 implements MigrationInterface {
  name = 'ExecutiveSurface1757700003000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      create table if not exists notification (
        id uuid primary key default gen_random_uuid(),
        user_id uuid not null references app_user(id) on delete cascade,
        kind text not null
          check (kind in ('critical', 'request', 'memories', 'security', 'other')),
        title text not null,
        body text,
        destination text
          check (destination in ('groups', 'memories', 'messages', 'announcements', 'notifications')),
        sent_at timestamptz not null default now(),
        read_at timestamptz,
        created_at timestamptz not null default now()
      )
    `);
    await queryRunner.query(
      'create index if not exists notification_user_sent_idx on notification (user_id, sent_at desc)',
    );

    await queryRunner.query(`
      alter table message_report
        add column if not exists resolved_at timestamptz,
        add column if not exists resolved_by uuid references app_user(id),
        add column if not exists resolution text
          check (resolution in ('hidden', 'dismissed'))
    `);

    await queryRunner.query(
      'alter table attendance_record add column if not exists note text',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('alter table attendance_record drop column if exists note');
    await queryRunner.query(`
      alter table message_report
        drop column if exists resolution,
        drop column if exists resolved_by,
        drop column if exists resolved_at
    `);
    await queryRunner.query('drop table if exists notification');
  }
}
