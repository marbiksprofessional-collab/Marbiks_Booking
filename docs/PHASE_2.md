# Phase 2 — Attendance, Commission, Service Provider (Technician) App

## What's implemented

**Backend additions** (`backend/src/attendance/`, `backend/src/commissions/`, plus new
endpoints on the existing appointments module):
- Attendance: clock in / clock out, scoped to the authenticated user, rejecting a duplicate
  clock-in while already clocked in (409) and a clock-out with no open record (400)
- `ServiceItem.commissionPercent` field, and a commission summary endpoint
  (`GET /commissions/me?from=&to=`) that sums, for the authenticated technician's completed
  and invoiced appointments in a date range, `invoice.total * service.commissionPercent / 100`
- `GET /appointments/my?date=` — a technician's own queue for a given day
- `GET /appointments/customer/:customerId` — a customer's full appointment/treatment history
- Migration for the new table/column, unit tests for attendance and commission logic (all
  passing), and a full manual end-to-end pass: clock in → duplicate clock-in rejected → book
  an appointment assigned to the technician → see it in `/appointments/my` → mark complete →
  generate invoice → commission summary correctly returns 10% of the invoice total → clock out
  → duplicate clock-out rejected.

**Service Provider (Technician) app** (`apps/service_provider/`, Flutter): login, clock
in/out with live status, today's assigned queue, appointment detail with the customer's past
visit history and a "mark complete" action, and a commission summary screen with a date-range
picker. Built on the same shared `packages/api_client` as the Front Office Billing app (which
gained `getMyAppointments`, `getCustomerHistory`, `clockIn`/`clockOut`/`getAttendanceStatus`,
`getCommissionSummary`, and `completeAppointment`).

## Explicitly not in Phase 2

Daily targets, before/after photo capture and storage, product recommendations, training
videos, task checklists, leave requests, and salary slips (all listed under "Technician App"
in the original product vision) — these need their own backend modules (file storage for
photos, a targets/goals model, a training-content model) and are deferred to a later phase.

## Known limitations to address before production

- Commission calculation runs one query per completed appointment in the date range
  (`N+1`-style) rather than a single aggregate join — fine at demo scale, worth revisiting
  before a branch has hundreds of completed appointments per query.
- No geofencing/anti-proxy check on clock-in — it's a plain timestamp record, not tied to
  location or device, consistent with this phase's read of the requirements as literally
  "log a company's attendance," not fraud-prevention.
- Same money-rounding and invoice-numbering caveats as Phase 1 apply here too.

## Suggested next phase

**Inventory core** — products, stock levels, branch transfer, low-stock alerts — needed before
a Store app is useful; then the Customer app (registration/OTP login, booking, digital
invoice, loyalty points). Inventory core and the Store app are done in
[`docs/PHASE_3.md`](PHASE_3.md).
