import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * The MVP schema, applied verbatim from `specs/03-domain-model/schema.sql`.
 *
 * Generated rather than hand-written, by `npm run schema:sync`, so the DDL in
 * the specs and the DDL in the database cannot drift. Editing this file by hand
 * would break that guarantee — change `schema.sql` and add a *new* migration
 * instead, which is also what `specs/07-backend-spec.md` requires ("one per PR
 * ... never a hand-run SQL script against prod").
 *
 * The GRANT block at the end of schema.sql is deliberately excluded here: it
 * references the application's runtime role, which does not exist until
 * `1757700001000-AuditImmutability` creates it.
 */
export class InitialSchema1757700000000 implements MigrationInterface {
  name = 'InitialSchema1757700000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`-- RAEED — MVP database schema (PostgreSQL 15+)
-- Implementation-ready DDL for the modules in 01-product-brief.md.
-- Conventions:
--   * every table: id uuid pk default gen_random_uuid(), created_at, updated_at
--   * user-facing tables additionally get deleted_at (soft delete) — never hard-deleted
--     while a retention decision (open decision #4 in 01-product-brief.md) is pending
--   * audit_log_entry is the one exception: insert-only, no deleted_at, no update/delete
--     grant for the application role (see the GRANT statements at the bottom)
--   * foreign keys are always indexed
--   * tables appear in dependency order so this file runs top to bottom with no forward refs
--   * V1 tables (event, enrollment_fee, ...) are intentionally NOT in this file yet —
--     add them when V1 starts, per CLAUDE.md's "keep MVP and V1 scope separate"

create extension if not exists pgcrypto;

-- ============================================================
-- 1. Association structure, top level (ORG) — no dependencies
-- ============================================================

create table branch (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table season (
  id uuid primary key default gen_random_uuid(),
  label text not null,                       -- e.g. "2026-2027"
  start_date date not null,
  end_date date not null,
  status text not null default 'active' check (status in ('active','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create type category_gender as enum ('boys', 'girls', 'mixed');

create table category (
  id uuid primary key default gen_random_uuid(),
  name_ar text not null,                     -- e.g. الأشبال
  name_en text,
  name_fr text,
  min_age int,                                -- nullable: open decision #1 in 01-product-brief.md
  max_age int,
  gender category_gender,                     -- nullable until confirmed
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ============================================================
-- 2. Identity & access (ACC)
-- ============================================================

create type role_name as enum ('parent', 'educator', 'executive', 'admin');

create table app_user (
  id uuid primary key default gen_random_uuid(),
  phone text unique,                 -- E.164, e.g. +2126XXXXXXXX
  email text unique,
  preferred_locale text not null default 'ar' check (preferred_locale in ('ar','fr','en')),
  is_active boolean not null default true,   -- ACC-07: flips to false on deactivation
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- Phone/email are the only place identifying contact info lives (MSG-06's
-- "never show phone numbers" rule has exactly one column to guard).

create table role_assignment (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(id) on delete cascade,
  role role_name not null,
  branch_id uuid references branch(id),      -- optional restriction for executive/admin (ACC-08)
  created_at timestamptz not null default now(),
  unique (user_id, role, branch_id)
);

create table user_device (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_user(id) on delete cascade,
  push_token text,
  platform text check (platform in ('ios','android','web')),
  last_seen_at timestamptz,
  revoked_at timestamptz,                    -- ACC-07 self-service / forced device logout
  created_at timestamptz not null default now()
);
create index on user_device (user_id) where revoked_at is null;

-- ============================================================
-- 3. Groups (ORG, continued) — needs category/season/branch/app_user
-- ============================================================

create table "group" (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category_id uuid not null references category(id),
  season_id uuid not null references season(id),
  branch_id uuid not null references branch(id),
  capacity int,
  weekly_schedule_json jsonb not null default '[]', -- drives SES-02 auto-generation
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index on "group" (season_id, category_id, branch_id);

create table group_educator (
  group_id uuid not null references "group"(id) on delete cascade,
  educator_user_id uuid not null references app_user(id),
  availability_hours_json jsonb,             -- per-educator (MSG-07)
  assigned_at timestamptz not null default now(),
  unassigned_at timestamptz,                 -- keep history; never delete the row
  primary key (group_id, educator_user_id, assigned_at)
);
create index on group_educator (educator_user_id) where unassigned_at is null;

-- ============================================================
-- 4. Children & families (CHD) — needs app_user, group
-- ============================================================

create table child (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  dob date not null,
  photo_url text,
  school_level text,
  health_json jsonb not null default '{}',   -- schema-versioned; see entities.md. Every
                                              -- read is logged separately (AUD-03), regardless
                                              -- of column layout.
  health_json_version int not null default 1,
  special_needs_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create type consent_type as enum ('privacy_policy', 'image_rights');
create type image_rights_level as enum ('allowed', 'app_only', 'not_allowed');

create table consent_record (
  id uuid primary key default gen_random_uuid(),
  guardian_id uuid not null references app_user(id),
  child_id uuid references child(id),        -- null for privacy_policy (account-level)
  type consent_type not null,
  level image_rights_level,                  -- only set when type = image_rights
  version int not null,
  effective_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
-- Append-only: "current" consent = latest row per (child_id, type). Never update-in-place —
-- the full history must exist for AUD-02 and for WAL-06's re-check-on-downgrade rule.
create index on consent_record (child_id, type, effective_at desc);

create table parent_child (
  guardian_user_id uuid not null references app_user(id),
  child_id uuid not null references child(id) on delete cascade,
  relationship_type text not null,           -- mother, father, legal guardian, ...
  linked_at timestamptz not null default now(),
  unlinked_at timestamptz,                   -- only Executives/Admin can set this (ACC-05)
  primary key (guardian_user_id, child_id, linked_at)
);
create index on parent_child (child_id) where unlinked_at is null;
create index on parent_child (guardian_user_id) where unlinked_at is null;

create table child_group (
  child_id uuid not null references child(id) on delete cascade,
  group_id uuid not null references "group"(id),
  is_main boolean not null default true,     -- Q3: one main group + optional secondary groups
  valid_from timestamptz not null default now(),
  valid_to timestamptz,                      -- moving groups = new row, never an update (ORG-04)
  primary key (child_id, group_id, valid_from)
);
create index on child_group (group_id) where valid_to is null;
create index on child_group (child_id) where valid_to is null;

create table profile_change_request (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references child(id),
  requested_by uuid not null references app_user(id),
  field_path text not null,                  -- e.g. 'health_json.allergies'
  proposed_value jsonb not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references app_user(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);
-- Field tiers (self-edit-instant / request-with-notify / request-with-approval) are
-- enforced in application code (05-authorization.md), not the schema.

-- ============================================================
-- 5. Sessions & planning (SES) — needs group
-- ============================================================

create type session_status as enum ('planned', 'delivered', 'cancelled');

create table session (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references "group"(id),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  place text,
  title text,
  objectives text,
  theme text,
  status session_status not null default 'planned',
  is_customized boolean not null default false, -- true once an educator edits it — protects
                                                  -- it from silent regeneration (SES-02)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index on session (group_id, starts_at);

create type material_visibility as enum ('before_session', 'after_session', 'staff_only');

create table material (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references session(id) on delete cascade,
  storage_key text not null,                 -- resolved via StorageProvider — see 07-backend-spec.md
  kind text not null check (kind in ('document','image','audio','video','link')),
  visibility material_visibility not null default 'after_session',
  size_bytes bigint,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index on material (session_id);

-- ============================================================
-- 6. Presence & attendance (ATT) — safety-critical, needs session/child/app_user
-- ============================================================

create table presence_confirmation (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique references session(id) on delete cascade,
  sent_at timestamptz,
  deadline_at timestamptz,
  reminder_sent_at timestamptz,
  created_at timestamptz not null default now()
);

create type presence_answer_value as enum ('yes', 'no', 'late');
create type absence_reason as enum ('illness', 'travel', 'exam', 'other');

create table presence_answer (
  id uuid primary key default gen_random_uuid(),
  presence_confirmation_id uuid not null references presence_confirmation(id) on delete cascade,
  child_id uuid not null references child(id),
  answer presence_answer_value not null,
  reason absence_reason,
  answered_by uuid not null references app_user(id),
  answered_at timestamptz not null default now(),
  unique (presence_confirmation_id, child_id)
);

create type attendance_status as enum ('present', 'absent', 'late', 'excused');

create table attendance_record (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references session(id),
  child_id uuid not null references child(id),
  status attendance_status not null,
  recorded_by uuid not null references app_user(id),
  recorded_at timestamptz not null default now(),
  recorded_at_client timestamptz not null,   -- offline conflict rule uses this, see below
  corrected_from uuid references attendance_record(id), -- self-reference on correction
  created_at timestamptz not null default now(),
  unique (session_id, child_id)
);
create index on attendance_record (session_id);
-- Conflict rule (02-architecture.md / 04-api/conventions.md): an incoming write whose
-- recorded_at_client is older than the current row's recorded_at is rejected with
-- attendance.conflict, not silently overwritten.

-- ============================================================
-- 7. Homework (HWK)
-- ============================================================

create table homework (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references session(id),
  group_id uuid not null references "group"(id),
  instructions text not null,
  attachment_storage_key text,
  due_at timestamptz not null,
  target_child_ids uuid[],                   -- null = whole group, else specific children
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table homework_status (
  homework_id uuid not null references homework(id) on delete cascade,
  child_id uuid not null references child(id),
  done boolean not null default false,        -- self-reported (HWK-03) — see 09-notifications-spec.md
  done_at timestamptz,
  primary key (homework_id, child_id)
);

-- ============================================================
-- 8. Messaging (MSG)
-- ============================================================

create type conversation_type as enum ('child', 'staff', 'executive');

create table conversation (
  id uuid primary key default gen_random_uuid(),
  type conversation_type not null,
  ref_child_id uuid references child(id),     -- set when type = child
  ref_group_id uuid references "group"(id),   -- set when type = staff
  created_at timestamptz not null default now()
);

create table message (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references conversation(id) on delete cascade,
  sender_id uuid not null references app_user(id),
  kind text not null check (kind in ('text','voice','file')),
  body text,
  storage_key text,
  hidden_at timestamptz,                      -- MSG-08: hidden, never hard-deleted by users
  hidden_by uuid references app_user(id),
  created_at timestamptz not null default now()
);
create index on message (conversation_id, created_at);

create table message_report (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references message(id),
  reported_by uuid not null references app_user(id),
  reason text,
  created_at timestamptz not null default now()
);

-- ============================================================
-- 9. Announcements (ANN)
-- ============================================================

create table announcement (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references app_user(id),
  title text not null,
  body text,
  banner_storage_key text,
  audience_json jsonb not null,               -- {all|parents|educators, branch_ids[], category_ids[], group_ids[]}
  priority text not null default 'normal' check (priority in ('normal','urgent')),
  publish_at timestamptz not null default now(),
  expire_at timestamptz,
  pinned boolean not null default false,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table announcement_read (
  announcement_id uuid not null references announcement(id) on delete cascade,
  user_id uuid not null references app_user(id),
  read_at timestamptz not null default now(),
  confirmed_at timestamptz,                   -- "I have read this" (ANN-06)
  primary key (announcement_id, user_id)
);

-- ============================================================
-- 10. Memories Wall (WAL) — needs season/group/app_user/child
-- ============================================================

create table album (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references season(id),
  group_id uuid references "group"(id),
  title text not null,
  moderation_mode text not null default 'publish_then_moderate'
    check (moderation_mode in ('publish_then_moderate','approve_before_publish')), -- open decision #3
  created_at timestamptz not null default now()
);

create type post_moderation_status as enum ('pending', 'published', 'hidden');

create table post (
  id uuid primary key default gen_random_uuid(),
  album_id uuid not null references album(id) on delete cascade,
  author_id uuid not null references app_user(id),
  storage_key text not null,
  media_kind text not null check (media_kind in ('photo','video','banner')),
  moderation_status post_moderation_status not null default 'pending',
  hidden_reason text,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index on post (album_id);

create table post_tag (
  post_id uuid not null references post(id) on delete cascade,
  child_id uuid not null references child(id),
  primary key (post_id, child_id)
);
create index on post_tag (child_id);
-- Publish-time AND consent-downgrade-time check (WAL-06 + the re-check recommendation
-- in 01-product-brief.md's source review) both query: current image_rights_level for
-- every child_id tagged on a post.

-- ============================================================
-- 11. Audit (AUD) — insert-only, see GRANTs at the end
-- ============================================================

create table audit_log_entry (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references app_user(id),
  action text not null,                       -- e.g. 'attendance.correct', 'child.health_view'
  resource_type text not null,
  resource_id uuid,
  at timestamptz not null default now(),
  device_meta jsonb
);
create index on audit_log_entry (resource_type, resource_id, at desc);
create index on audit_log_entry (actor_user_id, at desc);`);
  }

  public async down(): Promise<void> {
    // Deliberately not implemented. This migration creates every table in the
    // product; a `down` would be a one-command way to destroy every child
    // record in an environment. Rebuild from scratch instead.
    throw new Error(
      'InitialSchema cannot be reverted — drop and recreate the database.',
    );
  }
}
