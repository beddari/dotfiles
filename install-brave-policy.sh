#!/bin/sh
# Install Brave Browser managed policies on macOS.
set -e

if [ "$(uname)" != "Darwin" ]; then
  echo "macOS only."
  exit 1
fi

echo "This will write Brave Browser enterprise policies to"
echo "  /Library/Managed Preferences/com.brave.Browser.plist"
echo ""
echo "Managed preferences require root access. You will be prompted for your password."
echo ""
printf "Continue? [y/N] "
read -r answer
case "$answer" in
  [yY]*) ;;
  *) echo "Aborted."; exit 0 ;;
esac

MANAGED_DIR="/Library/Managed Preferences"
PLIST="${MANAGED_DIR}/com.brave.Browser.plist"

sudo mkdir -p "$MANAGED_DIR"

sudo tee "$PLIST" > /dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>BraveRewardsDisabled</key><true/>
  <key>BraveWalletDisabled</key><true/>
  <key>BraveVPNDisabled</key><true/>
  <key>BraveAIChatEnabled</key><false/>
</dict>
</plist>
EOF

sudo chmod 644 "$PLIST"

# Clean up stale user-level keys for policy-managed settings
DOMAIN="com.brave.Browser"
for key in BraveRewardsDisabled BraveWalletDisabled BraveVPNDisabled BraveAIChatEnabled; do
    defaults delete "$DOMAIN" "$key" 2>/dev/null || true
done

sudo killall cfprefsd 2>/dev/null || true

echo ""
echo "Brave managed policies written to ${PLIST}"
echo "Restart Brave and verify at brave://policy"
