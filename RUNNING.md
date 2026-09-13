# Running RAEED locally

Three pieces: Postgres + Redis in containers, the NestJS API, and the Flutter
app. The API is the only one that needs the containers.

Everything below is local-development only. No cloud infrastructure is
provisioned (`specs/12-devops-and-environments.md`).

## Prerequisites

| | |
|---|---|
| Docker **or** Podman | Podman works rootless — see the note below |
| Node 20+ | for the API |
| Flutter 3.47+ | for the app. This machine has it at `~/flutter`, not on `PATH` |

**Podman instead of Docker.** `podman compose` delegates to the Docker Compose
plugin, so install it once and point the API socket at it:

```bash
mkdir -p ~/.docker/cli-plugins
curl -sSL -o ~/.docker/cli-plugins/docker-compose \
  https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64
chmod +x ~/.docker/cli-plugins/docker-compose
systemctl --user enable --now podman.socket
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
```

Then use `podman compose` wherever this document says `docker compose`.

## 1. Start Postgres and Redis

```bash
cp infrastructure/.env.example infrastructure/.env.local
cd infrastructure
docker compose up -d postgres redis
```

Both report healthy within a few seconds. The compose file also defines the
`api` service; running it in a container is optional, and the loop below is
faster for development.

## 2. Set up the database

```bash
cd backend
npm install
set -a && . ../infrastructure/.env.local && set +a

npm run migration:run   # applies specs/03-domain-model/schema.sql + the grants
npm run seed            # local development data
```

`migration:run` connects as the owner role. The API itself connects as
`raeed_app`, which has **INSERT and SELECT on `audit_log_entry` and nothing
else** — so a compromised API cannot erase the record of what it did
(`AUD-04`). You can check that directly:

```bash
docker exec raeed-postgres-1 psql -U raeed -d raeed -c \
  "select has_table_privilege('raeed_app','audit_log_entry','DELETE')"
--  f
```

## 3. Run the API

```bash
cd backend
set -a && . ../infrastructure/.env.local && set +a
npm run start:dev          # or: npm run build && node dist/main.js
```

```bash
curl localhost:3000/api/v1/health
# {"status":"ok","database":"up"}
```

### Signing in

There is no SMS provider locally, so **the OTP is printed to the API's own
log** — with the phone number masked, because
`specs/10-security-and-privacy.md` forbids raw numbers in application logs even
as a development convenience. The config refuses to start outside development
without a real provider key, so this cannot silently become production
behaviour.

Seeded accounts:

| Phone | Role |
|---|---|
| `+212600000001` | Parent — three children across two groups |
| `+212600000002` | Educator of الأشبال أ, **and** a parent |
| `+212600000003` | Executive |

```bash
curl -X POST localhost:3000/api/v1/auth/otp/request \
  -H 'Content-Type: application/json' -d '{"phone":"+212600000001"}'
# then read the six-digit code from the API log
```

Note the rate limit is real: five OTP requests per hour per number
(`specs/10-security-and-privacy.md`). If you hit it while testing, clear it:

```bash
docker exec raeed-redis-1 redis-cli --scan --pattern 'otp:rate:*' \
  | xargs -r -n50 docker exec raeed-redis-1 redis-cli DEL
```

## 4. Run the app

`device_id` must be a UUID — the mobile app generates one per install.

### On Android (the real target)

Needs the Android SDK, which is not installed on this machine. Once it is:

```bash
cd mobile
flutter run --dart-define=RAEED_API_BASE_URL=http://10.0.2.2:3000/api/v1
```

`10.0.2.2` is the host as seen from an Android emulator — `localhost` there is
the emulator itself. On a physical device, use your machine's LAN address.

### In a browser (quickest way to look at it)

```bash
cd mobile
flutter build web --dart-define=RAEED_API_BASE_URL=http://localhost:3000/api/v1
cd build/web && python3 -m http.server 8080
```

Open <http://localhost:8080>.

**Two caveats on the web build.** It is a convenience for looking at screens,
not a supported target:

- **The attendance screen will not work.** Its offline queue is Drift over
  SQLite, and running that on the web needs a `sqlite3.wasm` worker that is not
  set up here. On Android it works as tested.
- Secure storage falls back to browser storage, so "stay signed in" behaves
  differently from a real device.

## What works end to end today

Verified against the running stack:

- OTP sign-in, token issuance, refresh rotation (a replayed refresh token is
  refused), `/auth/me` returning scope derived live from the database
- `GET /children` scoped correctly — the parent and the educator see genuinely
  different sets, and a parent asking for another family's child by exact id
  gets `403 scope.forbidden`
- `GET`/`POST /consent`, `GET /announcements`
- The health list payload carries a boolean flag and no health text; the detail
  route carries the record
- **Attendance.** `GET`/`PATCH /sessions/{id}/attendance`, with the conflict
  rule (a stale `recorded_at_client` is refused with both sides returned) and
  corrections stored as a new row pointing at the superseded one
- **The critical absence-alert pipeline.** An unexplained absence enqueues on
  the dedicated `critical` queue before the PATCH returns, and the worker
  dispatched it in **14 ms** from the write in local testing — the SLA is p95
  under 30 s (`specs/02-architecture.md`). A declared absence correctly fires
  nothing.
- `GET /presence-confirmations/pending` and `POST .../answers`, including two
  siblings sharing one confirmation

## Not built yet

- **FCM and SMS delivery.** The critical pipeline runs end to end and the worker
  logs exactly what it would dispatch, but no provider is wired up — so a real
  phone does not buzz yet. Both are deliberately explicit rather than stubbed as
  no-ops, because a silent success would make a broken alert pipeline look
  healthy.
- The load test that proves the p95 SLA under realistic concurrency
  (`RAEED-19`) — without it, Epic C is not done.
- Session auto-generation from the weekly schedule, homework, materials
- Messaging, Memories Wall, dashboard, the audit interceptor on other modules
- The React executive dashboard

## Stopping

```bash
cd infrastructure && docker compose down        # keeps the data
cd infrastructure && docker compose down -v     # wipes it
```
