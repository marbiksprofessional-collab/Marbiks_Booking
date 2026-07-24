# Store (Flutter)

Store Manager app: current stock levels per branch (with low-stock and expiring-batch
highlighting), receiving new stock, consuming/adjusting stock, transferring stock between
branches, and creating/receiving purchase orders from vendors.

## Setup

Same as the other apps in this repo — Dart source only, no generated native platform folders:

```bash
cd apps/store
flutter create .        # generates android/, ios/, web/, etc. around the existing lib/
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>:3000/api/v1
```

Log in with the seeded store manager account (`store@marbiks.com` / `ChangeMe123!`, see the
root README) to try it against the local backend.

## Structure

- `lib/screens/stock_screen.dart` — stock levels, low-stock highlighting, expiring-batch banner
- `lib/screens/receive_stock_screen.dart` — receive new stock (with optional batch/expiry/vendor)
- `lib/screens/stock_actions_screen.dart` — consume, transfer to another branch, audit adjustment
- `lib/screens/purchase_orders_screen.dart`, `create_purchase_order_screen.dart`,
  `purchase_order_detail_screen.dart` — vendor purchase order lifecycle (place → receive)
- Shares `packages/api_client` with the other apps.

## Not yet implemented

Barcode/QR scanning (the backend models a `sku` field but there's no scanner UI yet),
consumption tracking tied automatically to service bookings (a technician finishing a facial
doesn't yet auto-deduct the product used — it's a manual "Consume" action), and cosmetic
manufacturing/production-batch workflows. See `docs/PHASE_3.md` at the repo root.
