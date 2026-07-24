# Phase 1 — Core ERP + Front-Office Billing

## Why this scope

The original product vision (`docs/product-vision.md`) describes a 16-role, dozen-module,
AI-throughout platform spanning 500+ branches — a multi-year build. Rather than generating
placeholder stubs for all of it at once, Phase 1 delivers one real, working vertical slice:
the daily operational core that every other module depends on.

The previous scaffold in this repo (flat `.dart`/`.ts` files at the repo root) did not
compile — `app.module.ts` imported files that didn't exist, there was no `tsconfig.json` or
build config, and commit messages described "completed" work that wasn't functional. It was
removed and rebuilt from scratch on a real, tested foundation.

## What's implemented

**Backend** (`backend/`, NestJS + PostgreSQL + TypeORM):
- JWT authentication + role-based access control, covering all 16 roles from the product vision
- Branches, Staff/Users, Customers, Service catalog, Resources (chairs/rooms/beds/machines)
- Appointments: create / reschedule / cancel / no-show / complete, with **conflict detection**
  that blocks double-booking the same technician or resource in an overlapping time window
- Billing: invoice generation from an appointment or from ad-hoc line items, with discount and
  GST tax calculation, payment status/method tracking
- Database migrations (TypeORM), a seed script (demo branch/users/services/chairs)
- Unit tests (booking conflict logic, invoice math) and an e2e test (auth flow) — all passing
- Verified end-to-end manually: login → create customer → book appointment → conflict correctly
  rejected with 409 → generate invoice with correct tax total

**Front-Office Billing app** (`apps/front_office_billing/`, Flutter): login, today's
appointment list, create/reschedule/cancel booking, checkout → invoice — the receptionist's
daily workflow, talking to the backend above through the shared `packages/api_client`.

## Explicitly not in Phase 1

Everything else from the product vision: Service Provider/Technician, Customer, and Store
apps; HR/payroll, marketing, franchise, and academy modules; every AI feature; GST filing,
bank reconciliation, and other finance depth; offline sync and conflict resolution;
multi-branch reporting. These build on the same backend and auth system once the core is
proven in daily use.

## Suggested next phases

1. **Service Provider (Technician) app** — clock in/out, service queue, commission view.
   Done in [`docs/PHASE_2.md`](PHASE_2.md).
2. **Inventory core** — products, stock levels, branch transfer, low-stock alerts — needed
   before a Store app is useful.
3. **Customer app** — registration/OTP login, booking, digital invoice, loyalty points.
4. Broaden HR (attendance, leave, payroll) and Finance (P&L, GST reports) once the
   operational core is stable in production.

## Known limitations to address before production

- Money fields use JS `number` + `toFixed(2)` rounding rather than a decimal library —
  acceptable for this MVP but should move to a fixed-point/decimal type before scaling.
- Invoice numbers use a date + random suffix; move to a per-branch sequential counter
  before relying on invoice numbers for accounting/GST filing.
- No refresh-token flow yet — JWT access tokens simply expire (default 8h).
- No rate limiting, request logging/monitoring, or audit log yet.
