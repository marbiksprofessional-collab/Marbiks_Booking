# Deploying to a Hostinger VPS (Docker)

Real, copy-pasteable commands for running the Marbiks ERP backend + PostgreSQL on a
Hostinger Ubuntu VPS via `docker-compose.yml` at the repo root. This replaces the AWS
ECS/Fargate path from `infra/aws/` (kept for reference, not the active deployment target
— see the note at the top of `infra/aws/README.md`).

## Prerequisites

Hostinger's Docker VPS template ships with Docker and the Compose plugin already
installed. If you provisioned a plain Ubuntu VPS instead, install them first:

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"   # log out and back in for this to take effect
docker compose version            # confirms the Compose plugin is present
```

## First-time setup

```bash
git clone https://github.com/marbiksprofessional-collab/marbiks_booking.git
cd marbiks_booking
git checkout main   # or whichever branch you're deploying

cp .env.example .env
nano .env
```

In `.env`, at minimum set real values for:

- `DB_PASSWORD` — the Postgres password (this also creates the DB user on first run)
- `JWT_SECRET` — generate one with `openssl rand -base64 48`

Then bring the stack up:

```bash
docker compose up --build -d
```

This builds the backend image from `backend/Dockerfile`, starts Postgres first (waiting
for its healthcheck), then starts the backend — which runs pending migrations
automatically on startup (`backend/docker-entrypoint.sh`) before serving traffic.

Watch it come up:

```bash
docker compose logs -f backend
```

Confirm it's healthy:

```bash
docker compose ps                                  # both services should show "healthy"
curl http://localhost:3000/api/v1/health            # {"status":"ok","service":"marbiks-erp-backend"}
```

### Creating your first Super Admin account

**Do not run `npm run seed` against production using its built-in demo credentials** — the
script's fallback super admin password (`ChangeMe123!`) is published in this repo's own
README. Instead, set your own values in `.env` first:

```bash
# in .env
SEED_SUPER_ADMIN_EMAIL=you@yourcompany.com
SEED_SUPER_ADMIN_PASSWORD=a-real-password-you-will-actually-remember
```

Then run the seed once:

```bash
docker compose up -d           # picks up the new .env values
docker compose exec backend npm run seed
```

This also creates one demo branch, a demo receptionist/technician/store-manager account,
a few demo services, and opening stock — all using the seed script's hardcoded demo
values (only the super admin credentials are overridable right now). Review
`backend/src/database/seeds/run-seed.ts` and remove or change anything you don't want in
a real production database; it was written for local development, not as a production
onboarding tool.

## Subsequent deployments

```bash
cd marbiks_booking
git pull origin main
docker compose up --build -d
```

`--build` rebuilds the backend image only if `backend/` changed since the last build (Docker
layer caching); Postgres and its data volume are untouched by this.

## Day-to-day operations

```bash
docker compose ps                     # status of both containers
docker compose logs -f backend        # tail backend logs
docker compose logs -f postgres       # tail Postgres logs
docker compose restart backend        # restart just the backend (e.g. after an env change)
docker compose down                   # stop both containers - does NOT delete the Postgres volume
```

**Never run `docker compose down -v`** on a production host — the `-v` flag deletes the
named volume, which deletes your Postgres data with it.

### Backups

There is no managed RDS-style automatic backup here anymore — Postgres is a plain
container with a Docker volume. Take your own backups:

```bash
# Dump to a timestamped file
docker compose exec -T postgres pg_dump -U "$(grep DB_USERNAME .env | cut -d= -f2)" \
  "$(grep DB_DATABASE .env | cut -d= -f2)" > "backup-$(date +%Y%m%d-%H%M%S).sql"

# Restore (only ever run this against an empty/new database)
cat backup-20260101-000000.sql | docker compose exec -T postgres psql -U <username> <database>
```

Set up a daily cron job running the dump command and copy the result off the VPS (e.g. to
Hostinger's own backup storage, S3, or anywhere else) — this repo doesn't automate that
part yet.

### Accessing Postgres directly

The compose file deliberately does not publish Postgres's port to the internet. To run
a one-off query:

```bash
docker compose exec postgres psql -U <username> <database>
```

To reach it from a GUI client on your own machine, use an SSH tunnel rather than opening
the port:

```bash
ssh -L 5432:localhost:5432 your-user@your-vps-ip
# then point your local Postgres client at localhost:5432
```

## Pointing the Flutter apps at this backend

Each app's `apiBaseUrl` (see `apps/<app>/lib/config.dart`) is a compile-time constant
defaulting to `http://localhost:3000/api/v1` - useful for a local emulator, useless on a
real phone or tablet (it points the app at itself, not your server). The APKs produced by
`build_apks.sh` or `.github/workflows/build-apks.yml` **without** an override are built
with that default and will never reach a real backend.

Once this backend is reachable at a real address (e.g. `http://your-vps-ip:3000/api/v1`,
or better, behind HTTPS via the Caddy/Nginx setup mentioned below), rebuild pointed at it:

```bash
API_BASE_URL=http://your-vps-ip:3000/api/v1 ./build_apks.sh
```

or, without a local Flutter/Android toolchain, trigger `build-apks.yml` manually from the
GitHub Actions tab (or via the API) with the `api_base_url` input set to the same value -
it threads through to `flutter build apk --release --dart-define=API_BASE_URL=...` for
every app in the matrix. Reinstall the resulting APKs over the old ones on your device;
the old ones can't be redirected at runtime since the URL is baked in at build time.

## Firewall

Only these ports need to be open to the internet:

- `22` (SSH) — restrict to your own IP if possible
- Whatever port your reverse proxy/domain serves on (see below)

Postgres (`5432`) is never exposed by this compose file, so there's nothing to firewall
there specifically — just don't add a `ports:` mapping for it.

## Not included here (recommended next steps)

- **HTTPS/domain**: this compose file serves plain HTTP on port 3000. For a real public
  domain, put Nginx or Caddy in front (Caddy in particular gets you free automatic
  Let's Encrypt HTTPS with a ~5-line Caddyfile) and only expose 80/443 to the internet,
  proxying to `127.0.0.1:3000`.
- **Automated backups** — see above.
- **Zero-downtime deploys** — `docker compose up --build -d` briefly stops the backend
  container while the new one starts. Fine for a single-VPS setup with occasional
  deploys; not a rolling/blue-green deploy.
