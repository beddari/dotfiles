# Claude Code

`task link` merges `claude/settings.json` into `~/.claude/settings.json`,
as the VSCodium settings are merged: the repo wins, your other keys stay.
Claude Code writes its own state into the same file, such as the accepted
dialogs, which is why it is merged and not linked. `task status` says
whether the two agree. Keep the file plain JSON, no comments.

Objects merge key by key, but an array is replaced whole. The `autoMode`
rule lists are arrays, so the repo holds every rule, and a rule added by
hand to `~/.claude/settings.json` is gone after the next `task link`. Add
it here instead.

## What is in it

| Key | For |
|---|---|
| `env` | Telemetry off |
| `model`, `modelSettings` | The model and its effort |
| `autoMode.environment` | What the auto mode classifier knows about Dataverket: the forge, the registry, the production cluster and the admin session |
| `autoMode.allow` | What it allows beyond its defaults: the swamp publish checklist, reads of the production cluster, the admin tasks, and changes asked for in the conversation |
| `tui`, `theme`, `spinnerTipsEnabled`, `agentPushNotifEnabled` | Looks |

## The auto mode rules

Auto mode runs every command an allow rule does not cover through a
classifier, a model reading the rules in `autoMode`. The `environment`
entries tell it what the names mean; the `allow` entries narrow its own
rules, after `$defaults`. A rule is a strong hint, not a guarantee, so a
command the classifier still refuses is run by hand.

Two rules it never lets a session change for itself: an agent editing
these files (Self-Modification), and anything that prints a credential. So
a change to `claude/settings.json` is a person's commit, and `task link`.

Per-repository rules, the deterministic `permissions.allow` entries that
skip the classifier, belong in that repository's `.claude/settings.json`,
not here.

## No credit in commits

`attribution` is off in `claude/settings.json`, so Claude Code adds no
`Co-Authored-By` trailer and no "Generated with" line. A session has still
written the trailer by hand once, into a signed commit, and undoing that
cost a YubiKey touch and a force push. `git/hooks/commit-msg` is the
guard: it fails a commit whose message credits Claude, before the commit
is signed. `core.hooksPath` in `home/gitconfig` runs it in every
repository; `task link` puts the directory at `~/.config/git/hooks`.

`core.hooksPath` hides a repository's own `.git/hooks`. The global hook
runs the repository's `commit-msg` after its check, so that one still
works, but the other hooks do not. A repository that needs them, with
lefthook or pre-commit say, keeps its own in its local config:

```sh
git config core.hooksPath .git/hooks
```

That repository is then without the guard; the trailer is caught at the
forge, or not at all.
