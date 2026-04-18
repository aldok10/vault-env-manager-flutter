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
# Double-click this file from inside the mounted `.dmg` or next to
# the extracted `.app`. It looks for the nearest `.app` bundle and
# runs `xattr -cr` against it.
# ------------------------------------------------------------------
set -e

cd "$(dirname "$0")"

APP="$(find . -maxdepth 3 -name '*.app' -type d 2>/dev/null | head -n 1)"

if [ -z "${APP}" ]; then
  echo "ERROR: No .app bundle found next to this script."
  echo "Move this file next to vault_env_manager.app (or run it from"
  echo "inside the mounted .dmg volume) and try again."
  read -n 1 -s -r -p "Press any key to close..."
  exit 1
fi

echo "Found app bundle: ${APP}"
echo "Stripping quarantine attribute..."
/usr/bin/xattr -cr "${APP}"

echo ""
echo "Done. You can now open ${APP} normally (double-click, or via Finder)."
echo ""
read -n 1 -s -r -p "Press any key to close..."
