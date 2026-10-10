# dotfiles

The shell, editor, terminal and system settings of two computers: a Mac and
an Ubuntu 24.04 workstation. [Homebrew](https://brew.sh) installs the tools
on both, and [Task](https://taskfile.dev) links the files into the home
directory.

## What you get

- zsh with Homebrew, a history shared between shells and kept for 21 days,
  and the [Starship](https://starship.rs) prompt. bash has the same basics.
- Four themes, each one for Ghostty, VSCodium, Vim, dircolors and delta at
  once, switched with one command.
- git with commits and tags signed by an ssh key in the agent, and delta as
  its pager.
- [Ghostty](https://ghostty.org) and [VSCodium](https://vscodium.com),
  configured, with the VSCodium extensions from Open VSX.
- On the Mac: Homebrew's `ssh-agent` started by launchd, ssh keys in the
  Secure Enclave beside the YubiKey, and Touch ID for `sudo`.
- Brave with its own policy: no Rewards, Wallet, VPN, AI chat, News, or
  password manager.

## On a new computer

You need git and curl. On Ubuntu, install VSCodium from
[its apt repository](https://vscodium.com/#install) first if you want the
extensions; Homebrew has it for macOS only.

```sh
git clone https://codeberg.org/beddari/dotfiles ~/kode/dotfiles
cd ~/kode/dotfiles
bin/brew-bundle     # Homebrew and the packages, task among them
task link           # link the files and apply the theme
task status         # check that each link is in place
```

Then open a new shell. `task link` can run again at any time: it puts back
each link, removes those to files that have moved, and keeps the theme.

## Tasks

| Task | What it does |
|---|---|
| `task brew` | Install Homebrew when it is missing, and the packages in `Brewfile` |
| `task link` | Link the dotfiles into the home directory and apply the theme in use |
| `task status` | Show each link, the theme, missing packages and, on the Mac, the ssh-agent |
| `task theme -- <name>` | Switch to a theme; `task theme` alone lists them |
| `task theme-preview` | Show the prompt and `ls` in every theme |
| `task ssh-enclave -- <command>` | Make and load ssh keys in the Secure Enclave, on macOS; `task ssh-enclave` alone lists the commands. [docs/ssh.md](docs/ssh.md) |
| `task touchid` | Let Touch ID answer `sudo` and the authorization dialogs, on macOS |
| `task root-prompt` | Give root shells a red prompt and a dark red background |
| `task brave-policy` | Install `brave/policy.json` as Brave's managed policy |
| `task lint` | Run shellcheck on the scripts and check the JSON files |

The last three change the system and run with `sudo`. The others change only
your home directory.

`task link` also puts two commands in `~/.local/bin`, for use anywhere:

| Command | What it does |
|---|---|
| `theme <name>` | The same as `task theme` |
| `ssh-enclave <command>` | The same as `task ssh-enclave` |

## Local to one computer

What differs between the two computers goes in files that git ignores, or
that live outside this repository:

| File | Read by |
|---|---|
| `~/.gitconfig.local` | git, included by `home/gitconfig` |
| `~/.config/ghostty/config.local` | Ghostty, after `ghostty/config` |
| `~/.ssh/config.d/*` | ssh, included by `home/ssh_config` |
| `~/.config/git/allowed_signers` | git, to verify ssh signatures |

## How it is built

```
Taskfile.yml        the tasks; each one calls a script in bin/
Brewfile            the packages, for both computers; OS.mac? marks the Mac's
bin/                one script per task, and functions.sh that they share
local/bin/          the commands that task link puts in ~/.local/bin
home/               shell, git, ssh and Starship, linked into ~ and ~/.config
vim/                vimrc and the four colorschemes
ghostty/            linked as ~/.config/ghostty, with the four palettes
vscodium/           settings, keybindings and two theme extensions
themes/             delta and dircolors, one file per theme
brave/policy.json   Brave's managed policy
macos/              the LaunchAgent for Homebrew's ssh-agent
docs/               the details
```

`bin/functions.sh` lists every link that `task link` makes, and `task status`
checks the same list.

| Document | Content |
|---|---|
| [docs/ssh.md](docs/ssh.md) | The ssh-agent, keys in the Secure Enclave, the YubiKey, git signing |
| [docs/themes.md](docs/themes.md) | The four themes and how a switch reaches each tool |
| [docs/vscodium.md](docs/vscodium.md) | Paths, settings, Open VSX, and VSCodium on Ubuntu |
| [docs/system.md](docs/system.md) | Touch ID, the root prompt and the Brave policy |
