# Super Admin / Director Control Room (Flutter)

An ultra-premium dark dashboard for Directors, General Managers, and Super Admins:
real revenue across branches, real GST tax liability (with an honest CGST/SGST split),
and a real leakage-detection panel. Login is restricted client-side (and enforced
server-side via RBAC) to those three roles.

## What's real vs. explicitly not

Every number on this screen comes from `GET /reports/revenue` and `GET /reports/leakage`
on the backend, which query actual Postgres data — no simulated feeds, no fabricated
branch counts, no invented fraud alerts.

- **Revenue ticker**: real per-branch and total billed/collected/outstanding amounts.
  Refreshes by polling every 30s (see `config.dart`) — the UI says "polling", not "live",
  because it is polling, not a push/WebSocket feed.
- **GST liability**: real total tax from invoices, split into CGST/SGST by halving
  (an honest intra-state assumption — the backend doesn't yet distinguish inter-state
  sales, and the panel says so).
- **Revenue leakage signals**: real anomaly detection — completed appointments with no
  linked invoice, and invoices unpaid past a configurable threshold. Explicitly labelled
  "REAL DATA · NOT AI" — there is no IoT sensor feed or fraud-detection model behind it,
  just two honest SQL queries.
- **Franchise royalty settlement**: **deliberately empty.** There is no Franchise entity
  or royalty calculation in the backend yet. Rather than invent numbers for a Director
  to act on, this panel says so plainly and will start reporting once that module exists.

## Setup

Same as the other four apps in this repo — Dart source only, no generated native platform
folders:

```bash
cd apps/super_admin
flutter create .        # generates android/, ios/, web/, etc. around the existing lib/
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>:3000/api/v1
```

Log in with the seeded super admin account (`admin@marbiks.com` / `ChangeMe123!`, see the
root README) to try it against the local backend.

## Structure

- `lib/super_admin_dashboard.dart` — the dashboard itself: responsive grid (1/2/3 columns
  depending on width), auto-refresh, date-range picker for revenue, unpaid-day threshold
  selector for leakage.
- `lib/theme/app_theme.dart` — the dark, gold-accented Apple-style theme.
- `lib/widgets/` — shared card shell and KPI tile widgets used by the dashboard.
- `lib/session/auth_session.dart` — staff login, client-side gated to Director/General
  Manager/Super Admin roles (the backend enforces this independently via `@Roles()`).
- Shares `packages/api_client` with the other four apps.

## Not yet implemented

Franchise royalty (see above — needs a real backend module first), any other reports from
the original product vision (customer/employee/marketing analytics, branch comparison,
daily/weekly/monthly/yearly rollups), and export/print of these reports. See
`docs/PHASE_5.md` at the repo root.
