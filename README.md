# dotfiles

Shell, editor, terminal and system settings for a Mac and an Ubuntu 24.04
workstation. [Homebrew](https://brew.sh) installs the tools,
[Task](https://taskfile.dev) links the files into `$HOME`.

## What you get

- zsh and bash with the [Starship](https://starship.rs) prompt; zsh history
  shared between shells, kept 21 days.
- Four themes across Ghostty, VSCodium, Vim, dircolors and delta, one command.
- git commits and tags signed with the YubiKey.
- [Ghostty](https://ghostty.org) and [VSCodium](https://vscodium.com),
  configured.
- Mac: Homebrew's `ssh-agent` for shells and apps, ssh keys in the Secure
  Enclave, Touch ID for `sudo`.
- Brave on the Mac without Rewards, Wallet, VPN, AI chat, News or password
  manager; Brave Origin on Ubuntu.

## Set up a new computer

On Ubuntu, first install VSCodium from
[its apt repository](https://vscodium.com/#install).

```sh
git clone https://git.dataverket.org/beddari/dotfiles ~/kode/dotfiles
cd ~/kode/dotfiles
bin/brew-bundle     # Homebrew and the packages, task among them
task link           # link the files, apply the theme
task status         # every link should say ok
```

Open a new shell. To push, switch the remote to ssh:
`git remote set-url origin ssh://git@git.dataverket.org/beddari/dotfiles.git`

## Tasks

| Task | Result |
|---|---|
| `task brew` | Packages in `Brewfile` installed |
| `task link` | Links in place, theme applied; safe to rerun |
| `task status` | Links, theme, missing packages, ssh-agent and its keys |
| `task theme -- <name>` | Every tool switched to the theme |
| `task theme-preview` | Prompt and `ls` shown in every theme |
| `task ssh-enclave -- <command>` | Secure Enclave keys made and loaded (Mac) |
| `task touchid` | Touch ID for `sudo` and auth dialogs (Mac, sudo) |
| `task root-prompt` | Red prompt in root shells (sudo) |
| `task brave-policy` | Brave policy installed (Mac, sudo) |
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
local/bin/     theme, ssh-enclave
home/          zshrc, bashrc, shellrc (shared by both), gitconfig, ssh_config
vim/ ghostty/ vscodium/ themes/ brave/ macos/    tool configs
docs/          the docs below
```

| Doc | Covers |
|---|---|
| [docs/ssh.md](docs/ssh.md) | Agent, Secure Enclave keys, YubiKey, git signing |
| [docs/themes.md](docs/themes.md) | Themes |
| [docs/vscodium.md](docs/vscodium.md) | VSCodium |
| [docs/system.md](docs/system.md) | Touch ID, root prompt, Brave policy |
