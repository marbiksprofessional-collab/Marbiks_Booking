# Front Office Billing (Flutter)

Receptionist/front-desk app: log in, see today's appointments, create/reschedule/cancel a
booking (with chair/room selection), and check a customer out with an invoice.

## Setup

This repo ships the Dart source (`lib/`) and `pubspec.yaml`, but **not** the generated native
platform folders (`android/`, `ios/`, `web/`, etc.) — those are produced by the Flutter SDK,
which was not available in the environment this app was written in. Before first run:

```bash
cd apps/front_office_billing
flutter create .        # generates android/, ios/, web/, etc. around the existing lib/
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>:3000/api/v1
```

`flutter create .` will not overwrite `lib/`, `pubspec.yaml`, or this README — it only adds
the missing platform scaffolding.

Default `API_BASE_URL` (used if you omit `--dart-define`) is `http://localhost:3000/api/v1`,
which works for an Android emulator talking to a backend on the same machine only if you
also set up port forwarding; for a physical device or iOS simulator, pass your machine's LAN
IP or a deployed backend URL explicitly.

## Structure

- `lib/session/auth_session.dart` — login state (`ChangeNotifier`, via `provider`)
- `lib/screens/` — login, appointments list, booking form, checkout/invoice
- `lib/utils/date_utils.dart` — small date/time formatting helpers (no `intl` dependency)
- Talks to the backend through the shared `marbiks_api_client` package
  (`packages/api_client`), which also holds the domain models (`Appointment`, `Invoice`, etc.)
  reused by future apps (Technician, Customer, Store).

## Not yet implemented

Push notifications, offline queueing, biometric/OTP login, multi-branch switching in one
session, and printing/emailing invoices — see `docs/PHASE_1.md` at the repo root for the
overall phased plan.
