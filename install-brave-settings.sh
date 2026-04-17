#!/bin/sh
# Apply Brave Browser user-level settings on macOS.
# No sudo required — uses defaults write to the user domain.
set -e

if [ "$(uname)" != "Darwin" ]; then
  echo "macOS only."
  exit 1
fi

DOMAIN="com.brave.Browser"

# Disable telemetry
defaults write "$DOMAIN" BraveP3AEnabled -bool false
defaults write "$DOMAIN" BraveStatsPingEnabled -bool false
defaults write "$DOMAIN" BraveWebDiscoveryEnabled -bool false

# Disable news feed
defaults write "$DOMAIN" BraveNewsDisabled -bool true

# Disable autofill and password manager
defaults write "$DOMAIN" AutofillAddressEnabled -bool false
defaults write "$DOMAIN" AutofillCreditCardEnabled -bool false
defaults write "$DOMAIN" PasswordManagerEnabled -bool false

echo "Brave user settings applied."
echo "Restart Brave for changes to take effect."
