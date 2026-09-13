# Backend Spec (NestJS)

Modular monolith, one deployable, one PostgreSQL database. Module boundaries are enforced by code review and lint rules (e.g. an ESLint import-boundary rule per module folder), not network calls.

## Project structure

```
backend/
  src/
    modules/
      identity/          // OTP, JWT issuance, role_assignment, user_device
      org-structure/     // branch, season, category, group, group_educator, Excel import
      children/          // child, parent_child, child_group, consent_record, profile_change_request
      sessions/          // session, material, weekly-schedule auto-generation
      attendance/        // presence_confirmation, presence_answer, attendance_record, the critical-alert trigger
      homework/
      messaging/         // conversation, message, message_report
      announcements/
      memories/          // album, post, post_tag, consent-check + re-check-on-downgrade
      notifications/     // the shared critical/normal/low queue infra, see 09-notifications-spec.md
      dashboard/          // read-only, reuses every other module's permission-scoped services
      audit/              // audit_log_entry — insert-only at the DB grant level
    common/
      abilities/          // 05-authorization.md's CASL setup, the @CheckAbility guard
      storage/            // StorageProvider interface + LocalDiskStorageProvider (OvhObjectStorageProvider later)
      queue/              // BullMQ setup: critical-queue, normal-queue
    main.ts
  migrations/             // one per PR, generated from schema.sql's intent — never a hand-run SQL script against prod
  test/
```

## Cross-cutting building blocks

- **`@CheckAbility(action, subjectType)` guard** — resolves the resource from the route param, loads it, calls the CASL ability built in `common/abilities`. Every controller method that isn't public (OTP request/verify) carries one.
- **`StorageProvider` interface** — `put(key, stream): Promise<void>`, `signedUrl(key, ttl): Promise<string>`, `delete(key): Promise<void>`. MVP wires `LocalDiskStorageProvider`; swapping to `OvhObjectStorageProvider` (S3-compatible SDK) later is a DI binding change, not a call-site change — every module in the list above only ever imports the interface.
- **Queues (`common/queue`)** — two BullMQ queues: `critical` (absence alerts, urgent announcements — processed ahead of everything else, see `02-architecture.md`) and `normal` (presence-confirmation scheduling, reminders, low-priority notification batching, image/video compression jobs).
- **Audit interceptor** — a single NestJS interceptor registered on the `children`, `attendance`, `messaging`, `memories`, and `audit` modules' mutating/sensitive-read routes, writing to `audit_log_entry`. Modules don't hand-roll their own audit calls.

## Background jobs (BullMQ, `normal` queue unless noted)

| Job | Trigger | Does |
|---|---|---|
| `send-presence-confirmation` | Scheduled, per group's weekly schedule | Creates `presence_confirmation`, notifies guardians |
| `presence-confirmation-reminder` | Deadline minus configured window | One reminder to guardians who haven't answered |
| `absence-alert` (**critical queue**) | `attendance` PATCH with an unexplained absent | Push immediately, SMS after 90s if undelivered — `09-notifications-spec.md` |
| `urgent-announcement-dispatch` (**critical queue**) | Announcement created with `priority: urgent` | Same push+SMS path as absence-alert |
| `attendance-not-recorded-reminder` | 30 min after session start with no attendance rows | Notifies the educator, then executives |
| `media-compress` | Upload confirmed | Transcodes video to H.264 720p / re-encodes images before marking a `material`/`post` active |
| `consent-downgrade-recheck` | New `consent_record` with `level: not_allowed` | Re-runs the WAL-06 check against every already-published post tagging that child; auto-hides violations pending review |
| `retention-purge` | Scheduled (season-end + N) | Runs the retention rules in `10-security-and-privacy.md`, itself logged to `audit_log_entry` |

## Environment variables

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string (queues + cache) |
| `JWT_ACCESS_SECRET` / `JWT_REFRESH_SECRET` | Token signing |
| `OTP_PROVIDER_API_KEY` | SMS/WhatsApp OTP provider |
| `SMS_FALLBACK_PROVIDER_API_KEY` | Critical-alert SMS fallback (may be the same provider as OTP) |
| `FCM_SERVICE_ACCOUNT_JSON` | Firebase Cloud Messaging credentials |
| `STORAGE_DRIVER` | `local` (MVP) \| `ovh` (post-MVP) |
| `STORAGE_LOCAL_ROOT` | Filesystem path for `LocalDiskStorageProvider` |
| `OVH_S3_*` | Bucket/region/keys — unset until the storage decision (`01-product-brief.md`) is executed |
| `SENTRY_DSN` | Error tracking |
| `HIJRI_OFFSET_DAYS` | Org-level Hijri display adjustment, default `0` |

No secret above is ever committed — see `12-devops-and-environments.md` for per-environment secret handling.
