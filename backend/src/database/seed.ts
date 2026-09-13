import 'reflect-metadata';
import { DataSource } from 'typeorm';

import { buildDataSourceOptions } from './data-source';

/**
 * Local development seed.
 *
 * Creates one branch, one season, the eight categories from the product scope,
 * two groups, two guardians, one educator, one executive, four children, and
 * today's sessions with an open presence confirmation — enough for every screen
 * the mobile app currently has to show something real.
 *
 * The names are ordinary Moroccan given names and the health notes are
 * deliberately generic. Putting plausible-looking records about actual children
 * into a seed that gets copied between machines is exactly the habit this
 * product exists to replace.
 *
 * Idempotent: re-running truncates and rebuilds, so `npm run seed` is safe to
 * repeat. It refuses to run outside development.
 */
async function seed(): Promise<void> {
  if ((process.env.NODE_ENV ?? 'development') !== 'development') {
    throw new Error('Refusing to seed outside development.');
  }

  // The seed writes structure tables the runtime role can write but should not
  // own, so it connects as the migration/owner role.
  const dataSource = new DataSource(
    buildDataSourceOptions({ forMigrations: true }),
  );
  await dataSource.initialize();

  try {
    await dataSource.transaction(async (tx) => {
      // Order matters only for readability — the truncate cascades.
      await tx.query(`
        truncate table
          audit_log_entry, post_tag, post, album,
          announcement_read, announcement,
          message_report, message, conversation,
          homework_status, homework,
          attendance_record, presence_answer, presence_confirmation,
          material, session,
          profile_change_request, child_group, parent_child, consent_record,
          child, group_educator, "group", role_assignment, user_device,
          app_user, category, season, branch
        restart identity cascade
      `);

      const [{ id: branchId }] = await tx.query(`
        insert into branch (name, address)
        values ('الفرع المركزي', 'الدار البيضاء')
        returning id
      `);

      const [{ id: seasonId }] = await tx.query(`
        insert into season (label, start_date, end_date, status)
        values ('2026-2027', '2026-09-01', '2027-06-30', 'active')
        returning id
      `);

      // The eight category names from the product scope (§5.2). Age ranges and
      // gender stay null: that is open decision #1, and guessing values into
      // the schema is exactly what `specs/01-product-brief.md` says not to do.
      const categoryNames = [
        'الأشبال',
        'النخبة',
        'الفتية',
        'اليافعون',
        'الصغار',
        'الفراشات',
        'الزهرات',
        'اليافعات',
      ];
      const categoryIds: Record<string, string> = {};
      for (const name of categoryNames) {
        const [{ id }] = await tx.query(
          'insert into category (name_ar) values ($1) returning id',
          [name],
        );
        categoryIds[name] = id;
      }

      // Two groups, each meeting twice a week.
      const weeklySchedule = JSON.stringify([
        { weekday: 3, starts_at: '16:00', ends_at: '18:00' },
        { weekday: 6, starts_at: '10:00', ends_at: '12:00' },
      ]);
      const [{ id: ashbalId }] = await tx.query(
        `insert into "group" (name, category_id, season_id, branch_id, capacity, weekly_schedule_json)
         values ('الأشبال أ', $1, $2, $3, 20, $4::jsonb) returning id`,
        [categoryIds['الأشبال'], seasonId, branchId, weeklySchedule],
      );
      const [{ id: zahratId }] = await tx.query(
        `insert into "group" (name, category_id, season_id, branch_id, capacity, weekly_schedule_json)
         values ('الزهرات أ', $1, $2, $3, 20, $4::jsonb) returning id`,
        [categoryIds['الزهرات'], seasonId, branchId, weeklySchedule],
      );

      // --- People ---------------------------------------------------------
      // Phone numbers are documentation-range Moroccan mobiles. In development
      // the OTP is printed to the API's stdout, so no SMS account is needed.
      const [{ id: parentId }] = await tx.query(
        `insert into app_user (phone, preferred_locale) values ('+212600000001', 'ar') returning id`,
      );
      const [{ id: educatorId }] = await tx.query(
        `insert into app_user (phone, preferred_locale) values ('+212600000002', 'ar') returning id`,
      );
      const [{ id: executiveId }] = await tx.query(
        `insert into app_user (phone, preferred_locale) values ('+212600000003', 'ar') returning id`,
      );

      await tx.query(
        `insert into role_assignment (user_id, role) values ($1, 'parent')`,
        [parentId],
      );
      // The educator is also a parent — the common case in a small association,
      // and the one that breaks a UI built around a single role.
      await tx.query(
        `insert into role_assignment (user_id, role) values ($1, 'educator'), ($1, 'parent')`,
        [educatorId],
      );
      await tx.query(
        `insert into role_assignment (user_id, role) values ($1, 'executive')`,
        [executiveId],
      );

      await tx.query(
        `insert into group_educator (group_id, educator_user_id) values ($1, $2)`,
        [ashbalId, educatorId],
      );

      // --- Children -------------------------------------------------------
      const children = [
        { name: 'آدم', dob: '2018-05-02', group: ashbalId, guardian: parentId,
          health: { allergies: ['حساسية من الفول السوداني'], dietary_notes: 'بدون مكسرات' } },
        { name: 'مريم', dob: '2016-11-20', group: zahratId, guardian: parentId,
          health: {} },
        { name: 'يوسف', dob: '2018-02-14', group: ashbalId, guardian: educatorId,
          health: {} },
        { name: 'عمر', dob: '2017-07-09', group: ashbalId, guardian: parentId,
          health: { conditions: ['ربو خفيف'] } },
      ];

      const childIds: string[] = [];
      for (const child of children) {
        const [{ id }] = await tx.query(
          `insert into child (full_name, dob, health_json) values ($1, $2, $3::jsonb) returning id`,
          [child.name, child.dob, JSON.stringify(child.health)],
        );
        childIds.push(id);
        await tx.query(
          `insert into parent_child (guardian_user_id, child_id, relationship_type)
           values ($1, $2, 'parent')`,
          [child.guardian, id],
        );
        await tx.query(
          `insert into child_group (child_id, group_id, is_main) values ($1, $2, true)`,
          [id, child.group],
        );
        // Consent is recorded for every child so the app opens past the
        // consent gate. Image rights start at the most restrictive level —
        // the same default the app applies.
        await tx.query(
          `insert into consent_record (guardian_id, child_id, type, level, version)
           values ($1, $2, 'image_rights', 'not_allowed', 1)`,
          [child.guardian, id],
        );
      }
      await tx.query(
        `insert into consent_record (guardian_id, type, version)
         values ($1, 'privacy_policy', 1), ($2, 'privacy_policy', 1), ($3, 'privacy_policy', 1)`,
        [parentId, educatorId, executiveId],
      );

      // --- Today's sessions ------------------------------------------------
      const [{ id: ashbalSessionId }] = await tx.query(
        `insert into session (group_id, starts_at, ends_at, place, title, theme, status)
         values ($1, date_trunc('day', now()) + interval '16 hours',
                     date_trunc('day', now()) + interval '18 hours',
                 'القاعة الكبرى', 'حصة الأشبال', 'الأخلاق', 'planned')
         returning id`,
        [ashbalId],
      );
      await tx.query(
        `insert into session (group_id, starts_at, ends_at, place, title, status)
         values ($1, date_trunc('day', now()) + interval '17 hours',
                     date_trunc('day', now()) + interval '19 hours',
                 'القاعة الصغرى', 'حصة الزهرات', 'planned')`,
        [zahratId],
      );

      // An open presence confirmation with no answers yet — the state that has
      // to survive a missed push by surfacing on the Home card (ATT-04).
      await tx.query(
        `insert into presence_confirmation (session_id, sent_at, deadline_at)
         values ($1, now(), date_trunc('day', now()) + interval '14 hours')`,
        [ashbalSessionId],
      );

      // --- Announcements ---------------------------------------------------
      await tx.query(
        `insert into announcement (author_id, title, body, audience_json, priority, pinned)
         values
           ($1, 'تغيير في توقيت حصة يوم السبت',
                'ستبدأ الحصة على الساعة الرابعة بدل الثالثة.',
                '{"all": true}'::jsonb, 'urgent', true),
           ($1, 'انطلاق التسجيل في الأنشطة الصيفية', null,
                '{"all": true}'::jsonb, 'normal', false)`,
        [executiveId],
      );

      // eslint-disable-next-line no-console
      console.log(
        [
          'Seeded RAEED development data.',
          '',
          '  Parent     +212600000001   (2 children: آدم, مريم, عمر)',
          '  Educator   +212600000002   (leads الأشبال أ, also a parent)',
          '  Executive  +212600000003',
          '',
          '  Sign in with any of these numbers — the OTP is printed to the',
          '  API log, because no SMS provider is configured locally.',
        ].join('\n'),
      );
    });
  } finally {
    await dataSource.destroy();
  }
}

void seed().catch((error: unknown) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
