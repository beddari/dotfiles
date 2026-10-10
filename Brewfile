# The packages for this Mac and the Ubuntu workstation, with Homebrew:
#   task brew, or bin/brew-bundle on a new computer
brew "age"
brew "age-plugin-se" if OS.mac?         # age keys in the Secure Enclave
brew "age-plugin-yubikey"
brew "colima" if OS.mac?
brew "coreutils" if OS.mac?             # GNU ls and dircolors, for the themes
brew "d2" if OS.linux?
brew "delve" if OS.linux?
brew "forgejo-cli" if OS.linux?
brew "git"
brew "go"
brew "go-task"                          # task: the runner, see Taskfile.yml
brew "goreleaser"
brew "jq"                               # task link merges the VSCodium settings with it
brew "k9s"
brew "kopia"
brew "kubernetes-cli"
brew "lima" if OS.mac?
brew "mtr"
brew "openssh" if OS.mac?               # the ssh-agent; docs/ssh.md says why
brew "openstackclient"
brew "opentofu"
brew "proton-pass-cli" if OS.mac?
brew "shellcheck"                       # task lint
brew "sops"
brew "starship"
brew "talosctl"
brew "tilt"
brew "tree"
brew "ykman"

go "golang.org/x/tools/gopls"
go "golang.org/x/vuln/cmd/govulncheck"

# Casks are for macOS only.
cask "brave-browser" if OS.mac?
cask "firefox@developer-edition" if OS.mac?
cask "font-fira-code" if OS.mac?
cask "ghostty" if OS.mac?
cask "inkscape" if OS.mac?
cask "joplin" if OS.mac?
cask "proton-pass" if OS.mac?
cask "signal" if OS.mac?
cask "spotify" if OS.mac?
cask "vscodium" if OS.mac?

# brew bundle installs these with the codium CLI, when there is no code
# CLI, so they come from Open VSX. On Ubuntu, VSCodium comes from its own apt
# repository first; docs/vscodium.md has the details.
vscode "bpruitt-goddard.mermaid-markdown-syntax-highlighting"
vscode "dnut.rewrap-revived"
vscode "golang.go"
vscode "jeanp413.open-remote-ssh"
vscode "opentofu.vscode-opentofu"
vscode "pomdtr.excalidraw-editor"
vscode "pomdtr.markdown-kroki"
vscode "shardulm94.trailing-spaces"
vscode "terrastruct.d2"
