# System tasks

Safe to rerun. All but the GNOME settings run with `sudo`.

## apt repositories (Ubuntu)

```sh
task apt-repos
```

Result: the repositories in `apt/` installed in `/etc/apt/sources.list.d`
and apt updated. One deb822 `.sources` file per repository with its signing
key inline, so the key is pinned here: Brave, VSCodium, Zabbly's incus, and
the OBS Studio, quickemu and xtradeb PPAs; xtradeb builds chromium and
firefox. `task status` shows the files that differ,
and the keys in `trusted.gpg.d`, which may sign any repository; Ubuntu's own
two should be the only ones.

Brave is the exception: `brave-browser` depends on `brave-keyring`, which
ships the keyring and on every upgrade checks that
`brave-browser-release.sources` points at it, or else symlinks the key into
`trusted.gpg.d`. So that file keeps its name and the package's keyring, and
`apt/` holds a copy of the keyring for the first install.

To add a repository, write the `.sources` file with the key inline, as the
others are. Print a key with
`gpg --no-default-keyring --keyring <file.gpg> --export --armor`, indent
every line one space and make blank lines ` .`. Check it before installing:

```sh
apt-get update -o Dir::Etc::SourceList=/dev/null \
  -o Dir::Etc::SourceParts=$PWD/apt -o Dir::State=/tmp/apt \
  -o Dir::Cache=/tmp/apt -o Debug::NoLocking=1
```

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

## GNOME settings (Ubuntu)

```sh
task gnome
```

Result: the settings in `gnome/settings` applied with `gsettings`, one line
per setting: schema, key, value as `gsettings get` prints it. `task status`
shows the settings that differ. To add one, find its line with
`gsettings list-recursively | grep <word>`, or run `dconf watch /` while
changing it in Settings.

Today it holds one: Space is a plain space at every modifier level
(`nbsp:none`). The Norwegian layout otherwise puts a no-break space on
AltGr+Space, invisible and breaking commands and code; the other `nbsp`
variants put a zero-width joiner or non-joiner there instead.
