# Themes

Four themes, each one for Ghostty, VSCodium, Vim, dircolors and delta:

| Name | Palette |
|---|---|
| `selenized-dark` | [Selenized](https://github.com/jan-warchol/selenized) dark |
| `selenized-light` | Selenized light |
| `solarized-osaka-dark` | [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim) night |
| `solarized-osaka-light` | Solarized Osaka day |

```sh
theme selenized-light               # from anywhere
task theme -- selenized-light       # the same, from this repository
task theme-preview                  # the prompt and ls in each of them
```

## What a switch changes

| Tool | Change |
|---|---|
| delta | `~/.config/delta-theme.gitconfig` links to `themes/delta-<name>.gitconfig`; `home/gitconfig` includes it |
| dircolors | `~/.dircolors` links to `themes/dircolors.dark` or `.light` |
| Vim | `~/.vim/theme.vim` names the colorscheme; `vim/vimrc` sources it |
| Ghostty | `~/.config/ghostty/theme.local` names the palette, and Ghostty reloads on `SIGUSR2` |
| VSCodium | `workbench.colorTheme` in the user settings is set, or added |

The link `~/.config/delta-theme.gitconfig` is how `task link` and `task
status` know the theme in use. Without it, `task link` sets
`solarized-osaka-dark`.

`~/.config/ghostty` is a link to `ghostty/`, so `theme.local` and
`config.local` land in this repository. Git ignores them.

## Known behaviour

**Vim without a theme.** `vim/vimrc` falls back to `solarized-osaka-night`
when `~/.vim/theme.vim` is missing.

**The preview and bold text.** `task theme-preview` assumes Ghostty's
default `bold-is-bright = false`: bold text keeps palette 0 to 7, with a
heavier font.
