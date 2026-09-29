import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * A session has a kind: the weekly حصة, a sport outing or a workshop
 * (ورشة). The educator creates the latter two by hand for a group, at a
 * slot of their choosing; the weekly kind is what the schedule generates.
 *
 * `schema.sql` is updated to match.
 */
export class SessionKind1757700007000 implements MigrationInterface {
  name = 'SessionKind1757700007000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      alter table session
        add column if not exists kind text not null default 'session'
          check (kind in ('session', 'sport', 'workshop'))
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`alter table session drop column if exists kind`);
  }
}
