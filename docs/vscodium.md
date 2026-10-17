# VSCodium

`task link` merges `vscodium/settings.json` into your settings (the repo
wins, your other keys stay), links `keybindings.json`, and installs the two
theme extensions. Keep `settings.json` plain JSON, no comments.

## Extensions

`task brew` installs the extensions listed in `vscodium/extensions.txt`,
with the `codium` CLI, from [Open VSX](https://open-vsx.org). They are not
in `Brewfile`: brew bundle would use the `code` CLI, and Microsoft's
marketplace, whenever VS Code is installed. Nothing installs them
otherwise. Check an extension and its publisher before adding it.

Not on Open VSX: Copilot Chat, `ms-vscode-remote.*`, `tilt-dev.tiltfile`.
Use `jeanp413.open-remote-ssh` for Remote-SSH.

## Ubuntu

Install VSCodium with `task apt-repos` and `sudo apt install codium`
before `task brew`.
