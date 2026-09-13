# RAEED — Implementation Specs

This folder is the implementation-ready breakdown of `../RAEED_Product_Scope.md`, produced through the architecture review in `../CLAUDE.md`'s spirit: concrete decisions, not another restatement of the product scope. Read `01-product-brief.md` first, then the file for whatever you're building.

**Status:** MVP specs, v1.0. Architecture decisions are confirmed (see the table in `01-product-brief.md`); four product-level decisions are still open and tracked there too. Nothing here has been implemented yet — this is the contract to build against.

## How this folder is organized

| File / folder | What's in it |
|---|---|
| [`01-product-brief.md`](./01-product-brief.md) | What RAEED is, roles, MVP scope, confirmed vs. open decisions — read this first |
| [`02-architecture.md`](./02-architecture.md) | System architecture, module boundaries, the critical-alert mechanism |
| [`03-domain-model/`](./03-domain-model/) | `schema.sql` — real PostgreSQL DDL for every MVP table — plus `entities.md` (ER diagrams, field docs) |
| [`04-api/`](./04-api/) | `openapi.yaml` — a working OpenAPI 3.0 contract for the core flows — plus `conventions.md` (envelope, pagination, error codes) |
| [`05-authorization.md`](./05-authorization.md) | RBAC/ability model, with the permission matrix and code-level shape |
| [`06-mobile-app-spec.md`](./06-mobile-app-spec.md) | Flutter architecture, folder layout, routing table, screen specs |
| [`07-backend-spec.md`](./07-backend-spec.md) | NestJS module map, background jobs, environment variables |
| [`08-design-system/`](./08-design-system/) | `design-tokens.json` (colors from the RAEED logo, Amiri typography) plus `style-guide.md` explaining every choice |
| [`09-notifications-spec.md`](./09-notifications-spec.md) | Notification lanes, the instant-absence-alert pipeline, SMS fallback |
| [`10-security-and-privacy.md`](./10-security-and-privacy.md) | Auth, RBAC enforcement, encryption, retention, CNDP notes |
| [`11-testing-strategy.md`](./11-testing-strategy.md) | What's automated vs. manual, per layer |
| [`12-devops-and-environments.md`](./12-devops-and-environments.md) | Environments, CI/CD, OVHcloud target infra, env var reference |
| [`13-roadmap-and-tickets.md`](./13-roadmap-and-tickets.md) | MVP broken into epics and implementation-ready tickets |

## Ground rules while building from these specs

- **Don't duplicate business logic between mobile and backend.** The backend is the single source of truth for every rule in `01-product-brief.md`; the Flutter app calls it, it doesn't re-implement it, even offline (offline writes are queued, not independently validated).
- **Every permission check goes through the ability model in `05-authorization.md`.** No `if role === 'educator'` scattered in controllers or widgets.
- **The design tokens in `08-design-system/design-tokens.json` are the only source of color and type values.** No hex codes or font names hardcoded in app or dashboard code.
- **Children's data rules are non-negotiable defaults**, not something to loosen for convenience during implementation: private storage, signed URLs, audit logging on every health-record view, consent checks before any child media is published.
