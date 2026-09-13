# Security & Privacy Spec

Children's data is the reason security is a first-class spec here, not a checklist appended at the end.

## Authentication & sessions

| | |
|---|---|
| Registration | Executive/Admin-only (`ACC-02`) — never a public endpoint |
| Login | Phone + OTP (6-digit, 5-minute expiry, 5 requests/hour/number), email OTP as an alternative |
| Sessions | 15-minute JWT access token + rotating refresh token per device, individually revocable (`ACC-07`) via `/auth/sessions/{deviceId}` |
| Recovery | No password exists — recovery is another OTP to the same verified phone, or an Executive re-invite if the number changed |
| Brute force | Per-IP and per-phone-number rate limits on OTP request/verify; exponential backoff on repeated failures |

## Authorization

Ability-based, server-side, on every request — see `05-authorization.md`. Never trusted from the client, never re-implemented per controller.

## Data protection

| | |
|---|---|
| Encryption in transit | TLS everywhere |
| Encryption at rest | Provider-native disk encryption (OVHcloud managed Postgres/volumes) **plus** application-level encryption on `child.health_json` specifically — a raw DB dump/backup leak still shouldn't expose it in plaintext |
| Input validation | DTO-level schema validation (class-validator) on every endpoint; parameterized queries only via the ORM — no raw SQL string concatenation, ever |
| File access | Private storage only (`StorageProvider`, `07-backend-spec.md`), short-lived signed URLs generated per-request after the same permission check as viewing the record |
| Audit logs | `AUD-02`/`AUD-03` as specified in the product scope; insert-only at the DB grant level (`03-domain-model/schema.sql`'s GRANT block) — holds even against a compromised or buggy app server, not just a well-behaved UI |

## What must never be logged (application logs / Sentry, as opposed to `audit_log_entry`)

Health information text, message bodies, OTP codes, raw phone numbers — only opaque IDs. `audit_log_entry` is the one place "who accessed what" is recorded, precisely so ordinary logs don't have to carry that weight.

## CNDP / data residency

Morocco's Law 09-08, supervised by the CNDP, applies. Hosting target is confirmed as **OVHcloud, EU region** (`01-product-brief.md`) — still worth confirming the specific region against the CNDP's cross-border-transfer rule before go-live, since "EU" and "outside Morocco" both trigger it regardless of provider. RAEED should also confirm whether health-data processing needs prior CNDP authorization before launch. This document isn't legal advice — get the region and the health-field list (open decision #2) signed off by whoever files the CNDP declaration before the `child` schema freezes.

## Retention (proposed — open decision #4, needs legal sign-off)

| Data | Proposed retention | Enforced by |
|---|---|---|
| Child & family records | While enrolled, then 2 years, then deleted/anonymized | `retention-purge` job, `07-backend-spec.md` |
| Health information | Deleted when the child leaves | Same job, targeted at `child.health_json` |
| Memories Wall albums | Archived by season, deleted after 3 seasons | Same job |
| Conversations | 2 years after season end | Same job — this is a scheduled admin-only purge, distinct from `message.hidden_at`, which is user-facing "hide" and never a delete (`MSG-08`) |
| Audit logs | 3 years | Same job — the purge itself is logged, so the log outlives what it describes deleting |

## Safeguarding rules enforced in code, not just policy

- No private educator–child channel exists in the schema (`conversation.type` is `child`/`staff`/`executive` only — a bespoke 1:1 educator-child thread isn't a representable state).
- Executive/Admin reads of any conversation are audit-logged with no exception (`MSG-08`).
- `message.hidden_at` supports hiding; there is no `DELETE` endpoint for messages at all.
- A safeguarding "raise a concern" endpoint exists independent of any specific message or conversation, routing directly to executives (see the product-improvement note carried from the architecture review — not gated behind finding a specific chat line to report).
