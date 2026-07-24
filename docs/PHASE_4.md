# Phase 4 — Customer App (OTP Auth, Booking, Reviews, Loyalty)

## What's implemented

**Backend additions**:
- `customer-auth` module: phone + OTP login, which doubles as registration — verifying an
  OTP for a phone number with no existing `Customer` creates one. OTPs are 6 digits, hashed
  with bcrypt before storage, expire after 5 minutes, and are single-use (consumed on
  successful verification). **There is no real SMS gateway wired up** — outside
  `NODE_ENV=production` the code is logged server-side and also returned in the response
  body (`devCode`) so the whole flow is testable without one; wire an actual SMS provider
  into `OtpService.requestOtp` before this goes anywhere near real users, at which point the
  dev-code fallback stops firing automatically.
- Extended the shared `JwtStrategy`/`JwtPayload` (from Phase 1) to carry an optional `phone`
  field alongside `email`, so customer tokens (`role: CUSTOMER`, `sub: customer.id`) flow
  through the exact same guards and `@Roles()` decorators as staff tokens — no parallel auth
  system, just a different way to mint the same kind of JWT.
- `customer-portal` module, mounted at **`/me`** (deliberately not nested under
  `/customers/:id`, to avoid any route-ordering ambiguity with the staff-facing
  `CustomersController`'s `/customers/:id`): profile, book/reschedule/cancel your own
  appointments, and view your own invoices. Every reschedule/cancel/invoice-read first loads
  the record and checks `record.customerId === requestingCustomerId`, throwing `403` on
  mismatch — verified with two separate customer accounts in the manual test below.
- `reviews` module: a customer can review their own appointment once it's `COMPLETED` (not
  before), and only once (unique constraint on `appointmentId` + an explicit check for a
  clear `409` rather than a raw DB error).
- Loyalty points are no longer a field nobody writes to: `BillingService.markPaid` now awards
  1 point per full ₹100 of the invoice total, guarded against re-awarding if an invoice is
  marked paid twice.
- Migration for the new tables (`otp_codes`, `reviews`); unit tests for OTP generation/
  expiry/consumption, ownership-check rejections (reschedule/cancel/invoice access), and
  loyalty point math — all passing.
- Verified end-to-end manually against real Postgres: requested an OTP, confirmed a wrong
  code was rejected and the OTP couldn't be replayed after use, registered via OTP verify,
  fetched profile, booked an appointment through `/me/appointments`, rescheduled it, confirmed
  a second customer got `403` trying to cancel the first customer's appointment, confirmed
  reviewing before completion was rejected, then had staff complete the appointment and mark
  its invoice paid, confirmed loyalty points landed correctly (17 points on a ₹1770 invoice),
  confirmed the customer could see that invoice via `/me/invoices`, submitted a review, and
  confirmed a second review on the same appointment was rejected (`409`).

**Customer app** (`apps/customer/`, Flutter): phone/OTP login (showing the dev-mode code
directly so it's usable without a real SMS setup), browse branches/services and book, a
bookings list with reschedule/cancel while upcoming, an invoice + star-rating review view
once a visit is completed, and a profile screen showing the loyalty point balance. Shares
`packages/api_client` with the other three apps (new `Review` model, OTP request/verify
methods, and the `/me/...` self-service calls).

## Explicitly not in Phase 4

Google/Apple social login (needs real OAuth client credentials from the business — a
decision point, not a technical gap), wallet balance, membership/packages, gift cards,
subscription plans, chat support, video consultation, home service booking, push
notifications, and the referral program — all listed under "Customer Features" in the
original product vision. Also not done: technician/resource selection during customer
self-booking (the customer books a service and a time; staff can still assign a specific
technician/chair afterward from the Front-Office app).

## Known limitations to address before production

- No real SMS gateway — see above. This is the one that actually blocks real users.
- No refresh-token flow (same note as Phase 1) — customer tokens simply expire.
- No rate limiting on OTP requests, so nothing currently stops someone from spamming OTP
  requests at a given phone number.

## Suggested next phase

All four originally-requested apps now exist in some working form (Front-Office Billing,
Service Provider, Store, Customer). From here the natural next steps are either going deeper
on one of the four (real SMS/payment gateway integration, barcode scanning, partial PO
receiving) or moving to a cross-cutting concern the product vision calls out repeatedly:
real-time dashboards/reporting, or the HR/Finance modules (payroll, leave, GST reports) that
haven't been touched yet.
