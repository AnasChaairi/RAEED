# RAEED API image.
#
# `development` is what infrastructure/docker-compose.yml runs: source mounted,
# `nest start --watch`. `runtime` is the compiled API with production
# dependencies only, used by infrastructure/docker-compose.server.yml. It also
# carries the migration CLI and the seed — both run from `dist/`, so no
# ts-node is needed on a server.
FROM docker.io/library/node:22-bookworm-slim AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM deps AS development
COPY tsconfig.json nest-cli.json ./
CMD ["npm", "run", "start:dev"]

FROM deps AS build
COPY tsconfig.json nest-cli.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

FROM docker.io/library/node:22-bookworm-slim AS runtime
WORKDIR /app
COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
# The local-disk StorageProvider's root. Created here so a fresh named volume
# mounted over it inherits the `node` owner.
RUN mkdir -p /var/lib/raeed/media && chown node:node /var/lib/raeed/media
USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
