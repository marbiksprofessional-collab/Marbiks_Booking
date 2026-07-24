# Marbiks ERP

A self-owned, multi-app ERP platform for Marbiks Professional (beauty, skin, hair, wellness, academy, and cosmetics). Built in-house rather than integrating with a third-party ERP, so the business fully owns its data and infrastructure.

The long-term product vision (all roles, modules, and AI features originally scoped) lives in [`docs/product-vision.md`](docs/product-vision.md). That document is a north star, not a build spec — see [`docs/PHASE_1.md`](docs/PHASE_1.md) through [`docs/PHASE_6.md`](docs/PHASE_6.md) for what's actually implemented so far and the phased plan to get from here to there.

## Repository layout

```
backend/                   NestJS + PostgreSQL core ERP backend (auth, branches, staff,
                            customers, service catalog, appointments/booking, billing,
                            attendance, commissions, products/vendors, inventory,
                            purchase orders, customer OTP auth, reviews, cross-branch
                            reporting)
apps/
  front_office_billing/    Flutter app for receptionists/front-desk billing staff (Phase 1)
  service_provider/        Flutter app for technicians: attendance, queue, commission (Phase 2)
  store/                   Flutter app for store managers: stock, receiving, transfers,
                            purchase orders (Phase 3)
  customer/                Flutter app for customers: OTP login, booking, invoices, reviews,
                            loyalty points (Phase 4)
  super_admin/             Flutter Director/Super Admin control room: real revenue, GST
                            liability, leakage detection (Phase 5)
packages/
  api_client/              Shared Dart HTTP/auth client used by all client apps
infra/aws/                 Terraform for self-hosting the backend on AWS (Phase 6) -
                            written and reference-checked, not yet applied; see
                            infra/aws/README.md
build_apks.sh               Builds a release APK per app; see docs/PHASE_6.md for what
                            was verified where (this repo's dev sandbox can't reach the
                            Android SDK's download host - .github/workflows/build-apks.yml
                            is the environment where this actually produces APKs)
docs/
  product-vision.md        Original full-scope product vision
  PHASE_1.md                Phase 1 scope: core ERP + front-office billing
  PHASE_2.md                Phase 2 scope: attendance, commission, technician app
  PHASE_3.md                Phase 3 scope: inventory core + store app
  PHASE_4.md                Phase 4 scope: customer app, OTP auth, reviews, loyalty
  PHASE_5.md                Phase 5 scope: cross-branch reporting + super admin dashboard
  PHASE_6.md                Phase 6 scope: APK build pipeline + AWS production IaC
  PHASE_7.md                Phase 7 scope: Hostinger VPS production deployment
```

All five apps (Front-Office Billing, Service Provider, Store, Customer, Super Admin) exist on top of the same backend, each with a real `android/` platform folder and a passing `flutter analyze`/`flutter test`. See `docs/PHASE_7.md` for the current (Hostinger) production deployment path and `docs/PHASE_6.md` for the APK release pipeline.

## Backend: local setup

Requirements: Node.js 22+, PostgreSQL 16+.

```bash
cd backend
cp .env.example .env        # edit DB credentials / JWT secret as needed
npm install
npm run migration:run       # creates the schema
npm run seed                # creates a demo branch, users, services, chairs
npm run start:dev
```

The API is served at `http://localhost:3000/api/v1`. Seeded login (change the password immediately in any real deployment):

| Role          | Email                     | Password       |
|---------------|---------------------------|----------------|
| Super Admin   | admin@marbiks.com         | ChangeMe123!   |
| Receptionist  | reception@marbiks.com     | ChangeMe123!   |
| Technician    | technician@marbiks.com    | ChangeMe123!   |
| Store Manager | store@marbiks.com         | ChangeMe123!   |

### Tests

```bash
npm test                    # unit tests (booking conflict detection, invoice math)
npm run test:e2e            # e2e (auth flow) - needs a marbiks_erp_test database
```

### Docker Compose / production deployment

`docker-compose.yml` at the repo root runs Postgres + the backend together and is the
basis for the actual production deployment target: a self-hosted Ubuntu VPS (Hostinger).
See [`docs/HOSTINGER_DEPLOY.md`](docs/HOSTINGER_DEPLOY.md) for the real deploy commands
(`git pull` + `docker compose up --build -d`), backups, and firewall notes.

```bash
cp .env.example .env   # fill in DB_PASSWORD and JWT_SECRET first
docker compose up --build -d
```

Verified: `docker compose config` (real syntax + `.env` variable substitution check —
no daemon needed) passes cleanly. Full `docker compose up` has not been run against a
live Docker daemon in the environment this was built in (none was available there) — the
backend itself was verified directly against a local Postgres install (build, migrations,
seed, and full login → book → invoice / OTP / inventory / reporting flows all passing —
see `docs/PHASE_1.md` through `docs/PHASE_5.md`). Please confirm `docker compose up` on
your actual VPS before relying on it in production.

AWS/Terraform (`infra/aws/`) from an earlier phase is kept for reference but is no longer
the active deployment path — see the note at the top of `infra/aws/README.md`.

## Status

See [`docs/PHASE_1.md`](docs/PHASE_1.md) through [`docs/PHASE_7.md`](docs/PHASE_7.md) for current scope and what's next.
