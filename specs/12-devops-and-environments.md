# DevOps: Environments, CI/CD, Infrastructure

## Environments

Local → Development → Staging → Production, each with its own database, storage root, and Firebase project (push notifications must never cross environments).

**Current phase: Local only.** Docker Compose runs the API, Postgres, and Redis on developer machines; no Development/Staging/Production infrastructure is provisioned yet (`01-product-brief.md`). The sections below are the target to stand up when the project moves past local dev — don't provision them speculatively.

```yaml
# infrastructure/docker-compose.yml — shape for local dev
services:
  api:
    build: ../backend
    env_file: .env.local
    ports: ["3000:3000"]
    depends_on: [postgres, redis]
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: raeed
      POSTGRES_PASSWORD: local_dev_only
    volumes: ["pgdata:/var/lib/postgresql/data"]
  redis:
    image: redis:7
volumes:
  pgdata:
```

## Git & CI

- Trunk-based, short-lived feature branches, PRs required into `main` — small, reviewable changes per `CLAUDE.md`.
- CI on every PR: lint + typecheck + unit/integration tests (backend against a real ephemeral Postgres, not mocks) + the OpenAPI contract test (`11-testing-strategy.md`).
- Mobile: build both flavors (dev/staging/prod via `--dart-define`) on a release tag; Fastlane-driven signed builds; staged Play Store rollout; TestFlight for iOS beta.

## Target production infrastructure — OVHcloud (EU), confirmed

Provision when the project is ready to leave local dev, sized for ~200 children / one branch:

| | |
|---|---|
| Compute | Single OVHcloud VPS or small managed-container service (Coolify/Dokku) running the API in Docker — no Kubernetes, this scale doesn't need it |
| Database | Managed PostgreSQL on OVHcloud, automated daily backups, point-in-time recovery |
| Object storage | OVH Object Storage (S3-compatible) — wired post-MVP, `07-backend-spec.md`'s `StorageProvider` |
| CDN | In front of signed-URL media delivery only, once object storage exists |
| DNS/TLS | Managed DNS + automatic TLS (Let's Encrypt via the platform) |
| Backups | Daily DB snapshot + a weekly *restore drill* — a backup nobody has restored is not a backup |
| Monitoring | Sentry (errors) + the platform's own uptime/metrics — no separate observability stack at this scale |

## Secrets

Never committed. Local dev uses `.env.local` (gitignored); CI uses GitHub Actions secrets; the target OVHcloud environment uses whatever secret store the chosen compute option provides (Coolify's built-in secrets, or a `.env` injected at deploy time, encrypted at rest on the host) — see `07-backend-spec.md` for the full variable list.

## Rollback

Backend: redeploy the previous tagged Docker image. Mobile: staged Play Store rollout halts automatically on a crash-rate threshold from Sentry; iOS relies on expedited-review for a critical fix since Apple has no staged-rollback equivalent.
