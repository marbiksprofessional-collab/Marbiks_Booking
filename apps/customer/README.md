# Customer (Flutter)

The customer-facing app: phone + OTP login (which also handles first-time registration),
browsing services and booking an appointment, viewing/rescheduling/cancelling your own
bookings, viewing the digital invoice for a completed visit, leaving a review, and checking
your loyalty point balance.

## Setup

Same as the other apps in this repo — Dart source only, no generated native platform folders:

```bash
cd apps/customer
flutter create .        # generates android/, ios/, web/, etc. around the existing lib/
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>:3000/api/v1
```

There's no real SMS gateway wired up on the backend yet — when you request an OTP, the
backend logs the code to its console **and** returns it in the response outside production
(`devCode`), and the login screen displays that dev code directly so you can log in without
a real phone/SMS setup. Wire an actual SMS provider into `backend/src/customer-auth/otp.service.ts`
before shipping this to real users, and that dev-code fallback disappears automatically
(`NODE_ENV=production` stops it from being returned).

## Structure

- `lib/session/auth_session.dart` — OTP request/verify flow (`ChangeNotifier`, via `provider`)
- `lib/screens/login_screen.dart` — phone entry → OTP code (+ optional name/email for new customers)
- `lib/screens/book_service_screen.dart` — pick a branch + service + date/time, book
- `lib/screens/my_bookings_screen.dart` / `booking_detail_screen.dart` — booking history,
  reschedule/cancel while upcoming, invoice + review once completed
- `lib/screens/profile_screen.dart` — name/phone/email, loyalty point balance, logout
- Shares `packages/api_client` with the other three apps.

## Not yet implemented

Google/Apple social login (would need real OAuth client credentials from the business — ask
before wiring this up), wallet/gift cards/packages/subscription plans, chat support, video
consultation, home service booking, push notifications, and referral programs — see
`docs/PHASE_4.md` at the repo root for what's built and deferred.
