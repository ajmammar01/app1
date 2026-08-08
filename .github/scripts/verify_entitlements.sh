#!/usr/bin/env bash
# Verifies that a built .app — and the widget extension embedded inside it —
# actually carries the App Group entitlement in its *code signature*, not just
# in the .entitlements source files (which is all the static "Verify App Group
# entitlement is wired on both targets" step earlier in the workflow can see).
#
# Why this check exists: building with CODE_SIGNING_ALLOWED=NO skips Xcode's
# CodeSign phase entirely. The binary still ends up with a signature, because
# the linker emits a minimal ad-hoc one — `codesign -dv` reports
# "flags=0x20002(adhoc,linker-signed)" — but that signature carries no
# entitlements blob at all. Entitlements are applied *by* the CodeSign phase,
# so skipping it silently drops the App Group. At runtime
# UserDefaults(suiteName:) then returns a usable-looking object whose writes go
# nowhere, and the App Group domain is never created on the simulator. That
# failure is invisible from inside the app, so it has to be caught here.
#
# Usage: verify_entitlements.sh <path-to-.app> <app-group-id>

set -uo pipefail

if [ "$#" -ne 2 ]; then
  echo "::error::Usage: verify_entitlements.sh <path-to-.app> <app-group-id>"
  exit 1
fi

app_path="$1"
app_group="$2"
status=0

check_one() {
  local binary_path="$1" label="$2"

  echo "::group::Signature summary for $label"
  codesign -dv "$binary_path" 2>&1
  echo "::endgroup::"

  local entitlements
  entitlements=$(codesign -d --entitlements :- "$binary_path" 2>/dev/null)

  echo "::group::Entitlements embedded in $label"
  if [ -n "$entitlements" ]; then
    echo "$entitlements"
  else
    echo "(none - no entitlements blob present in the code signature)"
  fi
  echo "::endgroup::"

  if printf '%s' "$entitlements" | grep -q "$app_group"; then
    echo "$label OK: code signature declares $app_group"
  else
    echo "::error::$label's code signature does not declare '$app_group' - the CodeSign phase either did not run or dropped entitlements"
    status=1
  fi
}

if [ ! -d "$app_path" ]; then
  echo "::error::Expected a built app bundle at $app_path but it does not exist"
  exit 1
fi

check_one "$app_path" "$(basename "$app_path")"

# App extensions are embedded under PlugIns/ (add_widget_extension.rb sets the
# embed phase's dst subfolder to :plug_ins).
appex_path=$(find "$app_path/PlugIns" -maxdepth 1 -name "*.appex" 2>/dev/null | head -n1)
if [ -n "$appex_path" ]; then
  check_one "$appex_path" "$(basename "$appex_path")"
else
  echo "::error::No .appex found under $app_path/PlugIns - the widget extension was not embedded"
  status=1
fi

exit $status
