# The dev server (OVH VM)

A shared copy of the backend at **<https://152-228-213-182.sslip.io/api/v1>**,
so the app can be tried on a real phone without the laptop running.

It is still a **development** environment. There is no SMS provider yet, and
the API refuses to start outside `NODE_ENV=development` without one
(`backend/src/common/config/env.ts`), so OTP codes are read from the API log and
the data is the seed. No real child's data goes on it.

What differs from the laptop stack is exposure:

| | |
|---|---|
| TLS | Caddy in front of the API, Let's Encrypt certificate for the `sslip.io` name (it resolves to the VM's IP, so no domain is needed). Android release builds refuse plain HTTP. |
| Secrets | JWT secrets and every database password are generated on the VM into `infrastructure/.env.server` (mode 600) and never leave it. |
| Database roles | The migrations create `raeed_app` / `raeed_retention` with the `local_dev_only` password; the bootstrap below rotates both. |
| Network | `ufw` allows 22, 80 and 443 only. Postgres and Redis publish no port at all — Docker's published ports bypass `ufw`, so not publishing is the actual control. The API is published on the VM's loopback only. |

## Pointing the app at it

```bash
cd mobile
flutter run --dart-define=RAEED_API_BASE_URL=https://152-228-213-182.sslip.io/api/v1
```

## Signing in

Same seeded numbers as [RUNNING.md](./RUNNING.md). Request a code from the app,
then read it from the log:

```bash
ssh ubuntu@152.228.213.182 \
  'cd ~/raeed/infrastructure && docker compose --env-file .env.server \
   -f docker-compose.server.yml logs api | grep OTP | tail -1'
```

## Deploying a change

From the laptop, on the commit you want running:

```bash
infrastructure/deploy-server.sh
```

It rsyncs `backend/` and `infrastructure/`, rebuilds the image, applies pending
migrations and restarts. It never seeds and never touches `.env.server`.

On the VM, the compose command is always:

```bash
cd ~/raeed/infrastructure
docker compose --env-file .env.server -f docker-compose.server.yml <ps|logs api|restart api|...>
```

Re-seeding (truncates everything):

```bash
docker compose --env-file .env.server -f docker-compose.server.yml \
  run --rm --no-deps api node dist/database/seed.js
```

## First-time bootstrap (already done — for a rebuilt VM)

1. Ubuntu 24.04: add 2 GB swap (the VM has 2 GB RAM and builds the image
   itself), install Docker (`curl -fsSL https://get.docker.com | sudo sh`), then
   `sudo ufw allow OpenSSH && sudo ufw allow 80/tcp && sudo ufw allow 443/tcp && sudo ufw allow 443/udp && sudo ufw --force enable`.
2. Generate `~/raeed/infrastructure/.env.server` on the VM with `umask 077`.
   Same keys as `.env.example`, plus `RAEED_API_HOST`, `POSTGRES_PASSWORD`,
   `APP_DB_PASSWORD`, `RETENTION_DB_PASSWORD`; every secret from
   `openssl rand -hex 32`; `DATABASE_URL` / `MIGRATION_DATABASE_URL` pointing at
   host `postgres` with those passwords.
3. `infrastructure/deploy-server.sh` from the laptop (the API will fail its
   health check until step 4 — the role still has the dev password).
4. Rotate the role passwords, then seed:
   ```bash
   set -a; . ./.env.server; set +a
   C="docker compose --env-file .env.server -f docker-compose.server.yml"
   $C exec -T postgres psql -U raeed -d raeed \
     -c "alter role raeed_app password '$APP_DB_PASSWORD'" \
     -c "alter role raeed_retention password '$RETENTION_DB_PASSWORD'"
   $C run --rm --no-deps api node dist/database/seed.js
   $C restart api
   ```

## Before this carries real data

This setup is not production (`specs/12-devops-and-environments.md`). At least:
an SMS provider and `NODE_ENV=production` (which also closes CORS and the
seed), FCM, off-VM Postgres backups, and a real domain.
