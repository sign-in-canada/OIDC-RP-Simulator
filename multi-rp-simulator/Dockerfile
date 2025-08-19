# syntax=docker/dockerfile:1

############################
# Build stage
############################
FROM node:20-alpine AS build
WORKDIR /app

# Install deps (useslockfile if present)
COPY package*.json ./
RUN npm ci

# Copy TS config + sources + root config.ts (imported by rp-server)
COPY tsconfig.json ./
COPY src ./src
COPY config.ts ./config.ts

# Optional copy of sample config file
# COPY sample-config.ts ./sample-config.ts

# Compile TS -> JS
RUN npm run build

# Copy EJS views/static under src/ next to compiled JS:
RUN sh -c 'if [ -d src/views ]; then mkdir -p dist/src/views && cp -r src/views/* dist/src/views/; fi'
RUN sh -c 'if [ -d src/public ]; then mkdir -p dist/src/public && cp -r src/public/* dist/src/public/; fi'

############################
# Runtime stage
############################
FROM node:20-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app

# Install deps
COPY package*.json ./
RUN npm ci --omit=dev

# Bring compiled app
COPY --from=build /app/dist ./dist
# Make ../node_modules resolvable from dist/src/**
RUN ln -s /app/node_modules /app/dist/node_modules

USER node

EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/health || exit 1

CMD ["node", "dist/src/rp-server.js"]
