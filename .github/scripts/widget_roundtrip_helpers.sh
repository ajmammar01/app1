#!/usr/bin/env bash
# Shared helpers for the widget tap-to-toggle round-trip check in
# .github/workflows/ios-sanity-check.yml. Sourced by each step that needs
# them (each `run:` block is its own shell process, so this can't just be
# defined once and reused) — not meant to be run directly.
#
# Expects UDID and APP_GROUP to already be set as environment variables by
# the calling step.

# Locates the plist backing the App Group's shared UserDefaults on the
# given simulator. Empty if the app hasn't written to the group yet.
find_group_plist() {
  find "$HOME/Library/Developer/CoreSimulator/Devices/$UDID/data/Containers/Shared/AppGroup" \
    -name "${APP_GROUP}.plist" 2>/dev/null | head -n1
}

# wait_for_key <key> <expected-value> [timeout-seconds]
# Polls the App Group's shared UserDefaults for <key> to equal
# <expected-value> (PlistBuddy prints booleans as literal "true"/"false").
# Prints the last value it saw (or "<missing>" if the plist/key never
# appeared) and returns non-zero on timeout.
wait_for_key() {
  local key="$1" expected="$2" timeout="${3:-30}" elapsed=0 last_seen="<missing>"
  while [ "$elapsed" -lt "$timeout" ]; do
    local plist_path
    plist_path=$(find_group_plist)
    if [ -n "$plist_path" ]; then
      local value
      value=$(/usr/libexec/PlistBuddy -c "Print :$key" "$plist_path" 2>/dev/null || true)
      if [ -n "$value" ]; then
        last_seen="$value"
        if [ "$value" = "$expected" ]; then
          echo "$value"
          return 0
        fi
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
