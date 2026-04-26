#!/bin/sh
# Install Brave Browser managed policies.
#
# macOS: generates and installs a configuration profile from brave-policy.json
#        via `profiles install`. The profile is tracked by macOS and survives
#        Brave updates that would delete a loose /Library/Managed Preferences plist.
#
# Linux: writes brave-policy.json directly to /etc/brave/policies/managed/,
#        which is the standard Chromium/Brave managed policy directory.
#
# Edit brave-policy.json to change policy values — it is the single source of truth.
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POLICY_JSON="${SCRIPT_DIR}/brave-policy.json"
OS="$(uname)"

if [ ! -f "$POLICY_JSON" ]; then
  echo "Error: ${POLICY_JSON} not found."
  exit 1
fi

case "$OS" in
  Darwin|Linux) ;;
  *) echo "Unsupported platform: ${OS}"; exit 1 ;;
esac

if [ "$OS" = "Linux" ]; then
  POLICY_DIR="/etc/brave/policies/managed"
  DEST="${POLICY_DIR}/brave-policy.json"
  echo "Installing ${DEST}..."
  mkdir -p "$POLICY_DIR"
  cp "$POLICY_JSON" "$DEST"
  chmod 644 "$DEST"
  echo ""
  echo "Brave policy installed at ${DEST}"
  echo "Restart Brave and verify at brave://policy"

elif [ "$OS" = "Darwin" ]; then
  PROFILE_ID="com.brave.Browser.policy"
  TMPCONFIG="$(mktemp /tmp/brave-policy-XXXXXX)"
  mv "$TMPCONFIG" "${TMPCONFIG}.mobileconfig"
  TMPCONFIG="${TMPCONFIG}.mobileconfig"

  # Generate the mobileconfig plist from brave-policy.json using Python 3.
  # Fixed UUIDs keep the profile identity stable across re-installs.
  python3 - "$POLICY_JSON" "$TMPCONFIG" <<'PYEOF'
import sys, json, plistlib

policy_json_path, output_path = sys.argv[1], sys.argv[2]

with open(policy_json_path) as f:
    policies = json.load(f)

profile = {
    "PayloadContent": [{
        "PayloadDescription": "Brave Browser enterprise policies",
        "PayloadDisplayName": "Brave Browser",
        "PayloadIdentifier": "com.brave.Browser.policy.settings",
        "PayloadOrganization": "Local",
        "PayloadType": "com.brave.Browser",
        "PayloadUUID": "9E2C4A6B-8D1F-3E5A-7B9C-1D3F5A7B9E1C",
        "PayloadVersion": 1,
        **policies,
    }],
    "PayloadDescription": "Brave Browser enterprise policy",
    "PayloadDisplayName": "Brave Browser Policy",
    "PayloadIdentifier": "com.brave.Browser.policy",
    "PayloadOrganization": "Local",
    "PayloadRemovalDisallowed": False,
    "PayloadScope": "System",
    "PayloadType": "Configuration",
    "PayloadUUID": "3D5A8C21-F4B2-4E9A-BC3D-7F1E2A4B6C8D",
    "PayloadVersion": 1,
}

with open(output_path, "wb") as f:
    plistlib.dump(profile, f, fmt=plistlib.FMT_XML)
PYEOF

  # Remove old bare plist left by previous installs
  OLD_PLIST="/Library/Managed Preferences/com.brave.Browser.plist"
  if [ -f "$OLD_PLIST" ]; then
    echo "Removing old managed preferences plist..."
    rm -f "$OLD_PLIST"
  fi

  # Remove existing profile so install is idempotent
  if profiles list 2>/dev/null | grep -q "$PROFILE_ID"; then
    echo "Removing existing Brave policy profile..."
    profiles remove -identifier "$PROFILE_ID"
  fi

  echo "Installing configuration profile..."
  # macOS 15 Sequoia removed 'profiles install' from the command line.
  # Opening the mobileconfig file triggers System Settings to prompt for installation.
  # Detect which method is available and use it.
  if profiles install -path "$TMPCONFIG" 2>/dev/null; then
    rm -f "$TMPCONFIG"
    killall cfprefsd 2>/dev/null || true
    echo ""
    echo "Brave policy profile installed (identifier: ${PROFILE_ID})"
    echo "Restart Brave and verify at brave://policy"
    echo "To remove: sudo profiles remove -identifier ${PROFILE_ID} (requires root)"
  else
    # macOS 15+: open the file so System Settings handles installation
    SAVED="${SCRIPT_DIR}/brave-policy-pending.mobileconfig"
    cp "$TMPCONFIG" "$SAVED"
    chmod 644 "$SAVED"
    rm -f "$TMPCONFIG"
    echo ""
    echo "Opening System Settings to the Profiles pane..."
    echo "Double-click 'Brave Browser Policy' to install it."
    sudo -u "${SUDO_USER:-$(logname)}" open "$SAVED"
    sleep 1
    sudo -u "${SUDO_USER:-$(logname)}" open "x-apple.systempreferences:com.apple.preferences.configurationprofiles"
    sleep 2
    rm -f "$SAVED"
    echo ""
    echo "Click 'Install' in the Profiles pane to complete installation."
    echo "Restart Brave and verify at brave://policy"
  fi
fi