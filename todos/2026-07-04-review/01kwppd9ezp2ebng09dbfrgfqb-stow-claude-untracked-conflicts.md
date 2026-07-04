# Next `stow .` conflicts on `.claude/settings.local.json` and would symlink `scheduled_tasks.lock` into `~/.claude`

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.stow-local-ignore (needs new patterns); affects /Users/jakob/dotfiles/.claude/settings.local.json and /Users/jakob/dotfiles/.claude/scheduled_tasks.lock

## Current state

`~/.claude` is deployed by `stow .` (README.md line 15) as an unfolded
directory: five per-entry symlinks exist (`CLAUDE.md`, `commands`,
`settings.json`, `skills`, `statusline-command.sh` all point to
`../dotfiles/.claude/...`), while `~/.claude` itself is a real directory
full of runtime state.

Two untracked files now sit inside `dotfiles/.claude/` and are not
covered by `.stow-local-ignore`:

- `.claude/settings.local.json` (project-local permission rules for the
  dotfiles repo, git-ignored via the global gitignore pattern
  `**/.claude/settings.local.json`)
- `.claude/scheduled_tasks.lock` (runtime lock written by the scheduled
  tasks feature, git-ignored via `.git/info/exclude`)

## Problem

`stow -n -v 2 .` run from `/Users/jakob/dotfiles` on 2026-07-04 shows:

```
LINK: .claude/scheduled_tasks.lock => ../dotfiles/.claude/scheduled_tasks.lock
CONFLICT when stowing .: cannot stow dotfiles/.claude/settings.local.json
  over existing target .claude/settings.local.json since neither a link
  nor a directory and --adopt not specified
WARNING! stowing . would cause conflicts:
```

So the next real `stow .` (or the `stow -R .` recommended by the
sibling todo `01kwpkwdy8882bx0njs9pxf1q4-stow-ignore-gaps.md`) will:

1. Abort with a conflict, because `~/.claude/settings.local.json`
   already exists as a real file with different, user-scope content.
2. If the conflict were resolved, symlink the dotfiles project's
   `scheduled_tasks.lock` into `~/.claude`, making one runtime lock file
   serve two scopes.

## Grounding

- `stow -n -v 2 .` output above (2026-07-04).
- `ls -la ~/.claude/` shows `settings.local.json` as a regular file
  (not a symlink) with its own content.
- Stow ignore semantics: a pattern without a slash matches the file
  basename; with a slash it matches the full relative path
  (GNU Stow manual, "Types And Syntax Of Ignore Lists",
  https://www.gnu.org/software/stow/manual/stow.html).

## Proposed change

Add to `.stow-local-ignore`:

```
^/\.claude/settings\.local\.json$
^/\.claude/scheduled_tasks\.lock$
```

Consider also pre-empting the other Claude Code runtime files that
`.git/info/exclude` already anticipates under `**/.claude/`
(`scheduled_tasks.json`, `routines/.state/`, `worktrees/`,
`checkpoints/`, `mailbox/`, `agent-registry.json`, etc.), since any of
them can appear in `dotfiles/.claude/` when a Claude Code session runs
in this repo. A basename-style block would cover them wholesale, but
verify each pattern with `stow -n -v 2 .` before relying on it.
