# age

The age identities are in `~/.config/sops/age`, one file per thing that
holds keys:

| File | Holds | Made again by |
|---|---|---|
| `keys.txt` | the humans: the YubiKey identities | `task age-yubikey` |
| `<system>.txt` | one system's plain key, `AGE-SECRET-KEY-1...` | a backup, or not at all |

sops reads `keys.txt` on its own, on the Mac because `shellrc` sets
`XDG_CONFIG_HOME`, so the YubiKeys open everything they are a recipient
of, everywhere. A system's key is never loaded by default: the systems are
isolated from one another, and a key is named only while working on its
system, in that shell or that repository:

```sh
export SOPS_AGE_KEY_FILE=~/.config/sops/age/dev-cluster.txt
```

## YubiKey

A YubiKey's identity is a stub the plugin reads from the key itself, so a
new computer registers it with the key plugged in:

```sh
task age-yubikey                  # the YubiKey plugged in
task age-yubikey -- --serial N    # one of several plugged in
```

Result: the identity appended to `keys.txt`, its recipient printed. A key
in the file already is left alone. Every decryption asks for a touch, and
the PIN once per session.

A new identity on a YubiKey: `age-plugin-yubikey --generate`, then
`task age-yubikey`. All identities on the YubiKeys plugged in:
`age-plugin-yubikey --list`.

`age-plugin-yubikey` comes from Homebrew on both computers. On Ubuntu it
talks to the key through the system's `pcscd`, from apt, which Homebrew
does not provide; the Mac has it built in.

## A system's key

A plain key is a secret with nothing behind it: mode 600, a copy somewhere
safe, and its public key from `age-keygen -y <file>`. Make the YubiKeys
recipients of the system's files too, and the plain key is only for the
system itself.
