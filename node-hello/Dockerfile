# Build & dependency stage
FROM node:22-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi

# Runtime stage
FROM node:22-alpine
ENV NODE_ENV=production
ENV PORT=3000
WORKDIR /app

# Upgrade system packages to pull latest security patches and create non-root user
RUN apk update && apk upgrade --no-cache && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy dependencies and application source with appropriate ownership
COPY --from=dependencies --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup package*.json ./
COPY --chown=appuser:appgroup src ./src

USER appuser
EXPOSE 3000
CMD ["node", "src/app.js"]
