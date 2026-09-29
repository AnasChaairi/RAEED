# Running RAEED locally

Three pieces: Postgres + Redis in containers, the NestJS API, and the Flutter
app. The API is the only one that needs the containers.

Everything below is local development. A shared dev copy of the backend also
runs on an OVH VM — see [DEPLOYING.md](./DEPLOYING.md).

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

Sign-in is a phone number and a six-character password. Every seeded account
uses the password **`raeed1`**. Accounts created from the app get a generated
password that the executive sees once and hands over in person.

Seeded accounts:

| Phone | Role |
|---|---|
| `+212600000001` | Parent — three children across two groups |
| `+212600000002` | Educator of الأشبال أ, **and** a parent |
| `+212600000003` | Executive, also admin |

```bash
curl -X POST localhost:3000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"phone":"+212600000001","password":"raeed1","device_id":"<any uuid>"}'
```

Note the throttle is real: five failed attempts lock a number for fifteen
minutes (`specs/10-security-and-privacy.md`). If you hit it while testing:

```bash
docker exec raeed-redis-1 redis-cli --scan --pattern 'login:failures:*' \
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

**One caveat on the web build.** It is a convenience for looking at screens,
not a supported target: secure storage falls back to browser storage, so "stay
signed in" behaves differently from a real device.

The attendance screen now works here too. Its offline queue is Drift over
SQLite, which on the web runs SQLite compiled to WebAssembly in a worker —
`mobile/web/sqlite3.wasm` and `mobile/web/drift_worker.js`, both committed and
pinned to the locked `drift` / `sqlite3` versions. The queue then lives in the
browser's OPFS or IndexedDB rather than a device file. Refresh the versions
alongside a `flutter pub upgrade` of those two packages — a worker built for a
different drift version will refuse to open the database.

## What works end to end today

Verified against the running stack:

- Password sign-in, token issuance, refresh rotation (a replayed refresh token is
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
- **The presence question goes out by itself** (`ATT-03`): a scheduler on the
  normal queue asks the group's guardians at `PRESENCE_SEND_HOUR` the day
  before each session, sets the deadline `PRESENCE_DEADLINE_HOURS_BEFORE` the
  start, and reminds the unanswered once `PRESENCE_REMINDER_HOURS_BEFORE` the
  deadline. Lower `PRESENCE_SEND_HOUR` and `PRESENCE_TICK_MINUTES` in
  `.env.local` to see it fire on a fresh database within a minute.

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
