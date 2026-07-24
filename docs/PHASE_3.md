# Phase 3 — Inventory Core + Store Manager App

## What's implemented

**Backend additions**:
- `products` and `vendors`: simple CRUD, `Product` carries `sku` (unique), `unit`, and
  `reorderLevel` for low-stock detection.
- `inventory` module — the core of this phase:
  - **Stock batches**: every stock receipt creates a `StockBatch` (per branch + product, with
    an optional batch number, expiry date, unit cost, and vendor). Current stock on hand is
    the sum of `quantityRemaining` across a product's batches at a branch — there's no single
    "quantity" field to get out of sync; it's always derived from the batch ledger.
  - **FIFO consumption**: consuming, transferring out, or negatively adjusting stock draws
    from the oldest-expiring batch first (`NULLS LAST` so undated batches are drawn last),
    splitting across multiple batches if needed, inside a DB transaction with row-level
    locking (`pessimistic_write`) so concurrent operations can't over-draft the same batch.
  - **Stock movements**: an immutable audit ledger (`RECEIVE`, `CONSUME`, `TRANSFER_OUT`,
    `TRANSFER_IN`, `ADJUSTMENT`) — every quantity change is traceable to who did it and why.
  - Endpoints: receive, consume, transfer (atomic, cross-branch), adjust (stock audit
    corrections), current stock per branch, low-stock (at/below reorder level), and batches
    expiring within N days.
- `purchase-orders`: create an order (branch + vendor + line items), list, get by id, receive
  (creates a stock batch + movement per line item and marks the order `RECEIVED`, with
  optional per-item batch number/expiry override at receipt time), cancel.
- Migration for all new tables; unit tests for FIFO consumption (single batch, multi-batch
  split, insufficient-stock rejection) and low-stock filtering, all passing.
- Verified end-to-end manually against real Postgres: created a vendor and product, placed a
  30-unit purchase order, received it (created a batch with a near-term expiry date), consumed
  5 units, transferred 15 to a second branch, confirmed remaining stock (10) correctly flagged
  as low stock (reorder level 10), confirmed the expiring-batch endpoint surfaced the batch,
  confirmed over-consuming past available stock was rejected (400), and confirmed a manual
  +2 audit adjustment landed correctly (12 on hand).

**Store Manager app** (`apps/store/`, Flutter): stock list with low-stock and expiring-batch
highlighting, receive-stock form (with vendor/batch/expiry), per-product consume/transfer/
audit-adjustment screen, and a purchase order list/create/receive flow. Shares
`packages/api_client` with the other two apps (new `Product`, `Vendor`, `StockLevel`,
`StockBatch`, `PurchaseOrder` models and the corresponding `ApiClient` methods).

## Explicitly not in Phase 3

Barcode/QR scanning UI (the data model has `sku` but no scanner integration), automatic
stock consumption tied to a completed service booking (currently a manual "Consume" action —
tying it to the technician's "mark complete" action from Phase 2 is a natural next step),
and cosmetic manufacturing/production-batch workflows (turning raw materials into finished
retail products) from the original product vision's Inventory Module.

## Known limitations to address before production

- `getStockForBranch` runs a raw aggregate query per call; fine at current scale, but if a
  branch carries thousands of active batches per product this should get an index review.
- Purchase order receipt currently receives every line item's full ordered quantity in one
  step — no partial receiving (e.g., vendor ships 20 of 30 ordered) yet.
- Same money-rounding caveat as Phases 1–2 applies to `unitCost` fields here.

## Suggested next phase

**Customer app** — registration/OTP login, booking, digital invoice, loyalty points — the
last of the four originally-requested apps (User, Service Provider, Front-Office Billing,
Store all now exist in some form). Done in [`docs/PHASE_4.md`](PHASE_4.md).
