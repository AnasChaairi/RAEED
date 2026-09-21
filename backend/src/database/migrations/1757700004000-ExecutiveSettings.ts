import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * A display name for users.
 *
 * `app_user` had no name column, and every screen that shows a person —
 * the guardian on a child's profile, the educator on a group, who recorded
 * or corrected a mark, who sent a message — rendered blank rather than fall
 * back to the phone number, which `MSG-06` forbids showing. The executive's
 * settings pages (EXEC-M-08..13) create guardians by name and list them by
 * name, so the column lands now. Nullable: existing accounts keep working
 * and render an empty name until an executive fills it in.
 *
 * `schema.sql` is updated to match.
 */
export class ExecutiveSettings1757700004000 implements MigrationInterface {
  name = 'ExecutiveSettings1757700004000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'alter table app_user add column if not exists display_name text',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('alter table app_user drop column if exists display_name');
  }
}
