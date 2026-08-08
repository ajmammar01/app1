#!/usr/bin/env bash
# Shared helpers for the widget tap-to-toggle round-trip check in
# .github/workflows/ios-sanity-check.yml. Sourced by each step that needs
# them (each `run:` block is its own shell process, so this can't just be
# defined once and reused) — not meant to be run directly.
#
# Expects UDID and APP_GROUP to already be set as environment variables by
# the calling step.

# wait_for_key <key> <expected-value> [timeout-seconds]
# Polls the App Group's shared UserDefaults for <key> to equal
# <expected-value> ("true"/"false" for booleans) by querying the live
# cfprefsd daemon inside the simulator via `defaults read`, rather than
# reading the on-disk plist directly — cfprefsd flushes to disk lazily
# (sometimes not within any bounded window for a foregrounded process
# that never backgrounds/terminates), so a value can be fully committed
# and visible to `defaults read` well before — or without ever — showing
# up in the plist file itself. `defaults read` prints CFBoolean values as
# "1"/"0" rather than PlistBuddy's "true"/"false", so that's normalized
# below to keep callers' expected-value strings unchanged.
# Prints the last value it saw (or "<missing>" if the key never appeared)
# and returns non-zero on timeout.
wait_for_key() {
  local key="$1" expected="$2" timeout="${3:-30}" elapsed=0 last_seen="<missing>"
  while [ "$elapsed" -lt "$timeout" ]; do
    local raw
    raw=$(xcrun simctl spawn "$UDID" defaults read "$APP_GROUP" "$key" 2>/dev/null || true)
    if [ -n "$raw" ]; then
      local value="$raw"
      case "$raw" in
        1) value="true" ;;
        0) value="false" ;;
      esac
      last_seen="$value"
      if [ "$value" = "$expected" ]; then
        echo "$value"
        return 0
      fi
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  echo "$last_seen"
  return 1
}

# Prints the pid(s) of any running Runner process, one per line, empty if none.
runner_pids() {
  xcrun simctl spawn "$UDID" pgrep -f "Runner.app/Runner" 2>/dev/null || true
}

runner_pid_count() {
  # grep -c exits 1 when the count is 0 (no match) — the count printed is
  # still correct, but that exit status would otherwise trip `set -e` in
  # any caller that does `n=$(runner_pid_count)` as a bare statement.
  runner_pids | grep -c . || true
}
