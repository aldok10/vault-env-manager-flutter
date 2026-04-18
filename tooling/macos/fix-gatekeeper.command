#!/bin/bash
# ------------------------------------------------------------------
# Vault Env Manager — macOS Gatekeeper quarantine stripper.
#
# macOS 14+ Gatekeeper blocks ad-hoc-signed desktop apps (i.e. apps
# not signed with a Developer ID Application certificate + notarized
# by Apple) with a "damaged" / "unknown developer" / "malware" prompt
# on first launch. Stripping the `com.apple.quarantine` extended
# attribute allows Gatekeeper to treat the bundle as trusted for the
# current user.
#
# Resolution order:
#   1. /Applications/vault_env_manager.app          (standard install path)
#   2. $HOME/Applications/vault_env_manager.app     (per-user install)
#   3. nearest *.app bundle up to 3 levels below    (portable / .dmg workflow)
# ------------------------------------------------------------------
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGETS=()

# Prefer the copies a user drags out of the .dmg into /Applications — this
# is the path docs/INSTALL.md documents. Keep going past the first match so
# the per-user install location gets cleaned too when both exist.
for candidate in \
  "/Applications/vault_env_manager.app" \
  "${HOME}/Applications/vault_env_manager.app"; do
  if [ -d "${candidate}" ]; then
    TARGETS+=("${candidate}")
  fi
done

# Fallback: anything sitting next to the script (portable + .dmg workflows).
NEARBY="$(find "${SCRIPT_DIR}" -maxdepth 3 -name '*.app' -type d 2>/dev/null | head -n 1 || true)"
if [ -n "${NEARBY}" ]; then
  TARGETS+=("${NEARBY}")
fi

if [ "${#TARGETS[@]}" -eq 0 ]; then
  echo "ERROR: No Vault Env Manager .app bundle found."
  echo ""
  echo "Drag vault_env_manager.app into /Applications first (or place"
  echo "this script next to the portable .app), then run the helper again."
  read -n 1 -s -r -p "Press any key to close..."
  exit 1
fi

for APP in "${TARGETS[@]}"; do
  echo "Stripping quarantine attribute from: ${APP}"
  /usr/bin/xattr -cr "${APP}"
done

echo ""
echo "Done. Launch Vault Env Manager normally from /Applications or Finder."
echo ""
read -n 1 -s -r -p "Press any key to close..."
