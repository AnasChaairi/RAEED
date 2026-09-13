# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What RAEED is

A private mobile + web platform connecting three roles around each enrolled child: **parents**, **educators (mo'atirin)**, and **executives (moshrifin)**. See [README.md](./README.md) for the full role and release description.

- **MVP**: categories (فئات) / groups / weekly sessions, presence confirmation + attendance with instant absence alerts, homework tracking, session materials, safeguarded messaging + targeted announcements, private Memories Wall (photos/videos), executive dashboard + audit logs.
- **V1**: camps and events, enrollment, fees.

## Specs are the contract

`specs/` is the implementation-ready breakdown of `RAEED_Product_Scope.md`. **Read the relevant spec before writing code for a feature** — don't re-derive decisions that are already settled there.

| Building | Read first |
|---|---|
| Anything | [`specs/01-product-brief.md`](./specs/01-product-brief.md) — confirmed vs. open decisions |
| Mobile app | [`specs/06-mobile-app-spec.md`](./specs/06-mobile-app-spec.md) (architecture, routing table, screen specs) |
| Any permission check | [`specs/05-authorization.md`](./specs/05-authorization.md) |
| Any API call | [`specs/04-api/openapi.yaml`](./specs/04-api/openapi.yaml) + [`conventions.md`](./specs/04-api/conventions.md) |
| Any UI | [`specs/08-design-system/`](./specs/08-design-system/) — tokens are the only source of color/type |
| Any test | [`specs/11-testing-strategy.md`](./specs/11-testing-strategy.md) — the 6 non-negotiable cases |
| Ticket scope | [`specs/13-roadmap-and-tickets.md`](./specs/13-roadmap-and-tickets.md) — `RAEED-N` IDs |

Four product decisions are still **open** (category age/gender ranges, health-field list, Memories Wall moderation default, retention periods). Do not guess them into the schema or UI — leave them nullable/configurable and flag them.

## Stack

Confirmed in `specs/01-product-brief.md` — build against these, don't re-derive them.

| Layer | Choice |
|---|---|
| Mobile | Flutter 3.x / Dart 3 — Riverpod (+ codegen), go_router, dio, Drift, flutter_secure_storage |
| Web dashboard | React + TypeScript (executive dashboard only) |
| Backend | NestJS (TypeScript), modular monolith, PostgreSQL, Redis + BullMQ |
| Push / errors | Firebase Cloud Messaging (delivery only) · Sentry |
| Hosting | OVHcloud EU — **local dev only for now**, no cloud infra provisioned |

## Repository layout

See [RUNNING.md](./RUNNING.md) to start the stack and sign in.

```
backend/         NestJS API — modular monolith, Postgres + Redis
infrastructure/  docker-compose stack (works with rootless Podman too)
mobile/          Flutter app (parents, educators, executives-on-mobile)
  lib/core/      theming, i18n, networking, router + guards, session, ability model, Drift database
  lib/features/  one folder per feature, four layers each:
                 domain/ (pure Dart) · data/ · application/ · presentation/
  lib/shared/    cross-feature widgets (skeletons, error view, offline banner)
  tool/          design-token generator
specs/           Implementation specs — the contract, see above
logo/            Brand assets
```

`dashboard/` (React, executives) is spec'd but not yet started.

### Mobile progress

| Ticket | State |
|---|---|
| RAEED-6 app shell — theme, i18n, router + guards, ability model | Done |
| RAEED-2/3/5 OTP sign-in, token refresh, consent capture | Done |
| RAEED-12 Parent Home + child profile | Done |
| RAEED-16/17/21 attendance, offline queue, presence confirmation | Done (mobile); **no server endpoints yet** |
| Everything else in `specs/13-roadmap-and-tickets.md` | Not started — routes render a `PlaceholderScreen` naming the ticket |

### Backend progress

| Ticket | State |
|---|---|
| RAEED-1 local stack, schema migration, audit-log grants | Done |
| RAEED-2/3 OTP, JWT, refresh rotation, devices | Done |
| RAEED-4 CASL abilities + `@CheckAbility` guard | Done |
| RAEED-9/10 children, consent, announcements (read) | Done |
| RAEED-13..21 sessions, attendance, the critical-alert queue | Not started |
| Messaging, Memories Wall, dashboard, audit interceptor | Not started |

## Mobile: install, run, test, lint

The Flutter SDK lives at `~/flutter` (not on the system `PATH` by default — prefix with `~/flutter/bin/` or add it to `PATH`).

```bash
cd mobile
flutter pub get                                    # install dependencies
dart run build_runner build --delete-conflicting-outputs   # Riverpod/Drift/JSON codegen
flutter run --dart-define=RAEED_ENV=dev            # run the app
flutter test                                       # unit + widget tests
flutter analyze                                    # lint / static analysis
dart format .                                      # format
```

Re-run `build_runner` after touching any `@riverpod`, Drift table, or `@JsonSerializable` class — generated `*.g.dart` / `*.freezed.dart` files are committed.

## Domain notes to keep in mind

- **Safeguarding is central**: this app handles data about children. Any feature touching messaging, media (Memories Wall), or personal data should default to the most private/restrictive option, and access should be scoped by role and by the specific child/group relationship — never assume broad visibility.
- **Role-based access is the core model**: parents should only ever see their own child's data; educators should only see their own group(s); executives have the oversight view (dashboard, audit logs) but actions should still be traceable per user.
- **Attendance alerts are latency-sensitive**: absence alerts are meant to be instant — keep this in mind for any notification/queue design.
- **Arabic terms are part of the domain vocabulary** (فئات = categories, mo'atirin = educators, moshrifin = executives). Keep them consistent across code, docs, and UI strings rather than inventing new translations.

## Git workflow — a branch per feature, a commit per iteration

**Non-negotiable. Every feature gets its own branch, and every completed iteration within that feature gets its own commit.** This keeps history structural and reviewable instead of one giant "implemented the app" blob.

For each feature (typically one `RAEED-N` ticket from `specs/13-roadmap-and-tickets.md`):

1. **Branch off `main` before writing any code:**
   ```bash
   git checkout main && git pull
   git checkout -b feat/raeed-6-app-shell
   ```
   Naming: `feat/raeed-<n>-<short-slug>`, or `fix/`, `chore/`, `refactor/`, `test/` for non-feature work. One ticket per branch — don't bundle two tickets into one branch.

2. **Commit after each meaningful iteration**, not only at the end. An iteration is a coherent, self-contained step — the domain layer landing, the data layer landing, the screen landing, the tests landing. Each commit must leave the tree in a working state: `flutter analyze` clean and `flutter test` green before every commit, no exceptions.

3. **Conventional Commits**, with the ticket ID in the scope:
   ```
   feat(raeed-6): wire design tokens into the Flutter theme
   test(raeed-17): cover the offline attendance conflict rule
   fix(raeed-21): keep the attendance chip tappable at 130% text scale
   ```
   Body: what changed and *why*, referencing the spec section it implements. Keep the subject under 72 chars.

4. **Finish the feature, then merge back to `main`** (or open a PR where the team uses them) and delete the branch. Never commit directly to `main` for feature work.

Rationale beyond tidiness: safeguarding-sensitive logic (permission scoping, consent checks, the absence-alert path) has to be auditable commit by commit — a reviewer needs to see *when* a scope check was introduced or changed, which a squashed mega-commit destroys.

## Working conventions

- Keep MVP and V1 scope separate — don't pull V1 features (camps/events, enrollment, fees) into MVP work unless asked.
- Prefer small, reviewable changes. Architecture is now settled in `specs/` — follow it; raise a concern rather than silently deviating.
- **Don't duplicate business logic between mobile and backend.** The backend is the single source of truth for every rule; the app calls it and renders the result. Client-side ability checks exist only to decide which affordances to *show* — never as the enforcement point, and offline writes are queued, not independently validated.
- **No hardcoded hex codes or font names** in app code — everything comes from `specs/08-design-system/design-tokens.json` via the generated theme.
- **No `if (role == educator)` scattered through widgets** — every permission question goes through the central ability model.
- Write the screen spec (loading / empty / error / success) before implementing a screen, using the template in `specs/06-mobile-app-spec.md`. Don't skip it because a screen "looks simple".
- Tests ship with the feature, in the same branch — not as a follow-up. The six non-negotiable cases in `specs/11-testing-strategy.md` are written first.
