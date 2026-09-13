# Mobile App Spec (Flutter)

One Flutter codebase for parents, educators, and executives-on-mobile (the executive web dashboard is `React`, spec'd separately if/when it starts — this file covers mobile only).

## Architecture

Feature-first folders, four pragmatic layers — no separate packages, that's unnecessary ceremony at this scale:

```
lib/
  core/              // theming (design-tokens.json → Dart), i18n, network client, router, secure storage
  features/
    auth/
      presentation/  // screens, widgets, riverpod providers holding UI state
      application/   // use-cases: RequestOtp, VerifyOtp, SwitchRole...
      domain/        // entities + repository interfaces, pure Dart, no deps
      data/          // repository impl, DTOs, Drift tables, API mapping
    children/
    sessions/
    attendance/
    homework/
    materials/
    messaging/
    announcements/
    memories/
    notifications/
    dashboard_mobile/   // executive's mobile view — thinner than the web dashboard
  shared/            // cross-feature widgets (health-alert badge, status pill, empty states)
test/
```

## Key decisions

| Concern | Choice | Why |
|---|---|---|
| Language / SDK | Dart 3 / Flutter 3.x | Single codebase, AOT-compiled — predictable performance on entry-level Android |
| State management | Riverpod (+ codegen) | Less ceremony than Bloc for this team; doubles as the DI container |
| Navigation | go_router | Declarative, typed deep links (a push opens the exact conversation/session), per-role redirect guards |
| Networking | dio + client generated from `04-api/openapi.yaml` | No hand-maintained request code drifting from the backend contract |
| Local persistence | Drift (SQLite) | Typed SQL + real migrations for the offline attendance/sessions cache (`02-architecture.md`'s offline scope) |
| Secure storage | flutter_secure_storage | Keychain/Keystore-backed access + refresh tokens |
| Push | Firebase Cloud Messaging only | Delivery only — no other Firebase product, keeping "no tracking SDK" intact |
| Crash/error tracking | Sentry | Shared with the backend; PII-scrubbed before leaving the device |
| i18n | flutter_intl, ARB files for `ar`/`fr`/`en` | ICU plurals from day one — Arabic needs all six categories |
| Theming | Generated from `08-design-system/design-tokens.json` | Single source of truth, see that folder |

## Routing table (go_router)

| Path | Screen | Guard |
|---|---|---|
| `/login` | Phone entry | none |
| `/login/otp` | OTP verify | phone pending |
| `/consent` | Privacy + image-rights consent | authenticated, consent not yet given |
| `/home` | Role-scoped home | authenticated + consented |
| `/children/:id` | Child profile | parent (own child) or educator (own group) |
| `/children/:id/schedule` \| `/attendance` \| `/homework` \| `/materials` | Child sub-tabs | same as above |
| `/groups/:id` | Educator group view | educator (own group) or executive |
| `/groups/:id/sessions/:sessionId/attendance` | Attendance marking | educator (own group) or executive |
| `/messages/:conversationId` | Conversation | member of conversation, or executive (oversight, logged) |
| `/memories` | Memories Wall | authenticated |
| `/memories/compose` | Post creation | educator or executive |
| `/announcements/compose` | Announcement composer | educator (own groups) or executive (any audience) |
| `/dashboard` | Executive mobile dashboard | executive/admin |

## Screen specs

Full loading/empty/error/success breakdown for the five screens with the most business logic — use this template for every new screen as it's built; don't skip straight to code.

### Parent Home (`/home`, parent role)

| | |
|---|---|
| Purpose | Answer "where is my child and what's next" in one glance, for every enrolled child |
| Entry points | App launch (post-auth default), notification tap-through, role switch |
| Components | One card per child (photo, name, age, group, next session, today's status pill), pinned/active announcements strip, bottom nav |
| User actions | Tap card → child profile; tap status pill → presence confirmation or attendance detail; pull to refresh |
| API | `GET /children`, `GET /announcements` |
| Loading | Skeleton child cards — never a bare spinner |
| Empty | Should not occur post-onboarding; if it does, "contact the association" (signals a data problem) |
| Error | Cached last-known cards + a subtle "couldn't refresh" banner — degrades gracefully offline |
| Success | Live today-status; a fresh absence alert overrides the status pill to a high-contrast alert state |

### Educator — Attendance marking (`/groups/:id/sessions/:sessionId/attendance`)

| | |
|---|---|
| Purpose | Mark a whole group in under a minute, offline-capable |
| Components | Pre-filled list from presence answers, large one-tap status chips, health-alert badge (icon only — full text on tap-through), live confirmed/absent/no-answer summary header |
| User actions | Tap a chip (cycles present→late→absent→excused); "mark remaining present"; submit |
| API | `GET/PATCH /sessions/{id}/attendance` — PATCH is queued locally (Drift) when offline |
| Loading/Empty/Error | Skeleton rows; "no children in this group yet"; offline banner "saved on this device, will sync" — never blocks submission |
| Success | Confirmation toast; any unexplained-absent mark triggers the critical-alert pipeline (`02-architecture.md`) |

### Presence confirmation (parent)

Push → one-tap Yes/No/Late with an optional reason chip set (illness/travel/exam/other) → done, no typing required unless "other". An unanswered confirmation also surfaces on the Home card itself so it survives a missed push.

### Memories Wall — post creation (educator)

Pick media → choose album (season-scoped) → tag children, where the picker visibly marks any child whose `image_rights_level` is `not_allowed` and blocks submission until that photo is removed → publish (immediate or pending, per the album's `moderation_mode`).

### Executive mobile dashboard

Stat tiles (children/families/groups/educators), an alerts panel (sessions missing attendance, over-capacity groups) that escalates by severity as a colored chip, not just a number — this screen is scanned, not read.

Remaining screens (calendar, materials library, staff channel, announcement composer, structure/people admin on web) follow the same template; write one before implementing, don't skip it because it "looks simple".
