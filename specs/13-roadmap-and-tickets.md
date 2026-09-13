# Roadmap & Implementation Tickets

Phases match `01-product-brief.md`'s MVP scope. Epics A–D (the weekly-cycle core) are broken into full tickets — start here. Epics E–I are listed at ticket-granularity too, but lighter, since they build on patterns A–D establish; expand each into full tickets when its phase starts.

Estimates are relative (S/M/L), not days — size them against your own team's velocity after Epic A.

## Epic A — Foundation & Auth

| ID | Ticket | Acceptance criteria | Est. | Depends on |
|---|---|---|---|---|
| RAEED-1 | Provision local dev environment | `docker-compose up` gives a working API + Postgres + Redis; `schema.sql` applies cleanly via the migration tool | S | — |
| RAEED-2 | `app_user` + OTP request/verify | `POST /auth/otp/request` + `/verify` per `04-api/openapi.yaml`; rate-limited per `10-security-and-privacy.md` | M | RAEED-1 |
| RAEED-3 | JWT issuance + refresh rotation | Access token 15min, refresh token rotates and is device-scoped; `DELETE /auth/sessions/{deviceId}` revokes one device | M | RAEED-2 |
| RAEED-4 | `role_assignment` + ability model skeleton | CASL `defineAbilityFor` per `05-authorization.md`; `@CheckAbility` guard enforced on a placeholder route; allow+deny test for parent/educator/executive/admin | M | RAEED-3 |
| RAEED-5 | Consent capture flow | `consent_record` write on first login; app blocks past `/consent` until privacy policy + per-child image-rights level are set (`ACC-06`) | M | RAEED-4 |
| RAEED-6 | Flutter app shell | go_router with the guarded routes in `06-mobile-app-spec.md`; design tokens wired from `08-design-system/design-tokens.json`; Amiri/Lora/Public Sans loaded, RTL default | M | RAEED-3 |

## Epic B — Org Structure & Children

| ID | Ticket | Acceptance criteria | Est. | Depends on |
|---|---|---|---|---|
| RAEED-7 | Branch/Season/Category CRUD (Admin) | Admin-only per ability matrix; the 8 category names seeded, `min_age`/`max_age`/`gender` nullable pending open decision #1 | M | RAEED-4 |
| RAEED-8 | Group CRUD + `group_educator` assignment | Group requires category+season+branch; a group's children must match the category's `gender` enum (validated server-side, not just UI) | M | RAEED-7 |
| RAEED-9 | Child profile CRUD + `parent_child` linking | Unlinking a child's last guardian is rejected (`children.last_guardian`, 409); guardian linking is Executive/Admin-only | M | RAEED-7 |
| RAEED-10 | Field-tier change requests | `POST /children/{id}/change-requests` implements the self-edit-instant / notify / approval tiers from `05-authorization.md` | M | RAEED-9 |
| RAEED-11 | Excel bulk import | Dry-run/preview step shows row-level validation errors before commit — don't ship the "silent partial import" failure mode | L | RAEED-8, RAEED-9 |
| RAEED-12 | Parent Home + Child Profile screens | Per the screen spec in `06-mobile-app-spec.md`: skeleton loading, cached-offline degrade, health-alert badge is icon-only in list views | M | RAEED-9, RAEED-6 |

## Epic C — Sessions, Attendance & Instant Alerts (highest priority, highest risk)

| ID | Ticket | Acceptance criteria | Est. | Depends on |
|---|---|---|---|---|
| RAEED-13 | Session auto-generation from weekly schedule | New sessions created from `group.weekly_schedule_json`; a schedule change never touches a session with `is_customized = true` | M | RAEED-8 |
| RAEED-14 | Session planning + materials upload | `material` records via `StorageProvider` (local disk driver); visibility enum enforced (`before_session`/`after_session`/`staff_only`) | M | RAEED-13 |
| RAEED-15 | Presence confirmation send + reminder job | Scheduled per group; one reminder before deadline; parents can declare in advance without waiting (`ATT-04`) | M | RAEED-13 |
| RAEED-16 | Presence answer endpoint + offline queue (mobile) | Answers queue in Drift when offline, sync on reconnect | M | RAEED-15, RAEED-6 |
| RAEED-17 | Attendance sheet GET/PATCH + conflict rule | `attendance.conflict` on stale `recorded_at_client`; correction creates a new row with `corrected_from` set, not an update-in-place | L | RAEED-16 |
| RAEED-18 | **Critical-alert pipeline** | Absence with no prior "no" answer enqueues on the `critical` BullMQ queue synchronously before the PATCH returns; push dispatched; 90s ack timeout triggers SMS fallback | L | RAEED-17 |
| RAEED-19 | Load test the critical-alert pipeline | p95 push dispatch <30s under realistic concurrent-session load (see `11-testing-strategy.md`) — **do not consider Epic C done without this** | M | RAEED-18 |
| RAEED-20 | Attendance-not-recorded escalation job | Educator reminder at +30min, executive visibility beyond that | S | RAEED-17 |
| RAEED-21 | Attendance marking screen (mobile) | One-tap chips, offline-capable, per the screen spec in `06-mobile-app-spec.md` | M | RAEED-17, RAEED-6 |

## Epic D — Homework & Materials

| ID | Ticket | Acceptance criteria | Est. | Depends on |
|---|---|---|---|---|
| RAEED-22 | Homework CRUD (group or targeted children) | `target_child_ids` null = whole group | S | RAEED-13 |
| RAEED-23 | Homework status + due-date reminder job | Self-reported `done`; dashboard-facing metric explicitly labeled "self-reported" wherever it's surfaced later (Epic G) | S | RAEED-22 |
| RAEED-24 | Materials library (parent-facing) | Filterable by type/theme/date across a child's groups (`MAT-02`) | M | RAEED-14 |

## Epic E — Messaging & Announcements

`conversation`/`message` per child+staff+executive types, `MSG-06` phone-number redaction enforced at the serializer (test it, don't trust the UI), per-educator `availability_hours_json` gating (`MSG-07`), announcement targeting + urgent priority feeding the same critical-alert pipeline as Epic C (RAEED-18) rather than a second implementation. Tickets: conversation creation on child enrollment, message send/report/hide endpoints, staff channel per group, announcement composer + audience targeting, read receipts, the safeguarding "raise a concern" endpoint independent of any message thread.

## Epic F — Memories Wall & Notification Center

Album/post/tag with the `memories.consent_blocked` publish-time check and the `consent-downgrade-recheck` job (`07-backend-spec.md`); moderation queue per `album.moderation_mode`; in-app notification center with unread counter, per-category preferences with the Critical set hard-locked (`09-notifications-spec.md`).

## Epic G — Executive Dashboard & Audit

React dashboard; every query reuses the `dashboard` module's permission-scoped services — no direct-to-DB reporting path. Overview stats, attendance trend with filters, alerts panel, exports (logged), audit log viewer (Admin only).

## Epic H — Hardening

Offline conflict-case automated tests (Epic C's non-negotiable case, `11-testing-strategy.md`), RTL/Arabic screen-reader pass, text-scaling pass at 130%+, performance pass against the targets that should be pulled into a `14-performance.md` if not already tracked, full bilingual string review.

## Epic I — Pilot & Launch

2–3 real groups, 4–6 weeks, weekly fixes. Exit criteria from the product scope: 80% of pilot families active, attendance recorded for 95% of sessions. Provision the OVHcloud target environment (`12-devops-and-environments.md`) before this epic starts, not during it.
