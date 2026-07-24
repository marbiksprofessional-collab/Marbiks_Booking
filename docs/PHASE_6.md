# Phase 6 — Release Orchestration: APK Build Pipeline & AWS Production Infrastructure

## Two corrections to the original request, made up front

1. **App directory names.** The request named `front_office`, `technician`, `store_app`,
   `customer_portal`. The real directories in this repo are `apps/front_office_billing`,
   `apps/service_provider`, `apps/store`, `apps/customer` — plus a fifth app,
   `apps/super_admin` (added in Phase 5), which wasn't mentioned but is included here
   since a release pipeline that silently skipped one of the five real apps would be a
   worse outcome than a corrected assumption. Everything below uses the real names.

2. **Branch.** This session's designated branch is `claude/new-session-8h5wzt`, not `main`
   — that's a repo-level constraint for this environment (see the top of this session's
   instructions), not something changed by this request. Work here is committed and
   pushed to that branch, same as every previous phase. If you want it on `main`, the
   normal path is a PR from this branch (reviewable, revertable) rather than a direct
   push — ask and I'll open one.

## What was actually run vs. what's real-but-unexecuted

This phase hit two genuine environment walls, both reported rather than routed around
(per this session's own network-egress policy, which explicitly says to report blocked
hosts, not retry them):

- **`dl.google.com` (Android SDK's download host) is policy-blocked.** Confirmed via the
  proxy's status endpoint (`connect_rejected`, "gateway answered 403 to CONNECT"). This
  means the Android SDK itself cannot be installed in this sandbox, which means
  `flutter build apk` cannot produce a real `.apk` here — confirmed directly:
  `flutter build apk --release` fails with `No Android SDK found`, exactly as expected,
  not a code problem.
- **`registry.terraform.io` (the Terraform provider registry) is also policy-blocked.**
  Confirmed the same way. This means `terraform init`/`validate`/`plan` could not be run
  in this sandbox either.

Everything else *was* actually run for real:

- **Flutter itself was installed for real** (its own CDN, `storage.googleapis.com`, isn't
  blocked) and used to genuinely verify all five apps and the shared package for the
  first time in this project's history:
  - `flutter create . --platforms=android` was run for real in all five app directories,
    producing real, committed `android/` platform folders (previously only documented as
    "needs `flutter create .`" — now actually done).
  - `flutter analyze` was run on all five apps + `packages/api_client`. It found and this
    phase fixed real issues: a deprecated `DropdownButtonFormField.value` (→
    `initialValue`) across four apps, deprecated `Color.withOpacity` (→ `.withValues`)
    across three apps and the shared widgets, a non-const constructor, and — in every
    single app — the Flutter-generated placeholder `test/widget_test.dart` referencing a
    `MyApp` class that never existed in any of these apps' actual `main.dart` (a real
    compile error, not a style nit). Every app's placeholder test was replaced with a
    real one that pumps the app's actual login screen and asserts on it. All five apps
    and the shared package now analyze clean and pass their tests for real.
  - `terraform fmt` was run against the new IaC (a real parse+reformat, catching syntax
    errors) and every module input/output reference was manually cross-checked by hand
    against every module's declared variables/outputs, since `terraform validate`
    wasn't available. This is a real but partial substitute for schema-level validation.
- **No AWS resources exist anywhere.** There are no AWS credentials in this session. The
  Terraform in `infra/aws/` is real, complete, non-placeholder infrastructure-as-code —
  but "complete" here means "ready to `terraform apply`," not "applied."

## What's implemented

### `build_apks.sh` (repo root)

Iterates the five real app directories, bootstraps `android/` via `flutter create` if
missing (idempotent — all five already have it committed now), runs `flutter pub get`
and `flutter build apk --release` for each, and collects successful builds into
`dist/apks/<app>-release.apk`. Continues past a single app's failure rather than aborting
the whole run, and exits non-zero if anything failed. Actually executed in this sandbox
against two apps to prove the control flow and error reporting are correct — both
correctly got through bootstrap and `pub get`, then failed at the same confirmed
`No Android SDK found` wall, with a clean per-app failure summary and a non-zero exit
code, exactly as designed.

Not signed for Play Store: no release keystore exists, so `flutter build apk --release`
falls back to Flutter's debug signing key. Fine for internal QA installs, not for a
Play Store submission — see the comment block in `.github/workflows/build-apks.yml`.

### `.github/workflows/build-apks.yml`

The actual path to real compiled APKs: GitHub-hosted runners have normal, unrestricted
internet access, so this workflow (triggered manually or on a `v*.*.*` tag) installs
Flutter + the Android SDK for real via `subosito/flutter-action`, then analyzes, tests,
and builds a release APK per app, uploading each as a workflow artifact. This is expected
to actually work once pushed — it isn't blocked by anything specific to this sandbox.

### `infra/aws/` (Terraform)

Self-hosted AWS stack for the backend, in three modules plus a fourth for CI/CD auth:

- `modules/network` — VPC, public/private subnets across 2 AZs, single NAT gateway
  (documented cost/availability tradeoff).
- `modules/database` — RDS PostgreSQL (Multi-AZ by default) in private subnets only, a
  security group scoped to just the ECS service, connection details in Secrets Manager.
- `modules/backend_service` — ECR repo, ECS Fargate cluster/service/task definition, ALB
  with optional HTTPS (bring your own ACM cert), CPU-based autoscaling, IAM roles scoped
  to exactly what's needed.
- `modules/github_oidc` — lets GitHub Actions assume an AWS role via OIDC federation
  instead of storing long-lived AWS access keys as a repo secret, scoped to this exact
  repo via the `token.actions.githubusercontent.com:sub` condition.

See `infra/aws/README.md` for the actual apply steps and everything it deliberately
doesn't include yet (DNS/ACM provisioning, remote Terraform state backend, a bastion/VPN
for running migrations against the private-subnet database).

### `.github/workflows/deploy-backend.yml`

Builds the backend Docker image, pushes to ECR, and updates the ECS service on every push
to `main` touching `backend/**` — authenticating via the OIDC role above, no stored AWS
keys. This is what runs *after* the one-time `terraform apply`.

## Known limitations to address before real production use

- `backend/docker-entrypoint.sh` runs migrations from every container's own startup
  (a Phase 1 decision, unchanged since). With `desired_count = 2`+ on ECS, two tasks
  starting simultaneously both attempt `migration:run` - TypeORM's migrations table
  makes this safe in the common case but it's not a real distributed lock. Before this
  carries real traffic, move migrations to a one-off deploy step (a single Fargate task
  or a CI step) rather than every container's entrypoint.
- No Terraform remote state backend configured (local state only) - fine solo, not once
  more than one person runs `apply`.
- No DNS/ACM automation, no bastion/VPN for reaching the private-subnet database to run
  migrations against it.
- APK release signing isn't configured (debug-signed only) - not Play Store ready.

## Suggested next step

Push this branch, let `.github/workflows/build-apks.yml` produce real signed-with-debug-key
APKs to confirm the pipeline end-to-end, and/or provide real AWS credentials + a
`terraform.tfvars` to actually stand up the stack in `infra/aws/README.md`'s first-time
setup steps.
