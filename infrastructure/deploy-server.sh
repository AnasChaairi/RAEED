#!/usr/bin/env bash
# Deploys the API to the dev server. Run from the laptop; see DEPLOYING.md.
#
#     infrastructure/deploy-server.sh            # pull the image CI built for main
#     RAEED_API_TAG=sha-1a2b3c4 infrastructure/deploy-server.sh   # a specific commit
#     infrastructure/deploy-server.sh --build    # no registry: rsync backend/, build on the VM
#
# Either way it syncs infrastructure/, applies pending migrations from the
# image's dist/ and restarts. It never touches infrastructure/.env.server on
# the VM (the secrets live only there) and never seeds — re-seeding truncates,
# so that stays a deliberate step.
set -euo pipefail

HOST="${RAEED_SERVER:-ubuntu@152.228.213.182}"
MODE="${1:-pull}"
TAG="${RAEED_API_TAG:-latest}"
cd "$(dirname "$0")/.."

ssh "$HOST" 'mkdir -p ~/raeed'
if [ "$MODE" = "--build" ]; then
  rsync -az --delete \
    --exclude node_modules --exclude dist --exclude storage --exclude coverage \
    --exclude '*.tsbuildinfo' --exclude '.env*' \
    backend/ "$HOST:raeed/backend/"
fi
# No --delete here: the exclude alone keeps .env.server from being overwritten,
# and --delete would still be one typo away from removing it.
rsync -az --exclude '.env*' infrastructure/ "$HOST:raeed/infrastructure/"

ssh "$HOST" "set -euo pipefail
cd ~/raeed/infrastructure
export RAEED_API_TAG='$TAG'
C=\"docker compose --env-file .env.server -f docker-compose.server.yml\"
if [ '$MODE' = '--build' ]; then \$C build api; else \$C pull api; fi
\$C up -d --wait postgres redis
\$C run --rm --no-deps api \
  node node_modules/typeorm/cli.js migration:run -d dist/database/data-source.js
\$C up -d
until curl -sf localhost:3000/api/v1/health; do sleep 2; done; echo
\$C ps --format 'table {{.Service}}\t{{.Status}}\t{{.Image}}'"
