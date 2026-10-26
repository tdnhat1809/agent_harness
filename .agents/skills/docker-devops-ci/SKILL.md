---
name: docker-devops-ci
description: Production Docker, Docker Compose, container security, multi-stage builds, and GitHub Actions CI/CD automation.
triggers:
  - Dockerfile and Docker Compose
  - CI/CD pipelines (GitHub Actions)
  - Containerization and deployment
---

# Docker, DevOps & CI/CD Guidelines

## 1. Production Dockerfile Best Practices (Multi-Stage)
Always use multi-stage builds to separate compilation tools from the lightweight runtime container:
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
# Run as non-root user
USER node
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

## 2. Container Security Guardrails
- **Non-root Execution**: Never run application processes as `root`. Always specify an unprivileged user (e.g. `USER appuser` or `USER node`).
- **Minimal Base Images**: Use Alpine, Debian Slim, or Google Distroless base images to minimize CVE attack surface.
- **Secret Protection**: Never bake API keys, secrets, or `.env` files into Docker images. Inject them at runtime via environment variables or secret managers.
- **Layer Caching**: Order instructions from least frequently changed to most frequently changed (e.g., dependency files before source code).

## 3. Docker Compose for Local Development
- Define healthchecks on databases and message brokers:
```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: app_db
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: secret_password
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app_user -d app_db"]
      interval: 5s
      timeout: 5s
      retries: 5
```
- Use `depends_on` with `condition: service_healthy` so backend services do not start before dependencies are ready.

## 4. GitHub Actions CI/CD Matrix
- Run automated checks on every pull request:
  - Linting & formatting check
  - Type checking (e.g., `tsc --noEmit`, `mypy`, `cargo check`)
  - Test suites with coverage threshold
  - Container build test
- Cache package managers (`actions/cache` or setup action cache) to keep CI runtime under 3 minutes.
