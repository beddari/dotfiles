#!/bin/sh
# Enable Touch ID for sudo and GUI authorization dialogs on macOS (Ventura and later).
#
# sudo (terminal):
#   Creates /etc/pam.d/sudo_local — stable, survives macOS updates.
#
# GUI authorization dialogs (installer prompts, privilege escalation):
#   Prepends pam_localauthentication.so to /etc/pam.d/authorization.
#   NOTE: that file is managed by macOS and may be reset on major OS upgrades.
#   Re-run this script after a major upgrade if GUI Touch ID stops working.
set -eu

if [ "$(uname)" != "Darwin" ]; then
  echo "macOS only."
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

SUDO_LOCAL="/etc/pam.d/sudo_local"
AUTHORIZATION="/etc/pam.d/authorization"

# --- state checks ---

sudo_touchid_enabled() {
  [ -f "$SUDO_LOCAL" ] && grep -qF "pam_tid.so" "$SUDO_LOCAL" 2>/dev/null
}

gui_touchid_enabled() {
  grep -qF "pam_localauthentication.so" "$AUTHORIZATION" 2>/dev/null
}

# --- installers ---

install_sudo_touchid() {
  tee "$SUDO_LOCAL" > /dev/null <<'EOF'
# sudo_local: local config file which survives system updates and is included
# for sudo PAM configuration on macOS 14 Sonoma and later.
auth       sufficient     pam_tid.so
EOF
}

install_gui_touchid() {
  tmp="$(mktemp)"
  # Prepend the LocalAuthentication line before the first existing auth line
  awk 'BEGIN { line="auth       sufficient     pam_localauthentication.so" }
       !done && /^auth/ { print line; done=1 }
       { print }' "$AUTHORIZATION" > "$tmp"
  cp "$tmp" "$AUTHORIZATION"
  rm -f "$tmp"
}

# --- main ---

NEED_SUDO=false; sudo_touchid_enabled || NEED_SUDO=true
NEED_GUI=false;  gui_touchid_enabled  || NEED_GUI=true

if ! $NEED_SUDO && ! $NEED_GUI; then
  echo "Touch ID already enabled for both sudo and GUI authorization."
  exit 0
fi

if $NEED_SUDO; then
  install_sudo_touchid
  echo "Touch ID for terminal sudo enabled."
fi

if $NEED_GUI; then
  install_gui_touchid
  echo "Touch ID for GUI authorization dialogs enabled."
fi

echo ""
echo "Falls back to password when Touch ID is unavailable (e.g. over SSH)."
