# Service Provider (Technician) App (Flutter)

Technician-facing app: clock in/out, see today's assigned service queue, view a customer's
treatment history before starting a service, mark a service complete, and track commission
earned over a date range.

## Setup

Same as the Front Office Billing app — this repo ships Dart source only, not the generated
native platform folders:

```bash
cd apps/service_provider
flutter create .        # generates android/, ios/, web/, etc. around the existing lib/
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>:3000/api/v1
```

Log in with the seeded technician account (`technician@marbiks.com` / `ChangeMe123!`, see the
root README) to try it against the local backend.

## Structure

- `lib/screens/queue_screen.dart` — clock in/out + today's assigned appointments
- `lib/screens/appointment_detail_screen.dart` — customer treatment history + mark complete
- `lib/screens/commission_screen.dart` — commission summary for a date range
- Shares `packages/api_client` (models + HTTP client) with the Front Office Billing app.

## Not yet implemented

Daily targets, before/after photo capture, product recommendations, training videos, task
checklists, leave requests, and salary slips — see `docs/PHASE_1.md` at the repo root for the
overall phased plan; those land in later phases once the core operational loop (attendance,
queue, commission) is proven in daily use.
