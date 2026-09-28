import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Sign-in moves from one-time codes to a phone number and a password
 * (`specs/10-security-and-privacy.md`).
 *
 * - `app_user.password_hash`: the scrypt string `PasswordService` writes;
 *   null for an account that has not been handed a password yet, which then
 *   cannot sign in.
 * - `app_user.password_set_at`: when it was last set, so an executive can see
 *   that a guardian never changed the one they were handed.
 *
 * `schema.sql` is updated to match.
 */
export class PasswordSignIn1757700006000 implements MigrationInterface {
  name = 'PasswordSignIn1757700006000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      alter table app_user
        add column if not exists password_hash text,
        add column if not exists password_set_at timestamptz
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      alter table app_user
        drop column if exists password_set_at,
        drop column if exists password_hash
    `);
  }
}
