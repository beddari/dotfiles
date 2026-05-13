# dotfiles

Personal shell, editor, terminal, and OS-config dotfiles for macOS and Linux.

The repo is a flat collection of files plus a few install scripts. `install.sh`
is the entry point; everything else is either symlinked into `$HOME` or invoked
explicitly when needed.

## Bootstrap

```sh
git clone https://codeberg.org/beddari/dotfiles ~/kode/dotfiles
cd ~/kode/dotfiles
./install.sh                  # install Homebrew + brew bundle + symlink dotfiles
```

Component scripts can also be run individually:

```sh
sh install-brew.sh            # Homebrew + Brewfile.$(uname)
sh install-dotfiles.sh        # symlink dotfiles, install VS Code config, etc.
```

`install-dotfiles.sh` is idempotent — it uses `ln -sfn` so re-runs re-point
symlinks to whatever the dotfiles directory currently is.

## Features

### Shell — `zshrc`, `bashrc`

- Homebrew shell env, `~/.local/bin` and `~/go/bin` on PATH.
- Pruned-and-shared zsh history (200k entries, 21-day retention, dedup).
- `brew()` wrapper that re-runs `brew bundle --vscode --go` after `brew upgrade`
  so VS Code extensions and Go tools stay in sync with `Brewfile.$(uname)`.
- macOS-only: remaps non-breaking space (Option+Space on Norwegian layouts)
  back to regular space.
- `terminfo-install <host>` ships the local `$TERM` entry to a remote box via
  `infocmp | ssh host tic -x -` (useful with Ghostty/non-stock terminals).

### Prompt — `starship.toml`

[Starship](https://starship.rs) prompt with a compact custom format:
remote-hostname arrow → directory → git branch → git status → character.
Magenta `❯` on success, red on error. Shows `$ZMX_SESSION` when set.

### Themes — `theme-*.sh`, `theme.sh`, `theme-terminal-colors-preview.sh`

Four coordinated themes covering Ghostty, VS Code, Vim, dircolors, and
[delta](https://github.com/dandavison/delta) (git diff pager):

| Script                          | Palette                                                                       |
|---------------------------------|-------------------------------------------------------------------------------|
| `theme-dark-selenized.sh`       | [Selenized dark](https://github.com/jan-warchol/selenized)                    |
| `theme-light-selenized.sh`      | Selenized light                                                               |
| `theme-dark-solarized-osaka.sh` | [Solarized Osaka night](https://github.com/craftzdog/solarized-osaka.nvim)    |
| `theme-light-solarized-osaka.sh`| Solarized Osaka day                                                           |

Each is a thin wrapper that sets env vars and sources `theme.sh`, which
symlinks the per-tool color files into `$HOME/.config/` and sends `SIGUSR2` to
Ghostty to reload live. The active theme is recorded by the existence of
`~/.config/delta-theme.gitconfig`.

```sh
~/.local/bin/theme-dark-solarized-osaka.sh   # installed by install-dotfiles.sh
./theme-terminal-colors-preview.sh           # preview prompt + ls in every theme
```

### Vim — `vimrc`, `vim-*.vim`

`vimrc` enables `termguicolors`, then sources `~/.vim/theme.vim` if present
(written by `theme.sh`). Falls back to `solarized-osaka-night`. Bundled
colorschemes: `selenized-dark`, `selenized-light`, `solarized-osaka-day`,
`solarized-osaka-night`.

### VS Code — `vscode-settings.json`, `vscode-keybindings.json`, `vscode-*` extension dirs

`install-dotfiles.sh` merges `vscode-settings.json` into the existing
user settings (`jq -s '.[0] * .[1]'`, dotfiles wins) and symlinks keybindings.
Two local theme extensions get symlinked into `~/.vscode/extensions/`:
`darkerized-better-solarized` and `solarized-osaka-night`. Theme switching is
done by `theme.sh` via a `sed`-based rewrite of `workbench.colorTheme`.

### Git — `gitconfig`, `gitconfig.local`, `delta-*.gitconfig`

`gitconfig` (placed at `/etc/gitconfig` or sourced manually) provides:
- ssh-signed commits and signed annotated tags
- `git lg` alias for a compact log graph
- rebase-on-pull with auto-stash
- includes `~/.gitconfig.local` (symlinked from `gitconfig.local`), which
  configures [delta](https://github.com/dandavison/delta) as pager and
  includes `~/.config/delta-theme.gitconfig` (per-theme syntax/diff colors).

### SSH — `ssh_config`

Adds keys to the agent on first use, plus `Include` directives for Lima,
Colima, and a `~/.ssh/config.d/` drop-in directory.

macOS: `com.brew.ssh-agent.plist` is loaded as a LaunchAgent by
`install-dotfiles.sh` so a Homebrew-installed `ssh-agent` runs at login. The
agent socket is exported as `$SSH_AUTH_SOCK` in `zshrc`/`bashrc`.

### Terminal — `ghostty/`

[Ghostty](https://ghostty.org) config with four custom palettes under
`ghostty/themes/`. The top-level `ghostty/config` is minimal — it loads
`theme.local` (managed by `theme.sh`) and `config.local` for host-specific
overrides.

### Brewfiles — `Brewfile.Darwin`, `Brewfile.Linux`

`install-brew.sh` installs Homebrew, then runs
`brew bundle --file=Brewfile.$(uname)`. Darwin gets the full kitchen sink
(casks: Brave, Ghostty, VS Code, Joplin, Proton Pass, Signal, Spotify,
Rectangle…). Linux is a leaner brews-and-vscode-extensions list.

## Optional / manual scripts

These aren't run by `install.sh`. Invoke when needed.

### Red root-shell warning prompt

```sh
sudo ./sudo-configure-root-prompt.sh
```

Writes a `PS1` that says `[root]` in red and sends OSC 11 to set the terminal
background dark red whenever a root shell is active (cleared via OSC 111 on
exit). Targets `/var/root/.profile` on macOS and `/etc/profile.d/root-prompt.sh`
on Linux.

### Touch ID for sudo and GUI prompts (macOS)

```sh
sudo ./sudo-configure-touchid.sh
```

Idempotent. Creates `/etc/pam.d/sudo_local` (stable since macOS 14 Sonoma)
and prepends `pam_localauthentication.so` to `/etc/pam.d/authorization` so
GUI authorization dialogs accept Touch ID. May need to be re-run after a
major macOS upgrade — `/etc/pam.d/authorization` is OS-managed.

### Brave managed policies — `brave-policy.json`, `sudo-configure-brave-policy.sh`

Brave runs with a hardened policy set (Rewards/Wallet/VPN/AI/News/P3A
disabled, autofill and password manager off). `brave-policy.json` is the
single source of truth.

```sh
sudo ./sudo-configure-brave-policy.sh
```

- **macOS:** generates a `.mobileconfig` and installs it as a configuration
  profile (`com.brave.Browser.policy`) via `profiles install`. Falls back to
  opening System Settings → Profiles on macOS 15 Sequoia, where command-line
  install was removed.
- **Linux:** symlinks `brave-policy.json` into `/etc/brave/policies/managed/`,
  so editing the JSON in this repo immediately updates the live policy.

  **Requires the .deb-installed Brave.** The snap build does not honor
  file-based managed policies regardless of path — confirmed both empirically
  and in [brave/brave-browser#19052](https://github.com/brave/brave-browser/issues/19052).
  If you're on the snap, switch first:
  ```sh
  cp -a ~/snap/brave/current/.config/BraveSoftware ~/.config/BraveSoftware
  sudo snap remove --purge brave
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo 'deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main' \
    | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update && sudo apt install -y brave-browser
  ```

Verify in `brave://policy` — `Reload policies` picks up edits without
restarting the browser on the .deb build.

## External references

- [Homebrew](https://brew.sh) — `install-brew.sh`, `Brewfile.*`
- [Starship](https://starship.rs) — `starship.toml`
- [Ghostty](https://ghostty.org) — `ghostty/`
- [delta](https://github.com/dandavison/delta) — git pager, themed
- [Selenized](https://github.com/jan-warchol/selenized) — palette for one theme pair
- [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim) — palette for the other theme pair
- [Brave Group Policy reference](https://support.brave.app/hc/en-us/articles/360039248271-Group-Policy) — policy keys
- [Chromium enterprise policies](https://chromium.googlesource.com/chromium/src/+/HEAD/docs/enterprise/policies.md) — underlying policy mechanism
- [Apple `pam_tid` / `sudo_local`](https://support.apple.com/guide/security/touch-id-and-face-id-security-secd9952567f/web) — Touch ID for sudo background
