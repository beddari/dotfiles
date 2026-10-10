# VSCodium

`task link` merges `vscodium/settings.json` into your settings (the repo
wins, your other keys stay), links `keybindings.json`, and installs the two
theme extensions. Keep `settings.json` plain JSON, no comments.

## Extensions

`task brew` installs the extensions listed in `Brewfile`, from
[Open VSX](https://open-vsx.org). Nothing installs them otherwise. Check an
extension and its publisher before adding it.

Not on Open VSX: Copilot Chat, `ms-vscode-remote.*`, `tilt-dev.tiltfile`.
Use `jeanp413.open-remote-ssh` for Remote-SSH.

## Ubuntu

Install VSCodium from [its apt repository](https://vscodium.com/#install)
before `task brew`.
