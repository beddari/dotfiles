# dotfiles

Shell, editor, terminal and system settings for a Mac and an Ubuntu 24.04
workstation. [Homebrew](https://brew.sh) installs the tools,
[Task](https://taskfile.dev) links the files into `$HOME`.

## What you get

- zsh and bash with the [Starship](https://starship.rs) prompt; zsh history
  shared between shells, kept 21 days.
- Four themes across Ghostty, VSCodium, Vim, dircolors and delta, one command.
- git commits and tags signed: the enclave key on the Mac, the YubiKey on
  Ubuntu.
- [Ghostty](https://ghostty.org) and [VSCodium](https://vscodium.com),
  configured.
- Claude Code's settings, with the auto mode rules for Dataverket's
  infrastructure, merged into place.
- Mac: Homebrew's `ssh-agent` for shells and apps, ssh keys in the Secure
  Enclave, Touch ID for `sudo`.
- Brave on the Mac without Rewards, Wallet, VPN, AI chat, News or password
  manager; Brave Origin on Ubuntu.
- Ubuntu: the apt repositories with their keys pinned, GNOME settings from
  a file, a touch of the YubiKey for `sudo`; AltGr+Space is a plain space.

## Set up a new computer

```sh
git clone https://git.dataverket.org/beddari/dotfiles ~/kode/beddari/dotfiles
cd ~/kode/beddari/dotfiles
bin/brew-bundle     # Homebrew and the packages, task among them
task link           # link the files, apply the theme
task status         # every link should say ok
```

On Ubuntu, then `task apt-repos` and `sudo apt install codium`.

The checkout can live anywhere: the scripts find the repository from where
they are, and the links point at it. After moving it, run `task link` from
the new place; the links are made again to there.

Open a new shell. Repositories on git.dataverket.org fetch over https and
push over ssh whichever url they were cloned with; `.gitconfig` rewrites
them.

## Tasks

| Task | Result |
|---|---|
| `task brew` | Packages in `Brewfile` installed |
| `task link` | Links in place, theme applied; safe to rerun |
| `task status` | Links, theme, packages, ssh-agent, GNOME settings, apt repos |
| `task theme -- <name>` | Every tool switched to the theme |
| `task theme-preview` | Prompt and `ls` shown in every theme |
| `task ssh-enclave -- <command>` | Secure Enclave keys made and loaded (Mac) |
| `task age-yubikey` | The YubiKey registered as an age identity for sops |
| `task touchid` | Touch ID for `sudo` and auth dialogs (Mac, sudo) |
| `task yubikey-sudo` | A YubiKey touch for `sudo`, password as fallback (Ubuntu, sudo) |
| `task root-prompt` | Red prompt in root shells (sudo) |
| `task brave-policy` | Brave policy installed (Mac, sudo) |
| `task apt-repos` | Repositories in `apt/` installed (Ubuntu, sudo) |
| `task gnome` | Settings in `gnome/settings` applied (Ubuntu) |
| `task lint` | shellcheck and JSON checks pass |

`theme` and `ssh-enclave` also work from anywhere, from `~/.local/bin`.

## Per-computer settings

| File | For |
|---|---|
| `~/.gitconfig.local` | git |
| `~/.config/ghostty/config.local` | Ghostty |
| `~/.ssh/config.d/*` | ssh hosts |
| `~/.config/git/allowed_signers` | verifying signed commits |

## Layout

```
Taskfile.yml   tasks; each calls a script in bin/
Brewfile       packages for both computers
bin/           task scripts; functions.sh lists every link
local/bin/     theme, ssh-enclave, ssh-agent-launchd
home/          zshrc, bashrc, shellrc (shared by both), gitconfig, ssh_config
vim/ ghostty/ vscodium/ claude/ themes/ brave/ macos/ gnome/ apt/ yubikey/    tool configs
docs/          the docs below
```

| Doc | Covers |
|---|---|
| [docs/ssh.md](docs/ssh.md) | Agent, Secure Enclave keys, YubiKey, git signing |
| [docs/age.md](docs/age.md) | age identities on the YubiKey, for sops |
| [docs/themes.md](docs/themes.md) | Themes |
| [docs/vscodium.md](docs/vscodium.md) | VSCodium |
| [docs/claude.md](docs/claude.md) | Claude Code: the settings, and the auto mode rules |
| [docs/system.md](docs/system.md) | apt repos, Touch ID, YubiKey, root prompt, Brave policy, GNOME |
