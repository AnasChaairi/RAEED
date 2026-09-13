# Product Brief

Condensed from `../RAEED_Product_Scope.md` v0.2 and the architecture review that followed it — see that file for the full requirement-by-requirement detail (IDs like `ATT-07`, `WAL-06`, referenced throughout these specs).

## What RAEED is

A private mobile + web platform connecting three roles around each enrolled child at RAEED Academy: **parents**, **educators (مؤطرين)**, and **executives (مشرفين)**. It replaces WhatsApp groups, paper attendance sheets, and shared photo albums with one system that scopes information to exactly who needs it, tracks attendance with instant absence alerts, and gives the board reliable data — all under safeguarding-first defaults, because every record in the system is about a child who is not themselves a user.

## Roles

| Role | Surface | Scope of visibility |
|---|---|---|
| Parent (ولي الأمر) | Mobile | Own children only |
| Educator (مؤطر) | Mobile | Own group(s) only |
| Executive (مشرف) | Mobile + Web dashboard | Everything, branch-scoped if restricted; every action logged |
| Admin | Web dashboard | Everything + structure/user management + audit log access |

## MVP scope (what these specs cover)

Accounts & access · Association structure (branches/seasons/categories/groups) · Children & families · Sessions & weekly planning · Presence confirmation & attendance (with instant absence alerts) · Homework · Learning materials · Messaging · Announcements · Memories Wall · Notifications · Executive dashboard & reports · Audit logs.

**Explicitly V1, not built now:** events/camps, enrollment & fees, homework submissions with feedback, authorized pick-up persons, repeated-absence flags, end-of-season memory book. **Explicitly out of scope indefinitely:** parent-to-parent messaging, public social features, child accounts, online payments, live video classes, school grade tracking.

## Confirmed technical decisions

These are settled — build against them, don't re-derive them.

| Decision | Confirmed choice |
|---|---|
| Engineering team | Experienced, in-house — the stack choices below are made on technical merit, not team-size compromise |
| Mobile | Flutter (Dart) — one codebase, parents + educators + executive mobile |
| Web dashboard | React + TypeScript — executive dashboard only |
| Backend | NestJS (TypeScript), modular monolith, PostgreSQL, Redis + BullMQ |
| Hosting target | **OVHcloud**, EU region. **Current phase: local development only** — Docker Compose, no cloud infra provisioned yet |
| Media storage | **Local disk for MVP**, behind a `StorageProvider` interface — OVH Object Storage (S3-compatible) wired post-MVP without touching calling code |
| Absence-alert / urgent-announcement SMS fallback | **In MVP** (originally V1's `NOT-05`) — see `09-notifications-spec.md` |
| Scale | Small-to-mid: ~200 children, one branch to start. Sizing in `12-devops-and-environments.md` is set for this |
| Push notifications | Firebase Cloud Messaging only (no other Firebase product) |
| Error tracking | Sentry, mobile + backend |

## Still open — do not guess these into the schema/UI

| # | Decision needed | Blocks |
|---|---|---|
| 1 | Category (فئة) age ranges and gender lock per category | Seeding real `category`/`group` data — `03-domain-model/schema.sql`'s `category` table ships with the 8 names from the scope and nullable range/gender fields until this lands |
| 2 | Health-information field list, confirmed for the CNDP filing | Freezing `child.health_json`'s schema in `03-domain-model/entities.md` |
| 3 | Who moderates the Memories Wall by default (publish-then-moderate vs. approve-first) | Default value of `album.moderation_mode` and the moderation queue's staffing/urgency |
| 4 | Retention periods, signed off by a legal advisor | The retention-job schedule in `10-security-and-privacy.md` (currently implements the scope's §11 proposed defaults, unconfirmed) |

## Core domain entities

Branch → Season → Category → Group → Child ↔ Guardian (via `parent_child`) · Group ↔ Educator (via `group_educator`) · Session → PresenceConfirmation → AttendanceRecord · Homework · Conversation/Message · Announcement · Album/Post · ConsentRecord · AuditLogEntry. Full shape in `03-domain-model/`.
