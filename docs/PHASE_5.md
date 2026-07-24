# Phase 5 — Cross-Cutting Reporting & Super Admin Dashboard

## Why this scope, and what got cut

The request that kicked off this phase asked for a Director control room with four
panels: a revenue ticker across 500+ branches, GST liability, a franchise royalty matrix,
and an "AI Fraud Monitoring Stream" reading IoT chair sensors. Before writing any code, two
of those four were flagged back to the user as unbuildable-as-real:

- **IoT/AI fraud monitoring** — there is no sensor hardware, no fraud-detection model, and
  by definition an "unrecorded walk-in" is invisible to a system with no sensor feed.
  Faking a live stream of alerts would have been exactly the kind of hallucinated theater
  that was stripped out of this repository's original scaffold at the start of the project
  (the old `fraud-control.service.ts` / `anti-proxy.service.ts` files). The user agreed:
  build a **real** leakage-detection signal from actual data instead, and explicitly labelled
  as such.
- **Franchise royalty (5% flat fee)** — there is no Franchise entity, franchise-owner model,
  or royalty calculation anywhere in the backend. The user agreed to defer this panel
  entirely rather than ship a card full of invented numbers.
- **"500+ branches"** — a scale descriptor, not a requirement to fabricate branch rows.
  The dashboard aggregates whatever branches actually exist (2, in this dev environment)
  and scales to however many are real.

## What's implemented

**Backend** (`backend/src/reports/`):
- `GET /reports/revenue?from=&to=` — real per-branch and grand-total revenue
  (billed/collected/outstanding) and tax totals, aggregated directly from the `invoices`
  table (default range: start of current month → now).
- `GET /reports/leakage?unpaidDays=` — two real anomaly signals: `COMPLETED` appointments
  with no linked invoice (a straight `LEFT JOIN ... WHERE invoice IS NULL`), and invoices
  still `UNPAID`/`PARTIAL` past a configurable day threshold (default 3).
- Both restricted via `@Roles()` to `SUPER_ADMIN`, `DIRECTOR`, `GENERAL_MANAGER`.
- Unit tests for the aggregation math (grand totals, the CGST/SGST 50/50 split, overdue
  total summation) and the default-threshold behavior — all passing.
- Verified end-to-end manually against real Postgres: confirmed real multi-branch revenue
  and tax totals from actual invoices created across earlier phases' testing; deliberately
  created a completed-but-uninvoiced appointment and a backdated unpaid invoice, and
  confirmed both showed up correctly in the leakage report with the right `daysOverdue`;
  confirmed a narrow date range correctly zeroed out; confirmed a non-authorized role
  (receptionist) got `403` and an unauthenticated request got `401`.

**Super Admin app** (`apps/super_admin/`, Flutter, ultra-premium dark/gold theme):
`lib/super_admin_dashboard.dart` — a responsive (1/2/3-column depending on width)
control room with:
1. **Revenue Ticker** — total billed/collected/outstanding, per-branch breakdown with a
   real share-of-total bar, a date-range picker, and honest "polling every 30s" labeling
   (not "live"/push).
2. **GST Tax Liability** — real total tax plus the CGST/SGST split, with an explicit
   caption noting the intra-state assumption and that inter-state (IGST) isn't
   distinguished yet.
3. **Revenue Leakage Signals** — unbilled-completed and overdue-invoice counts and lists,
   with a threshold selector (3/7/14/30 days), labelled "REAL DATA · NOT AI".
4. **Franchise Royalty Settlement** — intentionally empty, with a plain-language
   explanation of what's missing rather than fabricated figures.

Login is a new dedicated app (none of the other four target Director/Super Admin),
client-side role-gated to the three allowed roles in addition to the backend's own RBAC.

## Explicitly not in Phase 5

Franchise royalty (see above), and every other report/analytics view from the original
product vision: customer/employee/marketing analytics, branch-to-branch comparison,
daily/weekly/monthly/yearly rollups, and export/print of any of these reports.

## Known limitations to address before production

- `getRevenueSummary` and `getLeakageReport` run ad-hoc aggregate queries per request;
  fine at current scale, worth a materialized view or scheduled rollup once invoice volume
  is large.
- The CGST/SGST split is display-only math (`totalTax / 2`), not a separately tracked
  ledger — don't wire this into actual GST filing without adding real intra-state/
  inter-state tracking to invoices first.
- No caching between the 30s polls beyond what the two endpoints already compute fresh
  each time — acceptable at current data volume, not at real multi-hundred-branch scale.

## Suggested next phase

Build the real Franchise entity + royalty calculation this phase deferred, or continue
into HR/Finance (payroll, leave, GST filing reports) — both untouched so far.
