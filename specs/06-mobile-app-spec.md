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
      application/   // use-cases: SignIn, ChangePassword, SwitchRole...
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
| `/login` | Phone + password | none |
| `/more/password` | Change password | authenticated |
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
| `/manage/families/:familyId` | Family detail (EXEC-M-10b) | executive/admin |

## Screen specs

Full loading/empty/error/success breakdown for the five screens with the most business logic — use this template for every new screen as it's built; don't skip straight to code.

### Sign in (`/login`) — RAEED-2

| | |
|---|---|
| Purpose | Get a guardian, educator or executive into their surface with what the association handed them: a phone number and a six-character password |
| Entry points | Cold start with no session; sign-out; a refresh token that no longer rotates |
| Components | Phone field with the fixed `+212` prefix; password field (6 letters or digits, show/hide toggle); one "دخول" button; the "accounts are created by the association" notice. No sign-up link, no "forgot password" link — both are deliberate (`ACC-02`) |
| User actions | Type, submit. A number or password that cannot be right is refused on the device without a request, so a server attempt is never spent on a typo |
| API | `POST /auth/login`, then `GET /auth/me` |
| Loading | Spinner inside the button; fields disabled |
| Error | `auth.invalid_credentials` → one line above the form, the form stays, both fields keep their values; `auth.rate_limited` → the lock-out message; offline → the network message. The wording never says whether the number exists |
| Success | The session controller announces the user and the router moves on to `/consent` or the role's home; the screen itself navigates nowhere |

### Change password (`/more/password`) — RAEED-2

| | |
|---|---|
| Purpose | Let anyone replace the password the association handed them with one of their own |
| Entry points | More → "تغيير كلمة المرور", on every role's More screen |
| Components | Current password, new password, confirmation; one show/hide toggle for all three; the six-character rule as helper text |
| User actions | Fill, save. Mismatched confirmation and ill-shaped values are refused on the device |
| API | `PATCH /auth/me/password` |
| Error | A wrong current password shows under that field, the form stays; anything else is a snackbar |
| Success | Toast, back to More. The session is untouched — other devices stay signed in until revoked (`ACC-07`) |

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

Profile card (name, branch scope), a links card to the sections below (Children · Families & groups with the unassigned count · Reports & export · Structure and Logs, marked admin), role switcher when the user holds more than one role (presentation only — abilities stay the union), dark mode, language, the locked critical channel row, sign out, version line. No network call except the unassigned count.

#### EXEC-M-08 · Children (`/children`)

| | |
|---|---|
| Purpose | Find any child, see their group, season attendance and image-rights level at a glance |
| Components | Search field, category chips, one row per child (name, icon-only health badge, group · attendance, image-rights dot), legend |
| API | `GET /children?q=&category_id=` (oversight rows carry `image_rights_level` and `attendance`), `GET /categories` |
| Loading / Empty / Error | Skeleton rows · "no children match" · error view with retry |

#### EXEC-M-09 · Child (executive) (`/children/:id`, oversight role)

| | |
|---|---|
| Purpose | The child's whole situation, with the two sensitive reads made deliberate and recorded |
| Components | Gradient header (name, age, group, school), season attendance and image-rights tiles; **Health** section collapsed → "this view will be recorded" confirm → revealed with the recorded time (`AUD-03`); **Guardians** with account status and a masked phone that reveals on tap, logged (`MSG-06`); **Consents** (privacy policy per guardian, image rights); **Groups** with attendance; "open the child's thread (oversight, logged)" |
| API | `GET /children/{id}` (no health text for oversight), `GET /children/{id}/health`, `GET /children/{id}/guardians/{gid}/phone` |
| Loading / Error | Skeleton · error view; `scope.forbidden` renders "not available to you" |

#### EXEC-M-10 · Families & groups (`/manage`, `/manage/groups/new`, `/manage/families/new`)

| | |
|---|---|
| Purpose | Put every child in a group, invite every family, create groups |
| Components | Three tabs — **Unassigned** (multi-select → assign sheet showing each group's capacity after the move, with an over-capacity warning and confirm), **Families** (status chip active / partial / pending, resend invitation, add child), **Groups** (capacity bar, "assign children"); **New group** form (name, category chips, capacity stepper, educators, optional children, checklist, recorded marker — no schedule here, it is set on the group afterwards); **New family** wizard (guardians → children with main group or "later" → review with what will happen) |
| API | `GET /children?unassigned=true`, `POST /groups/{id}/children`, `GET /families`, `POST /invitations`, `GET /groups`, `GET /educators`, `GET /categories`, `POST /groups`, `POST /families` |
| Empty | Unassigned: "every child is in a group" (reassuring) |

#### EXEC-M-10b · Family detail (`/manage/families/:familyId`)

| | |
|---|---|
| Purpose | Change a household after it was created: correct a guardian, link a second one, unlink one, add a child, fix a child's name or birth date (`ACC-05`, RAEED-9) |
| Entry points | Tap a family card on the Families tab; the card's "+ طفل" opens the page with the add-child sheet already up (`?action=add-child`) |
| Components | Header (family label, status chip); **Guardians** card — one row per guardian: name · relationship, account chip, masked phone hint (`•• 34`), then edit / unlink / resend-invitation actions; "+ ولي آخر" footer; **Children** card — one row per child: name, birth date, group chip (warning tone when unassigned), edit action, tap-through to the child profile; "+ طفل" footer. Edits happen in bottom sheets that reuse the wizard's fields (name, `+212` phone, relationship dropdown; child name, date picker, group pills) |
| User actions | Edit a guardian (only changed fields are sent; typing a new number shows "this signs them out on every device"); unlink after a confirm that says the children keep their other guardians; add a guardian → handover dialog when a password comes back, otherwise "linked an existing account"; add a child; edit a child |
| API | `GET /families/{id}`, `PATCH /families/{id}/guardians/{gid}`, `POST /families/{id}/guardians`, `DELETE /families/{id}/guardians/{gid}`, `POST /families/{id}/children`, `PATCH /families/{id}/children/{cid}` — every mutation returns the family as it now is, and the page replaces its state with it: the family id is the guardian set, so it changes after a link or unlink |
| Loading | The card's `Family` object, pushed as `extra`, renders at once; otherwise a skeleton of two cards |
| Empty | Not reachable — a household has at least one guardian and one child by construction |
| Error | `scope.forbidden` (deleted or out of branch) → "this family is no longer available" with back; `children.last_guardian`, `guardians.phone_taken`, `guardians.already_linked` → one line inside the open sheet or dialog, which stays open with the values kept; offline → the network message with retry |
| Success | Toast, the row re-renders from the returned family; the Families tab, the unassigned list and the touched child profiles are invalidated |

#### EXEC-M-11 · Reports & export (`/reports`)

Attendance by educator and by category as percent **with the raw pair**; educators' planned / delivered / marked-on-time; engagement (guardians signed in, presence answers, homework marked "self-reported" and null until it exists); export with field checkboxes, health fields off by default and flagged, the recorded marker naming the fields, then the file offered through the share sheet. `GET /reports/*`, `POST /reports/exports`.

#### EXEC-M-12 · Structure (`/structure`, admin) and EXEC-M-13 · Logs (`/logs`, admin)

Seasons (open a new one with a label and dates; archive through the reversible confirm; never delete), categories with "age/gender: not set" (open decision #1) and an add-by-name form that deliberately asks nothing else, branches. A fresh installation needs one of each before the first group can be created. Audit log and the health-access view. A non-admin who opens either gets the "admins only" card; the attempt is made and therefore recorded server-side, which the card says.

### Educator surface (`EDU-M-*`)

The educator's app is "light": attendance in under a minute, everything else one tap from Today. Five tabs — Today · Sessions · Groups · Messages · Memories — plus Notifications and More reached from the Today header. An educator who is also a parent switches surface from More; abilities stay the union (`05-authorization.md`). The shell lives at `/home` when the presented role is educator, tab in `?tab=`. Every write below is scoped to the educator's own groups server-side; the app only decides what to show.

#### EDU-M-01 · Today (`/home`, educator role)

| | |
|---|---|
| Purpose | See the next session, how many guardians confirmed, and get to attendance in one tap |
| Components | Gradient header (greeting, name · role, notifications + more buttons, Gregorian and Hijri date); **next session card** (chip "next · in N min", time, title, group · room · N children, four presence tallies as a button — confirmed / late / declined / no answer — then "record attendance" at 52px) or the **attendance-done card** (summary counts, "session summary"); "session without content" nudge per auto-generated session in the next 7 days with an "add" button; three shortcuts (homework, memory, announcement); today's sessions with state chips; "from management": the pinned announcement with a "I've read this" acknowledgement that turns success when confirmed |
| User actions | Open presence overview; record attendance; add content; shortcuts; acknowledge |
| API | `GET /educator/today`, `POST /announcements/{id}/confirm-read` |
| Loading / Empty / Error | Header + skeleton cards · no session today → "no session today, next on …" · error view with retry; offline → the cached Today with the offline banner |
| Success | Acknowledging flips the button in place; attendance saved elsewhere replaces the next-session card |

#### EDU-M-02 · Presence overview (`/sessions/:id/presence`)

| | |
|---|---|
| Purpose | Plan the room: how many are coming, who declined and why, who never answered |
| Components | Expected count "of N" with a four-segment bar and legend; children grouped by answer (no answer · declined · late · confirmed) with the reason; footer "remind those who haven't answered (N)" that sends once and turns success; "the reminder is sent once — deadline HH:MM" |
| API | `GET /sessions/{id}/presence`, `POST /sessions/{id}/presence/remind` (409 `presence.reminder_already_sent`) |
| Loading / Empty / Error | Skeleton · "no confirmation was sent for this session" · error view |

#### EDU-M-03 · Attendance (`/groups/:id/sessions/:sessionId/attendance`) — restyled

Same machinery as RAEED-21 (Drift queue, conflict rule, never blocks offline). Presentation follows the design: header with the four status counts and "N unmarked", a dashed "mark the remaining (N) present" button, one row per child with the presence line under the name (confirmed / late / declined + reason / no answer) and **four 40px icon buttons** (present ✓ · late ⏱ · excused ◐ · absent ✕) — any status is one tap from any other; icon-only health badge. Submit label reads "save · alert N guardians" when an unexplained absence is marked. Before saving: unmarked children → warning sheet; unexplained absences → the high-reach confirm naming the children and saying their guardians get an immediate alert (`ATT-07`). Hint "editable for 30 minutes, then through an executive".

#### EDU-M-04 · Sessions (tab) → session (`/sessions/:id`) → content (`/sessions/:id/edit`) → summary (`/sessions/:id/summary`) → cancel sheet

| | |
|---|---|
| Purpose | A week of sessions generated from the group schedule; add content, materials, the summary; cancel or reschedule with everyone told |
| Components | Week header with prev/next, group pills, days (Gregorian · Hijri) with session rows (time, title, group · meta, state chip: ended / upcoming / in N min / no content / cancelled / rescheduled), footer "sessions are created from the group schedule — add content only". **Session**: gradient header (group · theme, title, edit), date · time · room chips, cancellation banner, objectives, materials with visibility chips, homework with the self-reported done bar, "record attendance" / "session summary" pair, "cancel or reschedule". **Content**: title, theme pills, objectives, materials each with a before / after / staff-only segmented control and remove, add file / photo / audio / link, "video ≤ 50 MB · long ones as a link", save. **Summary**: text, photos, the image-rights note naming any `not_allowed` child, reach line, send once. **Cancel sheet**: cancel / reschedule segmented, new slot when rescheduling, reason, "N guardians, co-educators and executives are told · recorded in your name", destructive confirm |
| API | `GET /sessions?from&to&group_id` (generates missing sessions from `weekly_schedule_json`, `SES-02`), `GET /sessions/{id}`, `PATCH /sessions/{id}`, `POST /sessions/{id}/materials`, `DELETE /materials/{id}`, `POST /media` (upload), `POST /sessions/{id}/summary`, `POST /sessions/{id}/cancel` |
| Loading / Empty / Error | Skeleton rows · "no sessions this week" · error view; a session outside the educator's groups → "not available to you" |
| Success | Save returns to the session with a toast; cancel shows the banner and the toast counts who was told |

#### EDU-M-05 · New homework (`/sessions/:id/homework/new`)

Title, instructions, "whole group (N)" / "specific children" with name chips, due-date chips (next three session-free days), "automatic reminder the day before if not marked done", attachment, send "to N children". Specific mode with no child picked is refused in place. `POST /sessions/{id}/homework` (`target_child_ids` null = whole group, `HWK-01`). Done counts everywhere are labelled self-reported (`HWK-03`).

#### EDU-M-06 · Groups (tab) → group (`/groups/:id`, educator) → child (`/children/:id`, educator)

| | |
|---|---|
| Purpose | The educator's groups, each child's standing, the team channel |
| Components | Group cards (name, schedule · room · co-educator, count chip, attendance / homework / next tiles, a care flag when a child has three consecutive absences), footer "adding or moving children is the executive's". **Group**: primary header with roster / homework / team-channel segments; roster rows (icon-only health badge, "attendance n/m" or the care flag, image-rights dot); homework cards with state and the self-reported bar, "no public ranking"; team channel = the group's staff conversation. **Child**: gradient header (age, school), attendance / homework / image-rights tiles; **Health** collapsed → recorded-view confirm → revealed (`AUD-03`); **Guardians** with account status, "message" (opens the child's thread), and an emergency contact whose number is never shown — "call through the app" is a logged server call that opens the dialer; **Notes** staff-only / shared segmented, marked phase 2 |
| API | `GET /groups` (educator rows carry `stats`), `GET /groups/{id}/roster`, `GET /groups/{id}/homework`, `GET /conversations` (staff thread of the group), `GET /children/{id}` (educator view), `GET /children/{id}/health`, `POST /children/{id}/emergency-call` |
| Loading / Empty / Error | Skeleton · "no groups assigned to you" · error view / "not available to you" |

#### EDU-M-07 · Messages (tab) → thread (`/messages/:id`)

Threads grouped by group (child conversations) then "team & management" (staff channels, the executives' thread); availability hours in the header ("outside them messages arrive silently", `MSG-07`); footer "there is no private child conversation — every thread holds the guardians and the group's educators". Thread reuses the conversation screen with a quick-reply row for members. `GET /conversations`, `GET/POST /conversations/{id}/messages`. Voice notes and attachments are not in this iteration.

#### EDU-M-08 · Memories (tab) → new post (`/memories/compose`)

My posts with status (awaiting approval / published / edit requested), albums grid for the season, "+ post". **New post**: media grid (pick from the device, uploaded through `POST /media`), album and audience, caption, "tag the children who appear" list with the image-rights level on each row — tapping a `not_allowed` child is refused in place with the banner "cannot tag … — remove any photo they appear in before publishing" (`WAL-06`), "send for approval" (or "publish" when the album's mode says so). `GET /memories/posts?mine=true`, `GET /memories/albums`, `POST /memories/posts` (422 `memories.consent_blocked` re-checked server-side).

#### EDU-M-09 · Announcement to my groups (`/announcements/compose`, educator)

Group pills with the live reach line ("reaches N guardians + co-educators" / "pick at least one group"), title, body, "ask for a read confirmation" toggle, "urgent (SMS) announcements are the executives'" (`ANN-03`), publish. `GET /announcements/reach` (educator rows carry `groups`), `POST /announcements` with `audience.type = groups` and `ack_required`.

#### EDU-M-10 · Notifications and More (`/notifications`, `/more`, educator)

Notifications reuse EXEC-M-06. More: profile (name, role · groups), role switcher, **availability hours** pills (saved through `PATCH /auth/me/availability`, applied to every group the educator leads), dark mode, language, the locked "attendance reminder · after 30 minutes" row, sign out.

Remaining screens (calendar, materials library, staff channel, announcement composer, structure/people admin on web) follow the same template; write one before implementing, don't skip it because it "looks simple".
