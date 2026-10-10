# System settings

These tasks change the system outside the home directory, and run with
`sudo`. Each can run again; it ends up the same.

## Touch ID, on macOS

```sh
task touchid
```

`sudo` in the terminal takes Touch ID through `/etc/pam.d/sudo_local`, which
macOS 14 and newer include and keep across updates.

The authorization dialogs, such as those of installers, take Touch ID
through `pam_localauthentication.so`, put first in
`/etc/pam.d/authorization`. macOS owns that file and may reset it at a major
upgrade. Run `task touchid` again when the dialogs stop taking Touch ID.

Without Touch ID, such as over ssh, both ask for the password.

## The root prompt

```sh
task root-prompt
```

A root shell gets the prompt `[root]` in red and a dark red terminal
background, set with OSC 11 and reset with OSC 111 when the shell exits.

| System | File |
|---|---|
| macOS | `/var/root/.profile`, empty from the start |
| Ubuntu | `/etc/profile.d/root-prompt.sh`, for login shells; `/root/.bashrc` is left alone |

## The Brave policy

```sh
task brave-policy
```

`brave/policy.json` turns off Rewards, Wallet, VPN, AI chat, News, P3A, the
stats ping, Web Discovery, autofill and the password manager. Check it in
`brave://policy`.

**macOS:** the policy becomes a configuration profile,
`com.brave.Browser.policy`. macOS 15 and newer cannot install one from the
command line; then the task opens it in System Settings, where you
double-click it, and leaves `brave/policy-pending.mobileconfig` for you to
remove. After an edit, run the task again.

**Ubuntu:** `/etc/brave/policies/managed/brave-policy.json` links to
`brave/policy.json`, so an edit here is the live policy. Reload policies in
`brave://policy`; Brave needs no restart. The link moved with the file: if
the policy stops working, run the task again.

It needs Brave from Brave's apt repository. The snap ignores managed
policies in every path ([brave/brave-browser#19052][snap]). To move from the
snap, keep the profile:

```sh
cp -a ~/snap/brave/current/.config/BraveSoftware ~/.config/BraveSoftware
sudo snap remove --purge brave
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
	https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main' \
	| sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update && sudo apt install -y brave-browser
```

[snap]: https://github.com/brave/brave-browser/issues/19052
