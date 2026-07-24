#!/usr/bin/env bash
#
# build_apks.sh
#
# Bootstraps the Android platform (if missing) and builds a release APK for
# each of the Marbiks Flutter apps in this repo, then collects the resulting
# .apk files into ./dist/apks/.
#
# Requires: a working Flutter SDK (with the Android toolchain installed -
# `flutter doctor` should show no Android issues) on PATH, or pass its bin
# directory via FLUTTER_BIN below. This script does not install Flutter or
# the Android SDK itself - see docs/PHASE_6.md for why (this repo's own dev
# sandbox has an organizational network policy that blocks the Android SDK's
# download host, so APK compilation must happen in an unrestricted
# environment - your machine, or the .github/workflows/build-apks.yml CI
# workflow in this repo, which runs on an unrestricted GitHub-hosted runner).
#
# Usage:
#   ./build_apks.sh                 # build every app
#   ./build_apks.sh front_office_billing store   # build only the named apps
#
# Exit code is non-zero if any app fails to build; the script still attempts
# every app rather than stopping at the first failure, so a single broken
# app doesn't block a release build of the other four.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$REPO_ROOT/apps"
DIST_DIR="$REPO_ROOT/dist/apks"

# Real app directories in this repo. (Not "front_office", "technician",
# "store_app", "customer_portal" - those names don't exist here; see
# docs/PHASE_6.md for the correction.)
ALL_APPS=(front_office_billing service_provider store customer super_admin)

# Flutter project name + org used when bootstrapping android/ for an app
# that doesn't have it yet (matches what was already generated for each app
# in this repo - re-running this is a no-op if android/ already exists).
declare -A PROJECT_NAMES=(
  [front_office_billing]="marbiks_front_office_billing"
  [service_provider]="marbiks_service_provider"
  [store]="marbiks_store"
  [customer]="marbiks_customer"
  [super_admin]="marbiks_super_admin"
)

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[1;33m[warn] %s\033[0m\n' "$1"; }
fail() { printf '\033[1;31m[fail] %s\033[0m\n' "$1"; }

if ! command -v "$FLUTTER_BIN" >/dev/null 2>&1; then
  fail "Flutter SDK not found (looked for '$FLUTTER_BIN' on PATH)."
  echo "Install Flutter (https://docs.flutter.dev/get-started/install) and make sure"
  echo "'flutter doctor' shows the Android toolchain as installed before running this."
  exit 1
fi

log "Using Flutter: $("$FLUTTER_BIN" --version | head -n1)"

if [ "$#" -gt 0 ]; then
  TARGET_APPS=("$@")
else
  TARGET_APPS=("${ALL_APPS[@]}")
fi

mkdir -p "$DIST_DIR"

FAILED_APPS=()
BUILT_APPS=()

for app in "${TARGET_APPS[@]}"; do
  app_dir="$APPS_DIR/$app"

  if [ ! -d "$app_dir" ]; then
    fail "No such app directory: apps/$app (known apps: ${ALL_APPS[*]})"
    FAILED_APPS+=("$app")
    continue
  fi

  log "[$app] Preparing"
  pushd "$app_dir" >/dev/null

  if [ ! -d "android" ]; then
    project_name="${PROJECT_NAMES[$app]:-marbiks_$app}"
    log "[$app] No android/ folder yet - bootstrapping via 'flutter create --platforms=android'"
    if ! "$FLUTTER_BIN" create . --platforms=android --project-name "$project_name" --org com.marbiks; then
      fail "[$app] 'flutter create' failed"
      FAILED_APPS+=("$app")
      popd >/dev/null
      continue
    fi
  else
    log "[$app] android/ already present - skipping bootstrap"
  fi

  log "[$app] Fetching packages"
  if ! "$FLUTTER_BIN" pub get; then
    fail "[$app] 'flutter pub get' failed"
    FAILED_APPS+=("$app")
    popd >/dev/null
    continue
  fi

  log "[$app] Building release APK"
  if "$FLUTTER_BIN" build apk --release; then
    apk_path="build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$apk_path" ]; then
      dest="$DIST_DIR/${app}-release.apk"
      cp "$apk_path" "$dest"
      log "[$app] OK -> ${dest#"$REPO_ROOT"/}"
      BUILT_APPS+=("$app")
    else
      fail "[$app] Build reported success but $apk_path is missing"
      FAILED_APPS+=("$app")
    fi
  else
    fail "[$app] 'flutter build apk --release' failed"
    FAILED_APPS+=("$app")
  fi

  popd >/dev/null
done

echo
log "Summary"
echo "Built:  ${BUILT_APPS[*]:-none}"
echo "Failed: ${FAILED_APPS[*]:-none}"

if [ "${#BUILT_APPS[@]}" -gt 0 ]; then
  echo
  echo "Artifacts in $DIST_DIR:"
  ls -lh "$DIST_DIR" 2>/dev/null || true
fi

if [ "${#FAILED_APPS[@]}" -gt 0 ]; then
  exit 1
fi
