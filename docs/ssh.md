# ssh

## The agent (Mac)

Homebrew's `ssh-agent` runs from launchd on `~/.ssh/agent.sock`, for shells
and for apps opened from the Dock. `task link` starts it; `task status`
shows it and its keys. Reopen apps that were running before the first
`task link`. On Ubuntu the desktop's agent is used.

launchd starts it at login through `~/.local/bin/ssh-agent-launchd`, which
macOS lists by that name in System Settings, General, Login Items &
Extensions, Allow in the Background. Keep it switched on: switched off, the
agent is gone after the next restart, with nothing in the logs. The wrapper
loads the Secure Enclave keys as soon as the agent listens, so a restart of
the agent, `launchctl kickstart -k gui/$(id -u)/com.brew.ssh-agent`, leaves
nothing to redo. Restart it after `brew upgrade openssh`: the old process
keeps a path to a helper the upgrade deleted, and every `sk-` key then
answers `agent refused operation`.

## Secure Enclave keys (Mac)

```sh
ssh-enclave create            # new key behind Touch ID, loaded into the agent
ssh-enclave pub               # public key, for a forge or authorized_keys
ssh-enclave list              # keys in the enclave and in the agent
ssh-enclave delete <label>    # remove a key everywhere
```

Files: `~/.ssh/id_enclave_<label>{,.pub}`, comment `enclave-<label>`. The
label defaults to the Mac's serial; `ssh-enclave create signing` makes a
second key. New shells reload the keys into the agent; using one asks for
Touch ID.

Use a key for one host, in `~/.ssh/config.d/<host>`:

```
Host github.com
    IdentityFile ~/.ssh/id_enclave_<serial>.pub
    IdentitiesOnly yes
```

Limits:

- The key never leaves this Mac. Keep the YubiKey on every server and forge
  as the way back in.
- P-256 only.
- Touch ID accepts any enrolled finger, including ones added later.
- `sc_auth` shows `Valid NO` after a year. Ignore it; the key still works.

Background: [Arian van Putten's gist](https://gist.github.com/arianvp/5f59f1783e3eaf1a2d4cd8e952bb4acf).

## Keep keys from being used behind your back

- YubiKey and Touch ID keys ask on every use. A prompt you didn't expect:
  deny it.
- A `--no-touch` key signs for any process running as you, silently. Load it
  with `ssh-add -c` to get a confirmation.
- Don't forward the agent (`ssh -A`, `ForwardAgent yes`): root on the remote
  host can use your keys. If a host needs it, `ssh-add -h` limits which keys
  go where.

## zmx-portal

`zmx-portal [host] [session...]` hands zmx sessions on this Mac to a remote
host, so an agent there can type into them. Ctrl-C ends the forward.

- The remote host gets a shell on this Mac as you, agent included. Use it
  only toward hosts you trust as much as this Mac.
- Name the host; the default is `192.168.0.3`.
- `unset SSH_AUTH_SOCK` in a session keeps the agent out of it.

## Signing with git

| Computer | Signs with | Set in |
|---|---|---|
| Mac | Enclave key | `~/.gitconfig.local` |
| Ubuntu | YubiKey key in the agent | `home/gitconfig` |

Which key signs is decided by configuration, never by what is plugged in:

- `user.signingkey` in `~/.gitconfig.local` names one public key, and git
  asks the agent for that key and no other. On a Mac it is the enclave key,
  so the YubiKey never signs a commit there, attached or not.
- With no `user.signingkey`, git runs the `defaultKeyCommand` in
  `home/gitconfig`, which picks the first `sk-ssh-ed25519` key in the agent:
  the YubiKey. That is Ubuntu, where there is no enclave. An enclave key is
  `sk-ecdsa`, so the command never picks one by accident.
- To sign one commit with the YubiKey on a Mac, override for that command:
  `git -c user.signingkey="key::$(cat ~/.ssh/id_yubikey_<serial>.pub)" commit -S`.
  Both keys are in `allowed_signers` on every computer, so either verifies.

Both keys are `sk-` keys to the agent, and the agent signs with an `sk-` key
through a provider: the YubiKey through `ssh-sk-helper` and libfido2, the
enclave key through Apple's `/usr/lib/ssh-keychain.dylib`, which `ssh-enclave
load` names with `ssh-add -S`. A key added with plain `ssh-add` has no
provider, so the agent treats it as a FIDO token and the signature fails with
`agent refused operation` whether or not a YubiKey is attached. The launchd
wrapper and every new shell run `ssh-enclave load`, which repairs that.

Set up a Mac:

```sh
git config --file ~/.gitconfig.local user.signingkey \
	"key::$(ssh-enclave pub | cut -d' ' -f1,2)"
echo "code@beddari.net namespaces=\"git\" $(ssh-enclave pub | cut -d' ' -f1,2)" \
	>> ~/.config/git/allowed_signers
```

Add the same public key on the forge as a signing key.

| Symptom | Fix |
|---|---|
| Mac: signing fails, key not in agent | `ssh-enclave load` |
| Mac: `agent refused operation` for every `sk-` key, after `brew upgrade openssh` | The running agent calls a helper the upgrade deleted. `launchctl kickstart -k gui/$(id -u)/com.brew.ssh-agent`; the wrapper reloads the enclave keys, the YubiKey's on its next use |
| Mac: `agent refused operation` for the enclave key only | It was added without its provider. `ssh-add -d ~/.ssh/id_enclave_<label>.pub`, then `ssh-enclave load`, or open a new shell |
| Mac: `~/.ssh/agent.sock` missing after a restart | Allow `ssh-agent-launchd` in the background, then `task link` |
| Ubuntu: `defaultKeyCommand ... returned no keys` | `ssh-add ~/.ssh/id_yubikey_<serial>` |
| `git log --show-signature` says no principal matched | Add the key to `allowed_signers`, below |
| No YubiKey stub on a computer | Copy `~/.ssh/id_yubikey_<serial>{,.pub}` from the other |

```sh
echo "code@beddari.net namespaces=\"git\" $(cat ~/.ssh/id_yubikey_<serial>.pub)" \
	>> ~/.config/git/allowed_signers
```
