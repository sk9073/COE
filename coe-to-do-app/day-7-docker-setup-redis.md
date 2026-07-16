# Day 7 — Docker Setup for Rails + PostgreSQL

## Overview

This document covers the complete Docker setup for the `coe-to-do-app` Rails application,
including all file changes made, the reasoning behind each change, and useful Docker Compose
commands for day-to-day development.

---

## Files Changed for Docker Setup

### 1. `Dockerfile`

The Dockerfile defines how the Rails application image is built.

**Key decisions:**

| Instruction | Purpose |
|---|---|
| `FROM ruby:3.2.10` | Uses the official Ruby image matching the app's Ruby version |
| `apt-get install libpq-dev` | Installs the PostgreSQL C library needed to compile the `pg` gem |
| `apt-get install postgresql-client` | Allows running `psql` commands inside the container for debugging |
| `COPY Gemfile Gemfile.lock ./` before `COPY . .` | Docker layer caching — gems are only reinstalled when the Gemfile changes, not on every code change |
| `RUN bundle install` | Installs all gems inside the image |
| `COPY entrypoint.sh /usr/bin/` | Makes the entrypoint script available system-wide |
| `RUN chmod +x` | Ensures the script is executable inside the Linux container |
| `ENTRYPOINT ["entrypoint.sh"]` | Runs `entrypoint.sh` before every container start |
| `EXPOSE 3000` | Documents that the app listens on port 3000 |
| `CMD ["rails", "server", "-b", "0.0.0.0"]` | Starts the Rails server, binding to all interfaces so it's accessible from outside the container |

---

### 2. `entrypoint.sh`

**Key decisions:**

| Line | Purpose |
|---|---|
| `set -e` | Exits immediately if any command fails — prevents silent errors |
| `rm -f /app/tmp/pids/server.pid` | Rails writes a PID file when the server starts. If the container crashes or is force-stopped, this file is left behind. On restart, Rails refuses to start because it thinks another server is already running. This line clears that stale PID file every time the container starts |
| `exec "$@"` | Replaces the shell process with the CMD (e.g., `rails server`). Using `exec` ensures signals like `SIGTERM` are passed directly to Rails, allowing graceful shutdown |

---

### 3. `docker-compose.yml`

**Key decisions:**

| Setting | Purpose |
|---|---|
| `image: postgres:16-alpine` | Uses the lightweight Alpine-based PostgreSQL 16 image to keep image size small |
| `volumes: postgres_data:/var/lib/postgresql/data` | Persists database data across container restarts. Without this, all data is lost every time the `db` container stops |
| `healthcheck: pg_isready -U postgres` | Polls the PostgreSQL server until it's ready to accept connections |
| `interval: 5s / timeout: 5s / retries: 5` | Checks every 5s, waits up to 5s per check, retries up to 5 times before marking unhealthy |
| `depends_on: condition: service_healthy` | Ensures the `web` container does NOT start until the `db` container passes its healthcheck. Prevents Rails from crashing on startup because Postgres isn't ready yet |
| `volumes: .:/app` (web) | Mounts the local codebase into the container — code changes reflect immediately without rebuilding the image |
| `DATABASE_HOST: db` | The hostname `db` resolves to the `db` service container on Docker's internal network |
| `DATABASE_NAME: coe_to_do_app_development` | Passed to `database.yml` via `ENV.fetch("DATABASE_NAME")` to set the correct PostgreSQL database name |
| `RAILS_ENV: development` | Tells Rails which environment config to use |

**Changes made from the original:**
- Removed deprecated `version: '3.8'` top-level key (no longer needed in modern Docker Compose)
- Added `healthcheck` block to the `db` service
- Upgraded `depends_on` from a simple list (`- db`) to the long-form with `condition: service_healthy`
- Added `DATABASE_NAME` environment variable to the `web` service

---

### 4. `config/database.yml`

**Key decisions:**

| Setting | Purpose |
|---|---|
| `<<: *default` | YAML merge key — inherits all settings from the `default` block. The `development` block then overrides specific keys like `adapter` |
| `adapter: postgresql` | Overrides the default SQLite adapter to use PostgreSQL for the development environment |
| `database: ENV.fetch("DATABASE_NAME")` | Reads the database name from the `DATABASE_NAME` env var set in `docker-compose.yml`. Falls back to `"coe_to_do_app_development"` for local development without Docker |
| `host: ENV.fetch("DATABASE_HOST")` | Inside Docker, this resolves to `db` (the service name). Outside Docker, it falls back to `localhost` |
| `username / password` | Read from environment variables so credentials are never hardcoded |

**Changes made from the original:**
- Added `adapter: postgresql` to the `development` block (was inheriting `sqlite3` from default)
- Added `database:` key with `ENV.fetch("DATABASE_NAME")` (was missing entirely — Rails would fail to connect)
- Added `host:`, `username:`, `password:`, and `pool:` keys driven by environment variables for Docker compatibility

## Docker Compose Commands Reference

### Starting & Stopping

```bash
# Build images and start all containers in detached mode
docker-compose up --build -d

# Start containers (without rebuilding)
docker-compose up -d

# Stop all running containers (keeps volumes)
docker-compose down

# Stop containers AND delete all volumes (wipes the database)
docker-compose down -v

# Restart a specific service
docker-compose restart web
```

### Building

```bash
# Rebuild all images from scratch (no cache)
docker-compose build --no-cache

# Rebuild only the web service
docker-compose build web

# Pull latest base images before building
docker-compose build --pull
```

### Logs

```bash
# Follow logs for the web service
docker-compose logs -f web

# Follow logs for the db service
docker-compose logs -f db

# Follow logs for all services
docker-compose logs -f

# Show last 100 lines of web logs
docker-compose logs --tail=100 web
```

### Running Commands Inside Containers

```bash
# Open a Rails console
docker-compose exec web rails console

# Run database migrations
docker-compose exec web rails db:migrate

# Create the database
docker-compose exec web rails db:create

# Drop and recreate the database
docker-compose exec web rails db:drop db:create db:migrate

# Seed the database
docker-compose exec web rails db:seed

# Run RSpec tests
docker-compose exec web bundle exec rspec

# Run a specific spec file
docker-compose exec web bundle exec rspec spec/models/list_spec.rb

# Open a bash shell inside the web container
docker-compose exec web bash

# Open a psql shell inside the db container
docker-compose exec db psql -U postgres -d coe_to_do_app_development
```

### Container Status & Inspection

```bash
# List all running containers and their status
docker-compose ps

# Show resource usage (CPU, memory) for running containers
docker stats

# Inspect the web container details
docker inspect coe-to-do-app-web-1

# Show all Docker images
docker images

# Show Docker networks
docker network ls
```

### Cleanup

```bash
# Remove stopped containers
docker-compose rm

# Remove all unused images, containers, networks, and build cache
docker system prune

# Remove all unused volumes too (careful — deletes data!)
docker system prune --volumes

# Remove only dangling/unused images
docker image prune
```

---

## Setup Summary — Steps Taken

1. Created `Dockerfile` to define the Rails application image (Ruby 3.2.10 + PostgreSQL dependencies)
2. Created `entrypoint.sh` to handle stale PID file cleanup on container startup
3. Configured `docker-compose.yml` with:
   - `db` service (PostgreSQL 16 Alpine) with persistent volume and healthcheck
   - `web` service (Rails app) with dependency on healthy `db`
4. Updated `Gemfile` — added `gem "pg", ">= 1.1"` for PostgreSQL support
5. Updated `config/database.yml` — configured the `development` environment to use PostgreSQL via environment variables
6. Ran `bundle install` locally to update `Gemfile.lock`
7. Ran `docker-compose up --build -d` to build the image and start containers
8. Ran `docker-compose exec web rails db:create db:migrate` to set up the database