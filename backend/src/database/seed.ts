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
          audit_log_entry, notification, post_tag, post, album,
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
      // Last season, kept for the structure screen: archived, never deleted.
      await tx.query(`
        insert into season (label, start_date, end_date, status)
        values ('2025-2026', '2025-09-07', '2026-06-28', 'archived')
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
        `insert into app_user (phone, display_name, preferred_locale)
         values ('+212600000001', 'سعاد الإدريسي', 'ar') returning id`,
      );
      const [{ id: educatorId }] = await tx.query(
        `insert into app_user (phone, display_name, preferred_locale)
         values ('+212600000002', 'عبد الله المرابط', 'ar') returning id`,
      );
      const [{ id: executiveId }] = await tx.query(
        `insert into app_user (phone, display_name, preferred_locale)
         values ('+212600000003', 'أنس الشعيري', 'ar') returning id`,
      );
      // A guardian who was invited and has not signed in yet, and a child
      // enrolled with no group — the two states the families and groups hub
      // exists to resolve.
      const [{ id: pendingParentId }] = await tx.query(
        `insert into app_user (phone, display_name, preferred_locale)
         values ('+212600000004', 'نعيمة التازي', 'ar') returning id`,
      );
      await tx.query(
        `insert into role_assignment (user_id, role) values ($1, 'parent')`,
        [pendingParentId],
      );
      // The seeded accounts that "have signed in": a device row with a last
      // seen time is what the activation figures count.
      await tx.query(
        `insert into user_device (user_id, platform, last_seen_at)
         values ($1, 'android', now() - interval '1 day'),
                ($2, 'android', now() - interval '2 hours'),
                ($3, 'android', now())`,
        [parentId, educatorId, executiveId],
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

      // A co-educator on the same group, so the team channel has two voices
      // and the educator's cards say "with …".
      const [{ id: coEducatorId }] = await tx.query(
        `insert into app_user (phone, display_name, preferred_locale)
         values ('+212600000005', 'حمزة الزياني', 'ar') returning id`,
      );
      await tx.query(
        `insert into role_assignment (user_id, role) values ($1, 'educator')`,
        [coEducatorId],
      );
      await tx.query(
        `insert into group_educator (group_id, educator_user_id, availability_hours_json)
         values ($1, $2, '{"start":"09:00","end":"20:00"}'::jsonb),
                ($1, $3, null),
                ($4, $2, '{"start":"09:00","end":"20:00"}'::jsonb)`,
        [ashbalId, educatorId, coEducatorId, zahratId],
      );

      // --- Children -------------------------------------------------------
      // Image rights vary on purpose so the Memories review shows all three
      // levels; the default for a real enrolment stays `not_allowed`.
      // `childIds` below is indexed by this list; the unassigned child is last.
      const children = [
        { name: 'آدم', dob: '2018-05-02', group: ashbalId, guardian: parentId,
          health: { allergies: ['حساسية من الفول السوداني'], dietary_notes: 'بدون مكسرات' },
          imageRights: 'app_only' },
        { name: 'مريم', dob: '2016-11-20', group: zahratId, guardian: parentId,
          health: {}, imageRights: 'allowed' },
        { name: 'يوسف', dob: '2018-02-14', group: ashbalId, guardian: educatorId,
          health: {}, imageRights: 'allowed' },
        { name: 'عمر', dob: '2017-07-09', group: ashbalId, guardian: parentId,
          health: { conditions: ['ربو خفيف'] }, imageRights: 'not_allowed' },
        { name: 'إلياس التازي', dob: '2017-03-11', group: null, guardian: pendingParentId,
          health: {}, imageRights: 'not_allowed' },
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
        if (child.group) {
          // Enrolled before the seeded sessions, so the season's attendance
          // counts them.
          await tx.query(
            `insert into child_group (child_id, group_id, is_main, valid_from)
             values ($1, $2, true, now() - interval '30 days')`,
            [id, child.group],
          );
        }
        // Consent is recorded for every child so the app opens past the
        // consent gate. Image rights start at the most restrictive level —
        // the same default the app applies.
        await tx.query(
          `insert into consent_record (guardian_id, child_id, type, level, version)
           values ($1, $2, 'image_rights', $3, 1)`,
          [child.guardian, id, child.imageRights],
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

      // --- Past sessions and their attendance -------------------------------
      // Last week's الأشبال session was marked, and one mark was corrected
      // afterwards: the trail the executive's review screen shows.
      const [{ id: lastWeekSessionId }] = await tx.query(
        `insert into session (group_id, starts_at, ends_at, place, title, status)
         values ($1, date_trunc('day', now()) - interval '7 days' + interval '16 hours',
                     date_trunc('day', now()) - interval '7 days' + interval '18 hours',
                 'القاعة الكبرى', 'حلقة القرآن — سورة الملك', 'delivered')
         returning id`,
        [ashbalId],
      );
      // The educator added content and materials to the delivered session,
      // sent its summary, and set homework the guardians report on.
      await tx.query(
        `update session
            set objectives = $2, theme = 'القرآن الكريم', is_customized = true,
                summary = $3, summary_sent_at = now() - interval '6 days'
          where id = $1`,
        [
          lastWeekSessionId,
          '• حفظ الآيات 6–10 من سورة الملك\n• فهم معنى «تبارك» و«الملك»\n• تطبيق أحكام المدّ في الآيات',
          'حفظ الأشبال اليوم الآيات 6 إلى 10 من سورة الملك، وتعلّموا معنى «تبارك». نرجو مراجعة الآيات مع أبنائكم.',
        ],
      );
      await tx.query(
        `insert into material (session_id, storage_key, title, kind, visibility, size_bytes)
         values ($1, 'seed/hifz-6-10.pdf', 'ورقة الحفظ — الآيات 6–10', 'document', 'before_session', 245760),
                ($1, 'https://example.org/tilawa-al-mulk', 'تلاوة الآيات — الشيخ الحصري', 'link', 'after_session', null),
                ($1, 'seed/prep-notes.txt', 'ملاحظات التحضير', 'document', 'staff_only', 2048)`,
        [lastWeekSessionId],
      );
      const [{ id: homeworkId }] = await tx.query(
        `insert into homework (session_id, group_id, title, instructions, due_at)
         values ($1, $2, 'مراجعة الآيات 1–10', 'يقرأ الطفل الآيات على أحد الوالدين مرتين، مع الانتباه لأحكام المدّ.',
                 date_trunc('day', now()) + interval '5 days' + interval '18 hours')
         returning id`,
        [lastWeekSessionId, ashbalId],
      );
      const [adamId, , yousefId, omarId] = childIds;
      await tx.query(
        `insert into homework_status (homework_id, child_id, done, done_at)
         values ($1, $2, true, now() - interval '2 days'), ($1, $3, true, now() - interval '1 day'), ($1, $4, false, null)`,
        [homeworkId, adamId, yousefId, omarId],
      );
      await tx.query(
        `insert into attendance_record
           (session_id, child_id, status, recorded_by, recorded_at, recorded_at_client)
         values ($1, $2, 'present', $5, $6, $6),
                ($1, $3, 'present', $5, $6, $6),
                ($1, $4, 'absent',  $5, $6, $6)`,
        [
          lastWeekSessionId, adamId, yousefId, omarId, educatorId,
          new Date(Date.now() - 7 * 24 * 3600 * 1000 + 16.2 * 3600 * 1000),
        ],
      );
      const [{ id: omarOriginalId }] = await tx.query(
        `select id from attendance_record where session_id = $1 and child_id = $2`,
        [lastWeekSessionId, omarId],
      );
      await tx.query(
        `update attendance_record set superseded_at = now() - interval '6 days' where id = $1`,
        [omarOriginalId],
      );
      await tx.query(
        `insert into attendance_record
           (session_id, child_id, status, recorded_by, recorded_at, recorded_at_client, corrected_from, note)
         values ($1, $2, 'excused', $3, now() - interval '6 days', now() - interval '6 days', $4,
                 'اتصلت الأم: مرض مفاجئ، عُذر مقبول.')`,
        [lastWeekSessionId, omarId, executiveId, omarOriginalId],
      );
      // Yesterday's الزهرات session ended with no attendance at all — the
      // danger alert on the dashboard.
      await tx.query(
        `insert into session (group_id, starts_at, ends_at, place, title, status)
         values ($1, date_trunc('day', now()) - interval '1 day' + interval '17 hours',
                     date_trunc('day', now()) - interval '1 day' + interval '19 hours',
                 'القاعة الصغرى', 'حديث الأسبوع', 'planned')`,
        [zahratId],
      );

      // --- Conversations ------------------------------------------------------
      // One thread per child, a staff channel for الأشبال أ, and the executive
      // channel. One message in آدم's thread has been reported.
      const [{ id: adamThreadId }] = await tx.query(
        `insert into conversation (type, ref_child_id) values ('child', $1) returning id`,
        [adamId],
      );
      await tx.query(
        `insert into conversation (type, ref_child_id) values ('child', $1), ('child', $2)`,
        [yousefId, omarId],
      );
      const [{ id: staffThreadId }] = await tx.query(
        `insert into conversation (type, ref_group_id) values ('staff', $1) returning id`,
        [ashbalId],
      );
      const [{ id: executiveThreadId }] = await tx.query(
        `insert into conversation (type) values ('executive') returning id`,
      );
      await tx.query(
        `insert into message (conversation_id, sender_id, kind, body, created_at)
         values ($1, $2, 'text', 'السلام عليكم، آدم أتمّ حفظ الآيات الخمس الأولى من سورة الملك اليوم ما شاء الله.', now() - interval '2 days'),
                ($1, $3, 'text', 'وعليكم السلام، جزاكم الله خيرًا أستاذ.', now() - interval '2 days' + interval '20 minutes')`,
        [adamThreadId, educatorId, parentId],
      );
      const [{ id: reportedMessageId }] = await tx.query(
        `insert into message (conversation_id, sender_id, kind, body, created_at)
         values ($1, $2, 'text', 'هل يمكن مشاركة رقم هاتف الأم مع مؤطر النادي؟', now() - interval '1 day')
         returning id`,
        [adamThreadId, educatorId],
      );
      await tx.query(
        `insert into message_report (message_id, reported_by, reason)
         values ($1, $2, 'طلب معلومات شخصية')`,
        [reportedMessageId, parentId],
      );
      await tx.query(
        `insert into message (conversation_id, sender_id, kind, body, created_at)
         values ($1, $2, 'text', 'أرفقت ورقة الحفظ لهذا الأسبوع.', now() - interval '3 days'),
                ($3, $4, 'text', 'الجمع العام يوم 4 أكتوبر — يرجى تأكيد الحضور.', now() - interval '4 days')`,
        [staffThreadId, educatorId, executiveThreadId, executiveId],
      );

      // --- Memories Wall ----------------------------------------------------
      // Two albums. One pending post awaits approval; one published post was
      // auto-hidden after a tagged child's guardian withdrew image rights —
      // the consent-downgrade case the review screen has to show.
      const [{ id: quranAlbumId }] = await tx.query(
        `insert into album (season_id, group_id, title, moderation_mode)
         values ($1, $2, 'ختم سورة الملك', 'approve_before_publish') returning id`,
        [seasonId, ashbalId],
      );
      const [{ id: tripAlbumId }] = await tx.query(
        `insert into album (season_id, group_id, title, moderation_mode)
         values ($1, $2, 'رحلة الغابة', 'approve_before_publish') returning id`,
        [seasonId, zahratId],
      );
      const [{ id: pendingPostId }] = await tx.query(
        `insert into post (album_id, author_id, storage_key, media_kind, moderation_status, created_at)
         values ($1, $2, 'seed/quran-1.jpg', 'photo', 'pending', now() - interval '3 hours') returning id`,
        [quranAlbumId, educatorId],
      );
      await tx.query(
        `insert into post_tag (post_id, child_id) values ($1, $2), ($1, $3)`,
        [pendingPostId, adamId, yousefId],
      );
      const [{ id: blockedPostId }] = await tx.query(
        `insert into post (album_id, author_id, storage_key, media_kind, moderation_status, hidden_reason, created_at)
         values ($1, $2, 'seed/trip-1.jpg', 'photo', 'hidden', 'consent_blocked', now() - interval '8 days') returning id`,
        [tripAlbumId, educatorId],
      );
      await tx.query(
        `insert into post_tag (post_id, child_id) values ($1, $2), ($1, $3)`,
        [blockedPostId, omarId, childIds[1]],
      );
      await tx.query(
        `insert into post (album_id, author_id, storage_key, media_kind, moderation_status, created_at)
         values ($1, $2, 'seed/quran-2.jpg', 'photo', 'published', now() - interval '9 days'),
                ($1, $2, 'seed/quran-3.jpg', 'photo', 'published', now() - interval '9 days'),
                ($3, $2, 'seed/trip-2.jpg', 'photo', 'published', now() - interval '8 days')`,
        [quranAlbumId, educatorId, tripAlbumId],
      );

      // --- Notification centre -------------------------------------------------
      await tx.query(
        `insert into notification (user_id, kind, title, body, destination, sent_at, read_at)
         values
           ($1, 'critical', 'غياب دون إشعار — عمر', 'الأشبال أ · أُبلغ الأولياء، لم يردّوا بعد.', 'groups', now() - interval '1 hour', null),
           ($1, 'critical', 'جلسة بلا تسجيل حضور', 'الزهرات أ · أمس 17:00', 'groups', now() - interval '40 minutes', null),
           ($1, 'request', 'طلب تغيير معلق — حقل صحي', 'طلب تعديل المعلومات الصحية لآدم.', null, now() - interval '5 hours', null),
           ($1, 'memories', 'منشور جديد في «ختم سورة الملك»', 'بانتظار اعتمادك.', 'memories', now() - interval '3 hours', now() - interval '2 hours'),
           ($1, 'security', 'دخول من جهاز جديد', 'Android · الدار البيضاء', null, now() - interval '1 day', now() - interval '1 day')`,
        [executiveId],
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
      // The pinned notice to educators on the Today screen, asking to be
      // acknowledged (ANN-06).
      await tx.query(
        `insert into announcement (author_id, title, body, audience_json, priority, pinned, ack_required)
         values ($1, 'يوم مفتوح للأولياء — السبت المقبل',
                 'نرجو حضور جميع المؤطرين من 09:30 للتحضير.',
                 '{"type": "educators", "category_ids": [], "group_ids": []}'::jsonb, 'normal', true, true)`,
        [executiveId],
      );

      // eslint-disable-next-line no-console
      console.log(
        [
          'Seeded RAEED development data.',
          '',
          '  Parent     +212600000001   (2 children: آدم, مريم, عمر)',
          '  Educator   +212600000002   (leads الأشبال أ and الزهرات أ, also a parent)',
          '  Educator   +212600000005   (co-educator on الأشبال أ)',
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
