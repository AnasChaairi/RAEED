#!/usr/bin/env bash
# Pushes this checkout's backend to the dev server, rebuilds the API image,
# applies pending migrations and restarts. Run from the laptop; see DEPLOYING.md.
#
#     infrastructure/deploy-server.sh
#
# It never touches infrastructure/.env.server on the VM (the secrets live only
# there) and never seeds — re-seeding truncates, so that stays a deliberate step.
set -euo pipefail

HOST="${RAEED_SERVER:-ubuntu@152.228.213.182}"
cd "$(dirname "$0")/.."

ssh "$HOST" 'mkdir -p ~/raeed'
rsync -az --delete \
  --exclude node_modules --exclude dist --exclude storage --exclude coverage \
  --exclude '*.tsbuildinfo' --exclude '.env*' \
  backend/ "$HOST:raeed/backend/"
# No --delete here: the exclude alone keeps .env.server from being overwritten,
# and --delete would still be one typo away from removing it.
rsync -az --exclude '.env*' infrastructure/ "$HOST:raeed/infrastructure/"

ssh "$HOST" 'set -euo pipefail
cd ~/raeed/infrastructure
C="docker compose --env-file .env.server -f docker-compose.server.yml"
$C build api
$C up -d --wait postgres redis
$C run --rm --no-deps api \
  node node_modules/typeorm/cli.js migration:run -d dist/database/data-source.js
$C up -d
until curl -sf localhost:3000/api/v1/health; do sleep 2; done; echo
$C ps --format "table {{.Service}}\t{{.Status}}"'
