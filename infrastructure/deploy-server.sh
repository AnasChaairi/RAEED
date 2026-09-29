#!/usr/bin/env bash
# Deploys the API to the dev server from git. Run from the laptop; see DEPLOYING.md.
#
#     infrastructure/deploy-server.sh                 # main
#     RAEED_REF=sha-or-branch infrastructure/deploy-server.sh
#     infrastructure/deploy-server.sh --build         # always build on the VM
#     infrastructure/deploy-server.sh --pull          # always take the CI image
#
# The VM keeps a clone of the repository (its own SSH key is a deploy key on
# GitHub), checks out the ref, then runs the image CI published for that exact
# commit when the registry lets it pull — else builds the same commit itself.
# Pending migrations are applied from the image's dist/ and the API restarts.
# It never touches ~/raeed/infrastructure/.env.server on the VM (the secrets
# live only there) and never seeds — re-seeding truncates, so that stays a
# deliberate step.
set -euo pipefail

HOST="${RAEED_SERVER:-ubuntu@152.228.213.182}"
REPO="${RAEED_REPO:-git@github.com:AnasChaairi/RAEED.git}"
REF="${RAEED_REF:-main}"
MODE="${1:-auto}"

ssh "$HOST" "REPO='$REPO' REF='$REF' MODE='$MODE' bash -s" <<'REMOTE'
set -euo pipefail
SRC=~/raeed/src
if [ ! -d "$SRC/.git" ]; then
  git clone --quiet "$REPO" "$SRC"
fi
git -C "$SRC" fetch --quiet --all --tags --prune
git -C "$SRC" checkout --quiet --detach "origin/$REF" 2>/dev/null \
  || git -C "$SRC" checkout --quiet --detach "$REF"
COMMIT=$(git -C "$SRC" rev-parse --short=7 HEAD)
echo "deploying $REF at $COMMIT"

# The secrets stay where they always were; the compose file finds them here.
ln -sf ~/raeed/infrastructure/.env.server "$SRC/infrastructure/.env.server"
cd "$SRC/infrastructure"
export RAEED_API_TAG="sha-$COMMIT"
C="docker compose --env-file .env.server -f docker-compose.server.yml"

if [ "$MODE" != "--build" ] && $C pull --quiet api 2>/dev/null; then
  echo "using the CI image $RAEED_API_TAG"
elif [ "$MODE" = "--pull" ]; then
  echo "the registry refused $RAEED_API_TAG and --pull was asked for" >&2; exit 1
else
  echo "building $COMMIT on the VM"
  $C build --quiet api
fi

$C up -d --wait postgres redis
$C run --rm --no-deps api \
  node node_modules/typeorm/cli.js migration:run -d dist/database/data-source.js
$C up -d
until curl -sf localhost:3000/api/v1/health; do sleep 2; done; echo
$C ps --format 'table {{.Service}}\t{{.Status}}\t{{.Image}}'
REMOTE
