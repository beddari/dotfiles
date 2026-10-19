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
