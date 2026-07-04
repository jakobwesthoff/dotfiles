# Global git ignore file (~/.config/git/ignore) is not tracked in the dotfiles

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.gitconfig (no `core.excludesfile`); missing /Users/jakob/dotfiles/.config/git/ignore
**Related todo**: 01kwppd9ezp2ebng09dbfrgfqb-stow-claude-untracked-conflicts.md (relies on the pattern this file provides)

## Current state

`~/.gitconfig` is a symlink into the repo and sets no
`core.excludesfile` (`git config --global core.excludesfile` returns
nothing), so git falls back to the XDG default `~/.config/git/ignore`.
That file exists on this machine (dated 2025-05-16) with exactly one
pattern:

```
**/.claude/settings.local.json
```

The repo stows `.config/*` into `~/.config`, but contains no
`.config/git/` directory — the ignore file is untracked local state.

## Problem

The setup depends on this pattern: it is what keeps per-project
`.claude/settings.local.json` files (including the one inside this repo,
see the related claude-config todo) out of `git status` in every
repository. On a machine bootstrapped from these dotfiles the file would
not exist, and every project with local Claude settings would show
untracked noise. It is the same reproducibility gap class as the rfx
MCP registration todo: behavior the daily workflow relies on, living
only outside the repo.

## Proposed change

Add `.config/git/ignore` to the repo with the pattern above; the
existing `stow .` deployment then covers it (after resolving the fact
that a real file already sits at `~/.config/git/ignore` — restow or
delete the local copy first). Alternatively inline the decision to keep
it machine-local, but then the claude-config todos should not rely on
it.
