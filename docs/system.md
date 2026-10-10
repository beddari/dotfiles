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

## Brave policy

```sh
task brave-policy
```

Result: Rewards, Wallet, VPN, AI chat, News, telemetry, autofill and the
password manager off. Check `brave://policy`.

- Mac: installs a configuration profile. On macOS 15 and later System
  Settings opens instead; double-click the profile there. Rerun after
  editing `brave/policy.json`.
- Ubuntu: links the policy, so edits apply on Reload in `brave://policy`.
  Needs Brave from Brave's apt repository; the snap ignores policies.

Switch Ubuntu from the snap to apt, keeping your profile:

```sh
cp -a ~/snap/brave/current/.config/BraveSoftware ~/.config/BraveSoftware
sudo snap remove --purge brave
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
	https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main' \
	| sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update && sudo apt install -y brave-browser
```
