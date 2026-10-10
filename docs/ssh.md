# ssh

## The agent

On the Mac, launchd runs Homebrew's `ssh-agent` at login, from
`macos/com.brew.ssh-agent.plist`. It listens on `~/.ssh/agent.sock`, and
`home/zshrc` and `home/bashrc` set `SSH_AUTH_SOCK` to that. The LaunchAgent
also sets it with `launchctl setenv`, for the apps you open from the Dock or
Finder, such as VSCodium. Without that they would get the agent of macOS,
which has no keys and no support for the YubiKey. An app that was open
before keeps the old agent until you quit and open it again. Homebrew's
OpenSSH is newer than the one in macOS, and has the built-in FIDO support
that the YubiKey needs.

`task link` installs the LaunchAgent and starts it with `launchctl
bootstrap`. Without that it would wait for the next login. It leaves a
running agent alone, since a restart drops the keys in it. `task status`
says whether it runs and lists its keys.

`home/ssh_config` adds a key to the agent the first time it is used, and
includes `~/.ssh/config.d/*` for what is local to one computer, and the
configs of Lima and Colima.

On Ubuntu the desktop's own agent is used.

## Keys in the Secure Enclave

macOS 15 and newer can keep an ssh key in the Secure Enclave and ask for
Touch ID when it is used. `ssh-enclave` manages them:

```sh
ssh-enclave create            # a key behind Touch ID, labelled with the serial
ssh-enclave pub               # its public key, for a forge or authorized_keys
ssh-enclave list              # the keys in the enclave, and in the agent
```

From this repository, `task ssh-enclave -- create` does the same.

The keys are named the way the YubiKey's is. That one is
`~/.ssh/id_yubikey_<serial>`, with the comment `yubikey-<serial>`; a key in
the enclave is `~/.ssh/id_enclave_<label>`, with the comment
`enclave-<label>`. The label is the Mac's serial number unless you give one,
as in `ssh-enclave create signing` for a second key.

`sc_auth` makes the key, and ssh reaches it through Apple's security key
provider, `/usr/lib/ssh-keychain.dylib`. The key is of the type
`sk-ecdsa-sha2-nistp256@openssh.com`. This was found and written up in
[a gist by Arian van Putten][gist]; what follows is what the gist and its
comments taught.

**The provider is given per key, never as `SSH_SK_PROVIDER`.** With that
variable set, every `sk-` key goes to the enclave's provider, and the
YubiKey stops working. `ssh-agent` remembers which provider added each key
and uses it to sign, so `ssh-enclave load` adds the enclave's keys with
`ssh-add -S` and the YubiKey keeps the built-in one. Homebrew's agent
accepts the provider, since by default it allows those under `/usr/lib`.

**Stub files, not `ssh-add -K`.** `ssh-enclave` writes
`~/.ssh/id_enclave_<label>` and its `.pub`. The stub points at the key in the
enclave and holds no secret, so it has no passphrase. Loading from it asks
for no PIN; `ssh-add -K` asks for one that the enclave does not use. The stub
also gives the key a comment, `enclave-<label>`, where the provider gives
only `ssh:`.

**The agent loses the keys when it restarts.** `home/zshrc` runs
`ssh-enclave load` when the agent holds no enclave key. That needs neither a
PIN nor Touch ID; the agent asks for Touch ID when it signs.

**One host, one key.** Point `IdentityFile` at the public key, and ssh offers
the agent's key that matches it:

```
Host github.com
    IdentityFile ~/.ssh/id_enclave_<serial>.pub
    IdentitiesOnly yes
```

### What the keys cannot do

- **Leave the Mac.** `ssh-enclave` makes the type `p-256-ne`, which cannot
  be exported. A key of the exportable type `p-256` can be exported by any
  program that runs as you, which is not much better than a key on disk, so
  `ssh-enclave` does not offer it. The YubiKey is the key that moves between
  computers and the one to recover with.
- **Be larger.** OpenSSH takes P-256 security keys only; a `p-384` key is
  made but never works.
- **Follow the fingerprints.** Touch ID is on or off. There is no
  `biometryCurrentSet`, so a fingerprint added later can use the key too.
- **Prove where they live.** Apple offers no attestation: a server cannot
  tell an enclave key from any other `sk-ecdsa` key.

### Known behaviour

**`sc_auth list-ctk-identities` says `Valid NO`.** The date is that of the
self-signed X.509 certificate that `sc_auth` makes with the key, valid for a
year. ssh does not use the certificate, and the key works after that date.

**`ssh-enclave stubs` wrote fewer stubs than there are keys.** Before Apple
fixed FB21992630, `ssh-keygen -K` gave every key the same file name. On such
a macOS only the first key gets a stub; `ssh-add -K -S
/usr/lib/ssh-keychain.dylib` still loads them all into the agent.

**A label has one word.** `ssh-enclave` reads the label from the columns
that `sc_auth` prints, so it takes only `A-Z a-z 0-9 . _ -`.

[gist]: https://gist.github.com/arianvp/5f59f1783e3eaf1a2d4cd8e952bb4acf

## Signing with git

`home/gitconfig` signs every commit and annotated tag with the YubiKey, on
the Mac and on Ubuntu alike. Its `gpg.ssh.defaultKeyCommand` takes the first
`sk-ssh-ed25519` key in the agent. That is the YubiKey's type; keys in the
enclave are `sk-ecdsa`, so they never sign. No serial or path is written into
the file, and a forwarded agent works too.

Git does not add keys to the agent, the way ssh does. When the YubiKey's key
is not in it, signing stops with `defaultKeyCommand succeeded but returned no
keys`. Add it, and sign again; the YubiKey asks for a touch at each signature:

```sh
ssh-add ~/.ssh/id_yubikey_<serial>
```

To verify signatures, git reads `~/.config/git/allowed_signers` on each
computer. It needs the YubiKey's key:

```sh
echo "code@beddari.net namespaces=\"git\" $(cat ~/.ssh/id_yubikey_<serial>.pub)" \
	>> ~/.config/git/allowed_signers
```

Each computer also needs the YubiKey's stub in `~/.ssh`. Copy it from the
other one; it holds no secret without the YubiKey. A key made with
`-O resident` can also be written again from the YubiKey with
`ssh-keygen -K`. Keys given as `key::` need OpenSSH 8.9 or newer; Ubuntu
24.04 has 9.6.
