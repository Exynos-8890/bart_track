#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_PATH="${BART_TRACK_APP_PATH:-$HOME/Applications/BartTrack.app}"
BUILD_APP_PATH="${BART_TRACK_BUILD_APP_PATH:-$REPO_ROOT/.build/XcodeDerivedData/Build/Products/Debug/BartTrack.app}"
EXTENSION_RELATIVE_PATH="Contents/PlugIns/BartTrackWidgetExtension.appex"
EXTENSION_ID="com.local.BartTrack.WidgetExtension"

log() {
  printf '[bart-track-uninstall] %s\n' "$1"
}

stop_processes() {
  local patterns=(
    "BartTrack.app/Contents/MacOS/BartTrack"
    "BartTrackWidgetExtension.appex/Contents/MacOS/BartTrackWidgetExtension"
  )

  for pattern in "${patterns[@]}"; do
    local pids
    pids="$(pgrep -f "$pattern" || true)"
    if [[ -n "$pids" ]]; then
      log "Stopping processes matching $pattern: $pids"
      # shellcheck disable=SC2086
      kill $pids 2>/dev/null || true
    fi
  done

  sleep 1

  for pattern in "${patterns[@]}"; do
    local pids
    pids="$(pgrep -f "$pattern" || true)"
    if [[ -n "$pids" ]]; then
      log "Force stopping remaining processes matching $pattern: $pids"
      # shellcheck disable=SC2086
      kill -9 $pids 2>/dev/null || true
    fi
  done
}

unregister_extension_at() {
  local app_path="$1"
  local appex_path="$app_path/$EXTENSION_RELATIVE_PATH"

  if [[ -e "$appex_path" ]]; then
    log "Unregistering widget extension at $appex_path"
    pluginkit -r "$appex_path" 2>/dev/null || true
  fi
}

remove_installed_app() {
  if [[ -e "$APP_PATH" ]]; then
    log "Removing $APP_PATH"
    rm -rf "$APP_PATH"
  else
    log "No installed app found at $APP_PATH"
  fi
}

verify_uninstalled() {
  if [[ -e "$APP_PATH" ]]; then
    log "ERROR: app still exists at $APP_PATH"
    return 1
  fi

  local matches
  matches="$(pluginkit -m -A -D -v -i "$EXTENSION_ID" 2>/dev/null || true)"
  if [[ "$matches" == *"$EXTENSION_ID"* ]]; then
    log "WARNING: pluginkit still reports $EXTENSION_ID:"
    printf '%s\n' "$matches"
  else
    log "No pluginkit registration found for $EXTENSION_ID"
  fi

  local pids
  pids="$(pgrep -f "BartTrack.app|BartTrackWidgetExtension.appex" || true)"
  if [[ -n "$pids" ]]; then
    log "WARNING: BartTrack-related processes still exist: $pids"
  else
    log "No BartTrack-related processes are running"
  fi
}

main() {
  stop_processes
  unregister_extension_at "$APP_PATH"
  unregister_extension_at "$BUILD_APP_PATH"
  remove_installed_app
  verify_uninstalled
  log "Uninstall complete"
}

main "$@"
