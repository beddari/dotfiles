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
  go where. To sign commits on another computer, lend it the signing key
  alone, below.

## Signing on another computer

Logged in to another computer, git there signs with a key this one lends,
and the prompt comes up here. `ssh-sign-agent` lends, `ssh-sign-forwarded`
signs on the host; both are on every computer after `task link`. Below,
jubilato, a Mac, lends to mio, where three keys can then sign: jubilato's
enclave key, the YubiKey while it sits in jubilato, and the YubiKey at mio's
desk.

What is lent is a second agent that holds the chosen keys and nothing else,
forwarded to the hosts set up for it and no other. The agent that shells
and apps use is never forwarded.

### Set up, once per host

On the computer that lends, with the dotfiles linked on both:

```sh
ssh-sign-agent setup mio
```

- On mio, git gets `gpg.ssh.program` in `~/.gitconfig.local`, and
  jubilato's `user.signingkey` in `allowed_signers`.
- On jubilato, `~/.ssh/config.d/sign-agent-mio` starts the agent and
  forwards its socket whenever ssh connects to mio. Remove the file to end
  the lending.
- It says so when mio's sshd lacks `StreamLocalBindUnlink yes`; without
  it, the socket a closed connection left behind stops the next forward.

### A commit on the host, step by step

1. On jubilato, log in. Touch ID is for the login. ssh starts
   `ssh-sign-agent` by itself and forwards its socket:

   ```sh
   ssh mio
   ```

2. On mio, see that the key came along. It lists `enclave-<serial>`:

   ```sh
   SSH_AUTH_SOCK=~/.ssh/sign-forwarded.sock ssh-add -l
   ```

   `The agent has no identities` or `Connection refused`: on jubilato,
   `ssh-sign-agent`, then log in again.

3. On mio, commit as always. Touch ID comes up on jubilato; approve it:

   ```sh
   cd ~/kode/rigg
   git add -p
   git commit -m "fix: ..."
   ```

4. On mio, check who signed. It says `Good "git" signature for
   code@beddari.net with ECDSA-SK key`, the enclave key:

   ```sh
   git log --show-signature -1
   ```

5. Push. `git push` on mio logs in to the forge with mio's own key, never a
   lent one, and that key is the YubiKey at mio's desk. Away from the desk,
   take the branch out through jubilato, from a clone there; hashes and
   signatures stay as they are:

   ```sh
   git fetch mio:kode/rigg <branch>
   git push origin FETCH_HEAD:<branch>
   ```

   For every branch on mio at once, make mio a remote of the clone, once.
   Without the second line git keeps a `mio/HEAD`, and the push below makes
   a branch named `HEAD` on the forge:

   ```sh
   git remote add mio mio:kode/rigg
   git config remote.mio.followRemoteHEAD never
   ```

   Then, each time. A branch that has moved on at the forge is refused, not
   overwritten:

   ```sh
   git fetch mio
   git push origin 'refs/remotes/mio/*:refs/heads/*'
   ```

### Which key signs

On the host, `ssh-sign-forwarded` asks the forwarded agent, in place of the
host's `user.signingkey`, when the socket answers and git runs in an ssh
session, or no YubiKey is attached to the host. Otherwise it is `ssh-keygen`
and the host's own key signs: at mio's desk the YubiKey, as before.
`SSH_AUTH_SOCK` on the host is untouched: `ssh` and `git push` from there
never see a lent key, only `git commit` and `git tag` do.

What is lent is decided where the keys are. It starts as `user.signingkey`
alone:

```sh
ssh-sign-agent list            # the keys lent; the first one signs
ssh-sign-agent lend yubikey    # lend ~/.ssh/id_*yubikey* too
ssh-sign-agent drop enclave    # stop lending ~/.ssh/id_*enclave*
ssh-sign-agent stop            # lend nothing; the next connection starts over
```

`lend yubikey` asks for the passphrase of the stub. A change shows on the
host at once, with no reconnect. On the host, `SSH_SIGN_KEY` names another
key than the first for one command, by a word in its comment or type:

```sh
SSH_SIGN_KEY=yubikey git commit
```

A name that matches no lent key fails the commit; nothing else signs in its
place.

Limits:

- Root on the host can ask for a signature over anything while the
  connection is open, a login to a forge as well as a commit, with any key
  that is lent, and neither Touch ID nor the YubiKey says what it signs.
  Approve only when you just ran the `git commit`, and lend the YubiKey
  only while you need it.
- A session that began over ssh keeps `SSH_CONNECTION`: a zmx session made
  from jubilato and later used at mio's desk asks jubilato while jubilato is
  connected. Close that connection, or `ssh-sign-agent stop`.
- With several connections to a host the newest holds the socket.
- After `brew upgrade openssh`, restart this agent too: `ssh-sign-agent stop`;
  the next connection starts it.

## zmx-portal

`zmx-portal [host] [session...]` hands zmx sessions on this Mac to a remote
host, so an agent there can type into them. Ctrl-C ends the forward.

- The remote host gets a shell on this Mac as you, agent included. Use it
  only toward hosts you trust as much as this Mac.
- Name the host; the default is `192.168.0.3`.
- `unset SSH_AUTH_SOCK` in a session keeps the agent out of it.

## Signing with git

Commits and annotated tags are signed with an ssh key in the agent. The key
is `user.signingkey` in `~/.gitconfig.local`, one per computer: the enclave
key on a Mac, the YubiKey's key on Ubuntu. Git asks the agent for that key
and no other, so which key signs is decided by configuration, never by what
is plugged in: on a Mac the YubiKey never signs a commit, attached or not.
With no `user.signingkey` git refuses to commit rather than sign with
whatever the agent holds.

To sign one commit with the YubiKey on a Mac, override for that command:
`git -c user.signingkey="key::$(cat ~/.ssh/id_yubikey_<serial>.pub)" commit -S`.
Both keys are in `allowed_signers` on every computer, so either verifies.

Both keys are `sk-` keys to the agent, and the agent signs with an `sk-` key
through a provider: the YubiKey through `ssh-sk-helper` and libfido2, the
enclave key through Apple's `/usr/lib/ssh-keychain.dylib`, which `ssh-enclave
load` names with `ssh-add -S`. A key added with plain `ssh-add` has no
provider, so the agent treats it as a FIDO token and the signature fails with
`agent refused operation` whether or not a YubiKey is attached. The launchd
wrapper and every new shell run `ssh-enclave load`, which repairs that.

Set up a computer, with the key it signs with:

```sh
key="$(ssh-enclave pub | cut -d' ' -f1,2)"                   # Mac
key="$(cut -d' ' -f1,2 ~/.ssh/id_yubikey_<serial>.pub)"      # Ubuntu
git config --file ~/.gitconfig.local user.signingkey "key::$key"
echo "code@beddari.net namespaces=\"git\" $key" >> ~/.config/git/allowed_signers
```

Add the same public key on the forge as a signing key.

| Symptom | Fix |
|---|---|
| `either user.signingkey or gpg.ssh.defaultKeyCommand needs to be configured` | No `~/.gitconfig.local` on this computer; set it up, above |
| `Couldn't find key in agent` | Mac: `ssh-enclave load`. Ubuntu: `ssh-add ~/.ssh/id_yubikey_<serial>`. Over ssh from the Mac: `ssh-sign-agent list` there, then reconnect |
| Mac: `agent refused operation` for every `sk-` key, after `brew upgrade openssh` | The running agent calls a helper the upgrade deleted. `launchctl kickstart -k gui/$(id -u)/com.brew.ssh-agent`; the wrapper reloads the enclave keys, the YubiKey's on its next use |
| Mac: `agent refused operation` for the enclave key only | It was added without its provider. `ssh-add -d ~/.ssh/id_enclave_<label>.pub`, then `ssh-enclave load`, or open a new shell |
| Mac: `~/.ssh/agent.sock` missing after a restart | Allow `ssh-agent-launchd` in the background, then `task link` |
| `git log --show-signature` says no principal matched | Add the other computer's key to `allowed_signers`, below |
| No YubiKey stub on a computer | Copy `~/.ssh/id_yubikey_<serial>{,.pub}` from the other |

```sh
echo "code@beddari.net namespaces=\"git\" $(cat ~/.ssh/id_yubikey_<serial>.pub)" \
	>> ~/.config/git/allowed_signers
```
