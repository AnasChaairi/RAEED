# Design Prompt — RAEED Executive (مشرف) Surfaces

> Paste this whole file as the brief. It is self-contained: every token value, permission rule
> and data field it needs is inline. If you are running inside the RAEED repo, the authoritative
> sources are `specs/08-design-system/design-tokens.json`, `specs/05-authorization.md`,
> `specs/04-api/openapi.yaml`, `specs/03-domain-model/schema.sql`, `specs/06-mobile-app-spec.md`.

---

## 1. What you are designing

RAEED is a private platform for a Moroccan Islamic educational association (أكاديمية الطفل الرائد)
serving children aged 5–18. Three roles revolve around each enrolled child: **parents (أولياء الأمور)**,
**educators (مؤطرون / mo'atirin)**, **executives (مشرفون / moshrifin)**. Children are **not** users.

Parent and educator mobile screens already exist and are built (sign-in, consent, Parent Home,
child profile, attendance marking). **This brief covers only the executive role**, which has two surfaces:

| Surface | Sections | Status |
|---|---|---|
| **Executive web dashboard** (React + TypeScript) — the primary surface | Dashboard · Structure · People · Sessions · Attendance · Announcements · Memories moderation · Messages · Reports · Logs · Settings | **Not started — design everything** |
| **Executive mobile** (Flutter, same app as parents/educators) | Dashboard · Announcements · Messages · Memories · Groups | Only a placeholder `/dashboard` route exists |

Design **both**, web first, clearly separated. Do not redesign parent or educator screens — but match
their visual language exactly (§4), because executives who are also educators switch roles inside one account.

An **Admin** is an executive with two extra powers: structure/user management, and audit-log access.
Design one surface with admin-only areas marked, not two products.

---

## 2. Who the executive is, and what the design must respect

The executive is a board/management member of a small association (~200 children, one branch to start,
multi-branch capable). They are not a data analyst. They open the dashboard to answer, in order:

1. Is any child unaccounted for right now? (sessions with missing attendance, absence alerts)
2. Is the association running — sessions delivered, attendance recorded, parents responding?
3. Does anything need my decision? (profile-change approvals, moderation queue, reported messages, data requests)
4. Can I get a number or a list out of this for the board / the insurer / a funding partner?

**Four hard rules that shape every screen:**

- **Safeguarding first.** Every record is about a child who is not a user. Default to the most private
  option. Never design a bulk "show all health info" view; health data is revealed per child, deliberately,
  and **every view is logged** (`AUD-03`) — the UI must say so at the moment of reveal, not in a footer.
- **Executive power is visible power.** Executives can read any conversation and see everything; this is
  disclosed to users by design (`MSG-08`). Any oversight action (reading a thread, correcting attendance,
  exporting, viewing health info) needs a small, non-shaming **"this action is recorded"** affordance.
- **Phone numbers are never shown to other users** (`MSG-06`). An executive *can* see a guardian's
  contact, but the pattern is a reveal/copy affordance with a reason, not a plain column in a table.
- **Scanned, not read.** The dashboard escalates by colour and shape (severity chips), never by making
  the reader compare numbers.

---

## 3. Design foundations — non-negotiable

### 3.1 Colour tokens (the only palette; never introduce a hex)

Light / dark, both required for every screen.

| Token | Light | Dark | Use |
|---|---|---|---|
| `bg` | `#F6F9FC` | `#0B0F14` | Page ground |
| `surface` | `#FFFFFF` | `#121820` | Cards, tables, sheets |
| `surfaceAlt` | `#EEF3F8` | `#1A222C` | Table header rows, inset panels, chart plot ground |
| `ink` | `#0E1726` | `#E8EEF3` | Body text |
| `inkDim` | `#606F81` | `#9FB0BE` | Secondary text, labels, axis labels |
| `border` | `#DCE6F0` | `#28323D` | Card and table separation (the main separator — see §4) |
| `primary` | `#0C4A8B` | `#2BB3E8` | Primary actions, links, active nav |
| `primaryOn` | `#FFFFFF` | `#04202E` | Label on primary |
| `primarySoft` | `#EAF2FA` | `#0E3346` | Selected row, active tab ground, info tint |
| `accent` (text-safe gold) | `#8A6413` | `#F6A21E` | Gold that carries **text** |
| `accentDecorative` | `#F6A21E` | `#F6A21E` | Gold fills, icons, borders ≥3px, the star motif — **never small text in light mode** |
| `accentOn` | `#231402` | `#231402` | Label on an amber fill |
| `accentSoft` | `#FFF6E7` | `#33290F` | Amber tint ground |
| `success` | `#1C7A55` | `#34C185` | Present, delivered, approved |
| `warning` | `#A85A0A` | `#E0A544` | Late, pending, over capacity |
| `danger` | `#CD331C` | `#E2685A` | Absent-without-notice, blocked, consent violation |
| `info` | `#11769E` | `#2BB3E8` | Excused, neutral notices |
| `successSoft` / `dangerSoft` / `warningSoft` / `infoSoft` | `#E4F5EC` / `#FEE9E3` / `#FFF3DC` / `#EAF7FE` | `#10301F` / `#3A1710` / `#332711` / `#0E3346` | Status chip grounds |

Brand gradient (headers, sign-in, the one decorative surface): `primary` → `accentDecorative`,
derived from the logo's blue-to-gold running-child mark. Use it sparingly — one gradient region per screen, max.

**Semantic colours are not brand hues.** A warning must never look like "brand gold".
Status must never be colour-only: pair every status with an icon or a word (colour-blind + monochrome print).

### 3.2 Type

| Role | Family | Notes |
|---|---|---|
| Arabic display + body | **Amiri** | Ships **400 and 700 only**. Build Arabic hierarchy with size, colour and spacing — never a 500/600 weight. |
| Quran/hadith excerpts | **Amiri Quran** | Content blocks only, never UI chrome |
| Latin headings (FR/EN) | **Lora** | |
| UI chrome, both scripts | **Public Sans** | Buttons, tabs, table headers, form labels, timestamps, chips, numbers |

Scale (size / weight): display 32/700 · h1 26/700 · h2 21/700 · h3 18/700 · body 16/400 ·
bodySmall 14/400 · caption 12/500 (+0.02em).
Arabic line-height runs looser than Latin (body 1.8 vs 1.5) — Arabic layouts need more vertical air; do not
design a dense Latin table and assume the Arabic version fits.

### 3.3 Space, radius, elevation, targets

- Spacing scale: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64. Nothing off-scale.
- Radius: 6 · 10 · 14 · 18 · 22 · pill(999). Cards sit at 14–18, chips pill, inputs 10.
- **Surfaces are flat by design.** Separation comes from `border` + a `surface`/`surfaceAlt` shift, not shadow
  stacks. One elevation step exists and is reserved for genuinely floating things (menus, sheets, toasts).
- Touch/click targets: **44px min**, **52px for primary actions**. This holds on web too — executives use
  laptops with trackpads and sometimes a tablet.

### 3.4 Arabic, RTL, numerals, dates

- **Arabic is the default language**, right-to-left. Design **RTL as the primary** artboard, with an LTR
  (French/English) mirror for at least: sign-in, Dashboard, one table, one composer, one detail page.
- **Western digits 0–9** (Moroccan convention — *not* Eastern Arabic-Indic), pinned to `ar_MA`.
- **Tabular figures** wherever digits align: attendance counts, stat tiles, table number columns, chart axes.
- **Hijri date shows alongside Gregorian** everywhere a date is displayed (Gregorian is the system of record).
  The org has a ±1 day Hijri offset setting — the design must show the pair, e.g. `السبت 20 سبتمبر · 8 ربيع الأول`.
- Chevrons, back arrows, progress and trend directions mirror. Play buttons and the phone icon do not.
- Arabic plurals need all six ICU categories — never design a string that hardcodes "2 children".

### 3.5 Accessibility

WCAG AA for all text (the tokens above are pre-validated; combinations you invent are not).
Respect OS text scaling to **130%+ without clipping** — show at least one screen at 130% in Arabic.
Full keyboard path for every table and composer on web. Screen-reader labels for every status chip
and icon-only control. Never rely on hover alone to expose an action in a table row.

---

## 4. The existing visual language — match it

The parent/educator app was just rebuilt to a design canvas called "RAEED App". Its established patterns:

- A **brand-gradient header** that curves into the content below (bottom radius 22), carrying: greeting,
  today in both calendars, a one-line summary of what's on, and a bell with an unread dot.
  Content cards scroll up against it, so the page reads as one surface rather than a band plus a list.
- **Flat cards** on `surface` with a `border`, radius 14–18, generous internal padding (16–24).
- **Status pills** — pill radius, `*Soft` ground + the matching semantic ink, icon + word.
- **Skeleton loaders shaped like the real content** — never a bare centred spinner.
- **Offline banner** as a slim non-blocking strip, not a modal.
- **Health alerts are icon-only in list views**, with the text behind a deliberate tap/click.
- A **"needs your reply" (يحتاج ردّك)** prompt card pattern for anything awaiting the user's action.

Carry all of this into the executive surfaces. The web dashboard is the same brand in a data-dense layout:
same tokens, same chips, same flat-bordered cards — not a generic admin template.

---

## 5. Executive permissions — design inside these lines

| Action | Executive | Admin |
|---|---|---|
| View any child profile | Yes (branch-scoped if restricted) | Yes |
| View health info | Yes — **every view logged** | Yes — logged |
| Edit child profile / approve change requests | Yes | Yes |
| Manage seasons, categories, groups, users, role assignments | **No** | **Yes** |
| Plan sessions, mark/correct attendance, assign homework | All groups — corrections logged | All groups |
| Read any conversation | Yes — logged and disclosed to users | Yes — logged |
| Publish announcements | Any audience | Any audience |
| Moderate Memories Wall posts | All posts | All posts |
| Export data | Yes — logged | Yes — logged |
| View audit logs | **No** | **Yes** |

An executive may be restricted to a single **branch**. Design the branch scope as a visible, persistent
context indicator, not a hidden filter — a restricted executive must never wonder whether they are seeing everything.

---

## 6. Web dashboard — page inventory

Shell for every page: left nav (RTL: right) with the 11 sections, a persistent context bar
(**season selector · branch scope · search**), the user/role switcher, and a notification bell.
Breakpoints: **1440 primary**, **1024**, **768 (tablet, read-mostly)**. Tables must survive 1024 without
horizontal chaos — decide per table which columns collapse into the primary cell.

For **every** page below, produce: **loading · empty · error · success**, plus **permission-denied**
where the page is admin-only. Loading = content-shaped skeletons.

### EXEC-W-01 · Sign-in
Phone number → 6-digit OTP (email as alternative). Invitation-only: **no sign-up affordance anywhere** —
instead a line pointing at the association. Brand gradient + full logo lockup (wordmark version, not the
app icon crop). Error states: wrong code, expired code, rate-limited ("too many attempts, try in N minutes"),
deactivated account. Language switcher (ع / FR / EN) present before sign-in.

### EXEC-W-02 · Dashboard (overview) — `DSH-01, DSH-02, DSH-06`
The single most important screen. Top-to-bottom priority:
1. **Alerts panel first, above the stats** — sessions with attendance not recorded, groups over capacity,
   absence alerts sent today, pending approvals, reported messages, posts awaiting moderation.
   Each row is a severity chip + a plain sentence + a direct action link. Severity escalates by colour
   *and* position, and an empty alerts panel is a designed, reassuring state ("لا شيء يحتاج انتباهك اليوم"),
   not a blank box.
2. **Stat tiles**: children · families · groups · educators, each with a period delta and a breakdown
   affordance (by branch / category / group / gender).
3. **Attendance**: this week's rate + a weekly trend line, with a per-category small-multiple or ranked bar.
4. **Today**: sessions in progress / upcoming / cancelled, with attendance-recorded state per session.
Filters (season, date range, branch, category, group) apply to the whole page and are visibly sticky
(`DSH-03`). Design the "filtered to a narrow slice → small numbers" case: percentages over tiny denominators
must be shown with their raw counts (`3/4`, not `75%` alone).

### EXEC-W-03 · Structure → Seasons (Admin) — `ORG-01`
Season list with status (draft / active / archived), dates, and counts. Create/edit. **Archiving, never
deleting** — and the confirm step must spell out what archiving affects (groups, enrolments, albums).

### EXEC-W-04 · Structure → Categories (فئات) (Admin) — `ORG-02`
The association's **8 categories, named in Arabic**: الأشبال · النخبة · الفتية · اليافعون · الصغار ·
الفراشات · الزهرات · اليافعات. Each has an age range and a gender lock.
**Age ranges and gender are an unresolved board decision** — design the fields as clearly "not yet set"
(an inviting empty state, not a validation error), and never bake an age number into a mockup.

### EXEC-W-05 · Structure → Groups (Admin) + Group detail (all executives) — `ORG-03, ORG-04`
List: name, category, season, branch, capacity vs. enrolled (with an over-capacity state), educators,
weekly schedule, location. Detail tabs: **Roster** (add / move / remove a child **with history preserved** —
design the "moved mid-season" trace), **Educators** (assign/unassign, several per group), **Schedule**
(weekly recurrence that generates sessions), **Sessions**, **Homework**.

### EXEC-W-06 · Structure → Branches (Admin) — `ORG-05`
Small: name, address, executives in charge. One branch today, several supported — the design must not
look broken with exactly one row.

### EXEC-W-07 · People → Children — `CHD-02, CHD-03, AUD-03`
Searchable, filterable list (season, branch, category, group, gender, status). Columns carry a
**health-alert badge as icon-only**. Row click → child profile.

### EXEC-W-08 · People → Child profile
Sections: identity (name, date of birth, photo, school + school level), groups (main + others),
guardians and their relationship, emergency contacts, **health information (allergies, conditions,
medication, dietary needs, special needs)**, consents (privacy + image rights, with version and date),
attendance history and statistics, homework, materials, and the child's conversation.
**Health information is collapsed behind a deliberate reveal that states the view is recorded**, and the
field list itself is an unresolved decision — design the container, not a fixed list of fields.
Image-rights level must be unmistakable at a glance: `Allowed` · `App only` · `Not allowed`.

### EXEC-W-09 · People → Families / guardians — `ACC-05`
Guardian list with linked children and account status (invited / active / deactivated).
Linking and unlinking a guardian is **executive-only and custody-sensitive** — design a confirm step that
says who loses access to what, and refuse the "last guardian" case with a clear explanation rather than a
generic error. Phone numbers behind a reveal/copy affordance.

### EXEC-W-10 · People → Staff (educators and executives) — `ACC-07, ACC-08`
List with role, groups led, branch scope, availability hours, last active.
Detail: role assignment (Admin only), group assignments, availability window, **deactivate** — which revokes
access on all devices immediately while keeping history. That confirm step is the important part of this page.

### EXEC-W-11 · People → Invitations — `ACC-02`
Send and track invitations (SMS / WhatsApp / email) for guardians and staff. States: sent · opened ·
activated · expired · resend. Bulk send. Show the activation-rate number executives are measured on.

### EXEC-W-12 · People → Change-request queue — `CHD-04`
Parent-requested profile corrections in three tiers: applied instantly · auto-approved with notification ·
**pending approval** (health fields, guardian linking). The queue shows the requester, the child, a
**before → after diff**, and approve/reject with a reason. Health-field diffs follow the same reveal rule.

### EXEC-W-13 · People → Bulk import (Admin) — `ORG-06`
Excel import of families, children, groups. Four steps: upload → column mapping → **dry-run preview with
row-level validation errors** → commit with a result summary. The preview is the whole point: design the
partial-failure case (142 rows valid, 8 with errors) so no one can commit blind.

### EXEC-W-14 · Sessions → All sessions — `SES-10`
Cross-group calendar (week / month) and list, filterable, with per-session state: planned · delivered ·
cancelled · **attendance not recorded** (the state executives act on). Both calendars on every date.

### EXEC-W-15 · Sessions → Session detail — `SES-01, SES-03, SES-04, SES-05, SES-06`
Date, time, place, title, objectives, theme; materials with **per-material visibility**
(before session / after session / staff-only); presence-confirmation summary (confirmed / absent / no answer);
attendance sheet; session summary. Actions: cancel or reschedule — which notifies the group's parents and
educators, so the confirm step states exactly who gets notified and when.

### EXEC-W-16 · Attendance oversight + corrections — `ATT-06, ATT-07, ATT-08`
The safeguarding-critical view. Three parts: **sessions missing attendance** (escalated by how overdue),
**absence alerts sent** (child, session, time sent, delivery state including the SMS fallback), and
**attendance correction** — where a correction is a **new record referencing the one it corrects**, never an
overwrite. Design that history as a visible trail: who marked what, when, from which device, and who
corrected it. Per-child and per-group attendance drill-down with the four statuses:
present · absent · late · excused.

### EXEC-W-17 · Announcements → List — `ANN-05`
All announcements with audience, priority, publish and expiry dates, pinned state, and read rate.
Tabs or filters for scheduled · live · expired · draft.

### EXEC-W-18 · Announcements → Composer — `ANN-01, ANN-02, ANN-04, ANN-05`
Title, body, banner/image, attachments. **Audience targeting is the hard part**: everyone · parents only ·
educators only · specific branches / categories / groups — with a live **"this reaches N people"** count and
a plain-language summary of the audience before sending. Schedule for later, expiry date, pin to top,
and **urgent priority**, which fires the critical notification lane (push + SMS fallback) and therefore needs
a deliberate confirm that names the cost and the reach.

### EXEC-W-19 · Announcements → Read statistics — `ANN-06`
Read rate over time, and for important notices the list of people who confirmed "I have read this" versus
those who haven't — with a nudge action. Never shame individuals in an aggregate view; the list is an
operational tool, so keep it behind a step.

### EXEC-W-20 · Memories moderation → Queue — `WAL-07`
Posts awaiting approval (per album moderation mode), plus already-published posts that can be hidden.
Each item: media thumbnails, album, season, author, groups concerned, tagged children **with each child's
image-rights level shown on the thumbnail**, and any **consent-blocked** flag. Actions: approve · request
change · hide (never hard-delete). **The default moderation mode is an unresolved board decision** — design
both "publish then moderate" and "approve first" as switchable states of the same queue.

### EXEC-W-21 · Memories moderation → Albums & post detail — `WAL-03, WAL-05, WAL-06, WAL-10`
Albums per event/camp, season-scoped, timeline view. Post detail: media, audience (always a private,
explicitly-named audience — **there is no share-outside-the-app affordance anywhere, ever**), tagged children,
consent state per tag, reactions. Design the hard case: a child's image rights are downgraded *after* a post
went live, and the post must be re-checked and pulled.

### EXEC-W-22 · Messages → Conversations (oversight) — `MSG-08, MSG-10`
List of conversation threads by type: **per-child** (guardians + all the group's educators),
**staff channel per group**, **executive threads**. Unread and last-activity. Opening a thread an
executive is not a member of is oversight: it is **logged and disclosed** — design that moment honestly and
without drama (a one-line notice in the thread header, not a scary modal).
Thread view: text, photos, files, voice notes, read receipts. Actions: hide a message
(**hidden, never permanently deleted**, with the hidden state visible to executives), handle a report,
mute or restrict a user. A separate **reports queue** with reporter, reason, thread context, and resolution.

### EXEC-W-23 · Reports — `DSH-02, DSH-04, DSH-05, DSH-07, HWK-05`
Four report families, each filterable by season / date range / branch / category / group:
- **Attendance**: rate by category, group, educator, child; weekly trend.
- **Educator activity**: sessions planned vs. delivered, attendance recorded on time, average reply time.
- **Engagement**: parent activation rate, presence-confirmation response rate,
  homework completion **explicitly labelled "self-reported"** wherever it appears.
- **Exports**: Excel and PDF for the general assembly, funding partners, and trip insurance lists —
  with a column/field picker, and a clear statement that the export **is logged** and may contain
  health data. Design the export-in-progress and export-ready states.
Charts follow the token palette; no gradients in data marks, no more than 5 categorical series,
and never colour as the only encoding.

### EXEC-W-24 · Logs → Audit log (Admin) — `AUD-02, AUD-04`
Who · what · when · from which device, filterable by actor, action type, resource type, date range.
Actions include logins, creations, edits, deletions, posts, hidden messages, exports, consent changes,
attendance corrections. **Logs are append-only and cannot be edited, even by an admin** — the design must
make that visible (no edit/delete affordances at all, and a line stating the retention period, which is
itself an unresolved decision).

### EXEC-W-25 · Logs → Health-data access log (Admin) — `AUD-03`
Specifically: who viewed which child's health information, and when. This is the page that proves the
promise made on every reveal in `EXEC-W-08`, so it deserves its own clear, quiet layout.

### EXEC-W-26 · Settings — org (Admin) — `ACC-09, MSG-07, SES-08, WAL-07`
Association profile, branches, **Hijri offset (±1 day)**, default language, default educator availability
hours, Memories Wall moderation default, notification templates, material size/format limits,
retention periods (unresolved — show as configurable, unset).

### EXEC-W-27 · Settings — my account — `ACC-04, ACC-09, ACC-10`
Profile, language, notification preferences with the **critical lane visibly locked** (absence alerts,
urgent announcements, session change <24h — greyed with a one-line reason), active devices with
per-device sign-out, role switcher for multi-role users, and in-app **data-export / account-deletion
requests**. Also design the executive-side **queue** for handling those requests from other users.

### EXEC-W-28 · Notification centre
All notifications, unread counter, grouped low-priority items ("12 new photos in رحلة الربيع"),
filter by category. The centre is the source of truth; push is only the interrupt.

### EXEC-W-29 · System states
Global states as a set: 403 (executive hitting an admin-only page), 404, session expired, server error,
offline/degraded, maintenance, and the "you are branch-restricted" explanation.

---

## 7. Executive mobile — screen inventory

Phone-first (entry-level Android, 360–412dp wide). Same tokens, same brand-gradient header pattern as
Parent Home. Bottom nav with **5 items**: Dashboard · Announcements · Messages · Memories · Groups,
plus a "More" affordance for settings and role switching.

- **EXEC-M-01 · Dashboard.** Gradient header (greeting, both dates, what's on today, bell).
  Then: alerts panel as severity-chipped cards (sessions missing attendance, over-capacity groups,
  pending approvals), then stat tiles (children / families / groups / educators) with tabular figures,
  then today's sessions. This screen is **scanned while standing up** — nothing below the fold should be
  needed for the "is anything wrong?" question.
- **EXEC-M-02 · Announcements** — list + composer with the same audience targeting and urgent-mode confirm
  as the web, reduced to a phone-sized flow (audience picker as a sheet with a live reach count).
- **EXEC-M-03 · Messages** — thread list, thread view with voice notes, oversight notice, hide/report actions.
- **EXEC-M-04 · Memories** — wall view plus the moderation queue as a swipe-through review flow
  (approve / hide), with image-rights state on every tagged child.
- **EXEC-M-05 · Groups** — group list → group detail (roster, sessions, homework) → session →
  attendance sheet, including the correction flow with its visible history.
- **EXEC-M-06 · Notification centre**, **EXEC-M-07 · More/settings + role switcher**,
  **EXEC-M-08 · Offline and error states** (executives read sessions and children offline; writes queue).

---

## 8. Components to specify once and reuse

Deliver these as a small component sheet, in light and dark, RTL and LTR:

1. **Status chip** — present · absent · late · excused · confirmed · no answer · pending · approved ·
   hidden · blocked · cancelled. Icon + word + `*Soft` ground.
2. **Severity chip / alert row** — info · warning · danger, with an escalation state for "overdue".
3. **Stat tile** — label, big tabular number, delta, breakdown affordance, and a loading skeleton.
4. **Chart set** — trend line, ranked bar, small multiple, sparkline; axis and legend treatment;
   the "too little data" state.
5. **Filter bar** — season · branch · category · group · date range, with applied-filter chips and a reset.
6. **Data table** — header on `surfaceAlt`, row hover/selected, sticky first column, pagination,
   column picker, row actions that are keyboard-reachable, and the 1024 collapse rule.
7. **Health-info reveal** — the collapsed badge, the "this view is recorded" moment, the revealed panel.
8. **Image-rights indicator** — three levels, legible on a photo thumbnail.
9. **Audience picker** with live reach count and plain-language summary.
10. **"Recorded action" affordance** — the small, consistent marker for logged oversight actions.
11. **Confirm dialog** patterns: destructive-but-reversible (hide, archive), irreversible (deactivate,
    unlink guardian), and high-reach (urgent announcement) — three visually distinct weights.
12. **Empty states** — the reassuring kind (nothing needs you) vs. the data-problem kind (this should
    not be empty; contact the association) must not look alike.
13. **Skeletons** shaped like each content type; **offline banner**; **toast**.
14. **Role switcher** for a user who is both educator and executive.

---

## 9. Do not invent these

Four product decisions are **open**. Design containers and "not yet set" states; never a plausible-looking value.

1. Category age ranges and gender locks (the 8 فئات).
2. The health-information field list (pending a CNDP data-protection filing).
3. The Memories Wall default moderation mode (publish-then-moderate vs. approve-first).
4. Data retention periods (child records, health data, albums, conversations, audit logs).

Also out of scope — do not design them into the navigation:
camps and events, enrolment, fees and payments, homework submissions with feedback,
authorized pick-up persons, repeated-absence flags, the end-of-season memory book (all **V1**);
parent-to-parent messaging, public/social features, child accounts, online payments, live video,
school grades, donation management (**never**).

---

## 10. Deliverables

For each page in §6 and §7:

1. A **written screen spec before the visual** — purpose · entry points · components · user actions ·
   data shown · **loading / empty / error / success** (plus permission-denied and offline where they apply).
   Do not skip this for a page that "looks simple".
2. **RTL Arabic as the primary layout**, at 1440 and 1024 for web, 390 for mobile.
3. **Light and dark**, both.
4. At least one screen shown at **130% text scale in Arabic**, unclipped.
5. An LTR mirror for sign-in, the Dashboard, one table, one composer, one detail page.
6. The §8 component sheet, with the token name annotated on every colour — **no raw hex in any annotation**.
7. A short rationale note per page: what question it answers, and what the executive does next.

Use realistic Arabic content — real category names, plausible Moroccan guardian and child names,
group names, session titles (Quran memorisation, hadith, akhlaq, skills workshops). Placeholder
lorem text in an Arabic RTL layout hides real line-length and line-height problems, so avoid it.

**Tone:** calm, trustworthy, unhurried institutional warmth — this is a small association caring for
children, not a SaaS analytics product. The tagline it is designed around:
**صالح في نفسه، مصلح لغيره** — "upright in oneself, uplifting to others."
