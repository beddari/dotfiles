# ssh

## The agent (Mac)

Homebrew's `ssh-agent` runs from launchd on `~/.ssh/agent.sock`, for shells
and for apps opened from the Dock. `task link` starts it; `task status`
shows it and its keys. Reopen apps that were running before the first
`task link`. On Ubuntu the desktop's agent is used.

launchd starts it at login through `~/.local/bin/ssh-agent-launchd`, which
macOS lists by that name in System Settings, General, Login Items &
Extensions, Allow in the Background. Keep it switched on: switched off, the
agent is gone after the next restart, with nothing in the logs.

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
| Mac: `~/.ssh/agent.sock` missing after a restart | Allow `ssh-agent-launchd` in the background, then `task link` |
| Ubuntu: `defaultKeyCommand ... returned no keys` | `ssh-add ~/.ssh/id_yubikey_<serial>` |
| `git log --show-signature` says no principal matched | Add the key to `allowed_signers`, below |
| No YubiKey stub on a computer | Copy `~/.ssh/id_yubikey_<serial>{,.pub}` from the other |

```sh
echo "code@beddari.net namespaces=\"git\" $(cat ~/.ssh/id_yubikey_<serial>.pub)" \
	>> ~/.config/git/allowed_signers
```
