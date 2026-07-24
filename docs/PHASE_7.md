# Phase 7 — Hostinger VPS Production Deployment (replaces AWS as the active target)

## What changed

Phase 6 built out AWS ECS/Fargate + RDS Terraform as the production hosting plan. That
plan is now superseded: the business has a real Hostinger Ubuntu VPS with Docker
available, and wants to deploy there directly via Docker Compose instead of standing up
AWS infrastructure. This phase adapts the release path accordingly rather than building
both in parallel.

**Branch note, same as every phase before this one:** this session's designated branch
is `claude/new-session-8h5wzt`, not `main`. This work is committed and pushed there. If
you want it merged to `main`, the normal path is a PR from this branch — ask and I'll open
one; I'm not pushing directly to `main` on a bare request to do so, same reasoning as
Phase 6.

## What's implemented

- **`docker-compose.yml`** (repo root) rewritten for production use:
  - Reads `DB_USERNAME`/`DB_PASSWORD`/`DB_DATABASE`/`JWT_SECRET`/`JWT_EXPIRES_IN`/`PORT`
    from a `.env` file next to it (Compose loads this automatically) instead of the
    previous hardcoded demo values (`marbiks`/`marbiks`/a placeholder JWT string) —
    "aligned with our locked `.env` setup" means the same variable names as
    `backend/.env.example`, just supplied externally now.
  - Postgres's port is **not** published to the host — reachable only from the backend
    container over an internal Docker network (`marbiks_internal`). Direct access is via
    `docker compose exec postgres psql` or an SSH tunnel, documented in
    `docs/HOSTINGER_DEPLOY.md`.
  - Added a real healthcheck for the backend container (hits `/api/v1/health` with
    `wget`, already present in the `node:22-alpine` base image via busybox).
- **`.env.example`** (repo root, new) — the template `docs/HOSTINGER_DEPLOY.md` tells you
  to copy to `.env` and fill in.
- **`backend/src/database/seeds/run-seed.ts`** — the super admin email/password are now
  overridable via `SEED_SUPER_ADMIN_EMAIL`/`SEED_SUPER_ADMIN_PASSWORD` env vars, falling
  back to the existing demo values only if unset. This was a real gap worth closing here:
  the seed script's demo super admin password is published in this repo's own README, so
  running it unmodified against a real production database would leave a known
  credential live on a real system. The rest of the seeded data (demo branch, demo
  receptionist/technician/store-manager accounts, demo services/products) is still fixed
  demo content — flagged clearly in the deploy doc as something to review/remove for real
  production use, not silently made "production safe" by this change.
- **`docs/HOSTINGER_DEPLOY.md`** — real commands: initial server setup (Docker install if
  needed), first-time `.env` setup, `docker compose up --build -d`, health verification,
  the safe way to bootstrap a real super admin, subsequent deploys via `git pull` +
  rebuild, day-to-day operations (logs, restart, status), manual backup/restore commands
  (no managed-RDS-style automatic backups anymore — that's now the operator's
  responsibility, called out explicitly), direct DB access via SSH tunnel instead of a
  published port, firewall notes, and what's deliberately not included (HTTPS/reverse
  proxy, automated backups, zero-downtime deploys).
- **AWS artifacts reconciled, not deleted**: `.github/workflows/deploy-backend.yml` (the
  AWS ECS deploy workflow) was removed since an active CI trigger targeting an abandoned
  hosting plan is actively misleading, not just unused. `infra/aws/` itself was kept —
  real, reviewed Terraform work, not deleted on a one-line "we don't need this anymore" —
  but `infra/aws/README.md` now opens with an explicit "superseded" notice pointing at
  `docs/HOSTINGER_DEPLOY.md` as the active path.

## Verified for real

- `docker compose config` (validates syntax and resolves all `.env` variable
  substitution against a real `.env` built from the new `.env.example`) passes cleanly —
  confirmed `DB_PASSWORD`/`JWT_SECRET` interpolate correctly, `PORT`/`JWT_EXPIRES_IN`
  defaults apply when unset, and the new `SEED_SUPER_ADMIN_*` vars default to empty
  strings as intended. This does not require a running Docker daemon.
- The backend still builds and all 36 backend unit/e2e tests still pass after the seed
  script change (unaffected logic, but re-verified rather than assumed).
- Full `docker compose up --build -d` was **not** run end-to-end here — no Docker daemon
  is reachable in this sandbox (confirmed: `docker info`/`docker ps` fail with "cannot
  connect to the Docker daemon" — the same constraint noted back in Phase 1). The backend
  itself has been verified directly against a real Postgres instance repeatedly across
  Phases 1-5 (migrations, seed, and every feature's end-to-end curl-tested flow), so the
  application logic inside the container is well-exercised even though the container
  orchestration itself hasn't been run in this environment. Confirm `docker compose up
  --build -d` on the actual Hostinger VPS as the first real end-to-end check.

## Known limitations to address before relying on this in production

- No automated backups (documented manual `pg_dump` command only — set up your own cron).
- No HTTPS/reverse proxy in this compose file (recommended: Caddy or Nginx in front,
  noted in the deploy doc).
- Migrations still run from the backend container's own entrypoint on every start
  (same note as Phase 6) — harmless with a single backend replica (the Hostinger setup
  has exactly one), would need revisiting if this ever scales to multiple backend
  containers behind a load balancer.
- Seed script's non-admin demo data (branch, staff accounts, services) is still hardcoded
  demo content, not parameterized for production use — see the warning in
  `docs/HOSTINGER_DEPLOY.md`.
