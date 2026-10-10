# VSCodium

[VSCodium](https://vscodium.com) is VS Code without Microsoft's branding and
telemetry. Its files have the same format; only the paths differ:

| | macOS | Ubuntu |
|---|---|---|
| User settings | `~/Library/Application Support/VSCodium/User/` | `~/.config/VSCodium/User/` |
| Extensions | `~/.vscode-oss/extensions/` | `~/.vscode-oss/extensions/` |

`task link` does three things:

- It merges `vscodium/settings.json` into the user settings with
  `jq -s '.[0] * .[1]'`. This repository wins; keys it does not have are
  kept. The file must be plain JSON, without comments.
- It links `vscodium/keybindings.json`.
- It links the two theme extensions in `vscodium/extensions/`.

`theme` sets `workbench.colorTheme` in the user settings, so the theme is
not in `vscodium/settings.json`.

## Extensions

`Brewfile` lists the extensions, and `brew bundle` installs them with the
`codium` CLI when there is no `code` CLI. They come from
[Open VSX](https://open-vsx.org), VSCodium's marketplace, and not from
Microsoft's. Extensions that Microsoft publishes there under a licence for
its marketplace only are not to be had: Copilot Chat, `ms-vscode-remote.*`
and `tilt-dev.tiltfile`. `jeanp413.open-remote-ssh` takes the place of
Remote-SSH.

`home/bashrc` runs `brew bundle --vscode --go` after `brew upgrade`, so the
extensions and Go tools keep up with `Brewfile`.

## On Ubuntu

Homebrew's casks are for macOS only. Install VSCodium from
[its apt repository](https://vscodium.com/#install) before `task brew`, so
that `codium` is on PATH when `brew bundle` installs the extensions.
