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
| Components | Pre-filled list from presence answers, one large button per status (present / late / absent), health-alert badge (icon only — full text on tap-through), segmented marking-progress bar over the live confirmed/absent/no-answer summary header |
| User actions | Tap a status button (any status is one tap from any other); long-press for "excused", which has no button of its own; "mark remaining present"; submit |
| API | `GET/PATCH /sessions/{id}/attendance` — PATCH is queued locally (Drift) when offline |
| Loading/Empty/Error | Skeleton rows; "no children in this group yet"; offline banner "saved on this device, will sync" — never blocks submission |
| Success | Confirmation toast; any unexplained-absent mark triggers the critical-alert pipeline (`02-architecture.md`) |

### Presence confirmation (parent)

Push → one-tap Yes/No/Late with an optional reason chip set (illness/travel/exam/other) → done, no typing required unless "other". An unanswered confirmation also surfaces on the Home card itself so it survives a missed push.

### Memories Wall — post creation (educator)

Pick media → choose album (season-scoped) → tag children, where the picker visibly marks any child whose `image_rights_level` is `not_allowed` and blocks submission until that photo is removed → publish (immediate or pending, per the album's `moderation_mode`).

### Executive mobile (`/dashboard` shell, executive/admin) — EXEC-M-01..07

One shell, five tabs (Dashboard · Announcements · Messages · Memories · Groups) plus Notifications and More reached from the header. The shell is the executive's `/home`; every tab is scanned standing up, so alerts and severity chips come before numbers, and numbers before lists. Every oversight action carries the small "this action is recorded" marker (`AUD-03`) at the moment it happens, never in a footer.

#### EXEC-M-01 · Dashboard (`/dashboard`)

| | |
|---|---|
| Purpose | Answer "is any child unaccounted for right now?" before anything else, then "is the association running?" |
| Entry points | App launch for executives/admins, role switch, bottom nav, alert push tap-through |
| Components | Brand-gradient header (greeting + role, both calendars, today's session count, bell, more), alerts panel (severity-chipped cards: danger / warning / info, danger outlined), four stat tiles (children / families / groups / educators, tabular figures, delta), weekly attendance card (rate, delta, eight-week bars), today's sessions list with attendance state chip (recorded / not recorded / live / upcoming) |
| User actions | Tap alert → the tab that resolves it; tap session → group detail; bell → notifications; more → settings; pull to refresh |
| API | `GET /dashboard/overview` |
| Loading | Skeleton alert rows and stat tiles — never a bare spinner |
| Empty | No alerts → the reassuring "nothing needs your attention today" card, in `successSoft`. Stat tiles never go empty: zero is a value |
| Error | Cached last overview + the offline banner ("showing the version from 10:42"); no cache → error view with retry |
| Success | Alerts ordered danger → warning → info, then by recency; the badge on the Groups tab counts danger alerts about groups |

#### EXEC-M-02 · Announcements (tab) + composer (`/announcements/compose`)

| | |
|---|---|
| Purpose | See what was said to whom and how many read it; publish to any audience, with urgent gated behind a high-reach confirm |
| Components | List filtered by state chips (published / scheduled / draft / expired), one card per announcement (title, state tag, audience · timing · pinned, read-rate bar); composer: title, body, audience card opening the audience sheet (all / parents only / educators only / chosen categories, live reach count and plain-language summary), publish-now and expiry, urgent toggle, primary send button whose label carries the reach when urgent |
| User actions | Filter; tap "+"; pick audience; toggle urgent; send → urgent opens the *high-reach* confirm (amber weight) naming the reach and the SMS fallback cost, else publishes directly |
| API | `GET /announcements`, `POST /announcements` (`audience` object + `priority`), audience reach counts from `GET /announcements/reach` — proposed, not yet in `openapi.yaml` |
| Loading | Skeleton cards |
| Empty | "No announcements yet" with the compose button as the only action |
| Error | Error view with retry on the list; on send, the composer keeps the draft and shows the failure inline |
| Success | Toast "published to N people"; urgent sends are recorded with the audience and cost |

#### EXEC-M-03 · Messages (tab) + conversation (`/messages/:conversationId`)

| | |
|---|---|
| Purpose | Oversight of every thread, disclosed by design (`MSG-08`); act on reports without deleting anything |
| Components | Thread list grouped by kind (child conversations / educator channels / executives) with unread counts; conversation header with member list and, when the executive is *not* a member, the oversight notice ("your reading here is recorded and known to the members"); bubbles with sender + role, voice-note bubble (playback only), reported message with hide / dismiss actions, hidden-message stub visible to executives only; composer bar "write as executive" |
| User actions | Open thread; hide a reported message → *reversible* confirm (primary weight) → stub replaces the bubble; dismiss report; send a text message |
| API | `GET /conversations`, `GET /conversations/{id}/messages`, `POST /conversations/{id}/messages`, `POST /messages/{id}/hide`, `POST /messages/{id}/report/dismiss` — all proposed (Epic E, not yet in `openapi.yaml`) |
| Loading | Skeleton rows / bubbles |
| Empty | List: "no conversations yet"; thread: "no messages yet" |
| Error | Error view with retry; `scope.forbidden` renders "not available to you", never "not found" |
| Success | Hidden message shows who hid it and when; phone numbers never appear anywhere on this screen (`MSG-06`) |

#### EXEC-M-04 · Memories review (tab)

| | |
|---|---|
| Purpose | Clear the moderation queue one card at a time, seeing every tagged child's image-rights level before deciding |
| Components | Header with queue count and the album's moderation mode as the server reports it (never a client-side default — open decision), one review card (media, `1 / N`, tag chips with the three-level image-rights indicator, album · author · time, blocked banner when a tagged child's consent has since changed), hide / edit / approve actions at 52px, wall albums grid, indicator legend |
| User actions | Approve (or re-approve a blocked post once the offending media is removed) / hide — hide is never delete |
| API | `GET /memories/review-queue`, `POST /memories/posts/{id}/approve`, `POST /memories/posts/{id}/hide`, `GET /memories/albums` — proposed (Epic F) |
| Loading | Skeleton card |
| Empty | "You've reviewed everything" (reassuring kind), wall still shown |
| Error | Error view with retry |
| Success | Card advances to the next post; toast carries the recorded marker |

#### EXEC-M-05 · Groups (tab) → group (`/groups/:id`) → attendance review (`/groups/:id/sessions/:sessionId/attendance/review`)

| | |
|---|---|
| Purpose | Find the session with no attendance, open its sheet, correct a record with a visible history |
| Components | Group list (name · category, educator · schedule, capacity chip escalating to warning when over capacity); group header (primary ground, category · educator · schedule · room · enrolled/capacity) with segment chips; sessions list with state (recorded n/m / not recorded / upcoming); review sheet header with recorded-by and status counts; one row per child (name, health badge icon-only, guardian's answer, status chip, correct button); a corrected row shows its trail (original record → correction, who, when, device, the superseded record's id, recorded marker) |
| User actions | Open group; open session; correct → bottom sheet with the four statuses, a note, and the recorded marker → save |
| API | `GET /groups`, `GET /groups/{id}` (proposed), `GET /groups/{id}/sessions`, `GET /sessions/{id}/attendance`, `PATCH /sessions/{id}/attendance` — a correction is a **new** `attendance_record` with `corrected_from`, never an in-place edit |
| Loading | Skeleton rows |
| Empty | "No groups this season" / "No sessions yet" / "No children in this group" |
| Error | Error view with retry; offline → cached sheet with the offline banner |
| Success | The row outlines in `info`, the trail appears beneath it, and the summary counts move |

#### EXEC-M-06 · Notifications (`/notifications`)

Filter chips (all / critical / requests / memories), one card per notification (icon tile by kind, title, body, relative time), read ones dimmed. `GET /notifications` — proposed. Empty: "you're up to date".

#### EXEC-M-07 · More (`/more`)

Profile card (name, masked phone, branch scope), role switcher when the user holds more than one role (presentation only — abilities stay the union), dark mode, language, the locked critical channel row (absence alerts, urgent announcements and session changes within 24h always arrive), version line. No network call.

Remaining screens (calendar, materials library, staff channel, announcement composer, structure/people admin on web) follow the same template; write one before implementing, don't skip it because it "looks simple".
