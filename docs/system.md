# System tasks

These run with `sudo` and are safe to rerun.

## Touch ID (Mac)

```sh
task touchid
```

Result: `sudo` and installer dialogs accept Touch ID; the password still
works. A backup of each PAM file it changes is saved beside it as
`<file>.<date>.bak`. Rerun after a major macOS upgrade if the dialogs stop
taking Touch ID.

## Root prompt

```sh
task root-prompt
```

Result: root shells show a red `[root]` prompt on a dark red background.
Mac: `/var/root/.profile`. Ubuntu: `/etc/profile.d/root-prompt.sh`.

## Brave policy (Mac)

```sh
task brave-policy
```

Result: Rewards, Wallet, VPN, AI chat, News, telemetry, autofill and the
password manager off. Check `brave://policy`. On macOS 15 and later System
Settings opens instead; double-click the profile there. Rerun after editing
`brave/policy.json`.

Ubuntu uses Brave Origin, which needs no policy.
