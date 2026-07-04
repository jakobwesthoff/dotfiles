# Dotfiles skill copy drifts from the canonical copy shipped in project-page-starter

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/` (entire directory)

**Current state**: The dotfiles repo carries a full copy of the skill
(SKILL.md plus 4 reference files), last committed 2026-03-13
(dotfiles commit b038637 "Add Claude Code config files managed via stow").

**Problem / opportunity**: The template repository
`jakobwesthoff/project-page-starter` ships its own copy of the same skill
at `skills/setup-project-page/` and updates it together with the
generator (its workflow.md was updated 2026-06-30 with new action
versions, commit e9be969). The dotfiles copy is a snapshot with no sync
mechanism, so it silently falls behind whenever the generator changes.
The drift is already real: the two workflow.md files differ in five
action versions, and generator changes since March (Lua language support,
commit db9e4d6) are reflected in neither copy but make the skill's
content stale relative to the generator.

**Grounding**:

- `diff -ru /Users/jakob/dotfiles/.claude/skills/setup-project-page /Users/jakob/Development/github/jakobwesthoff/project-page-starter/skills/setup-project-page`
  shows workflow.md as the only differing file (five action-version bumps).
- The repo's `AGENTS.md` (lines 97-99) documents the skill's home:
  "This project provides a `/setup-project-page` Claude Code skill
  (defined in `skills/setup-project-page/SKILL.md`)".
- Local clone verified at origin HEAD (e9be969) via `git ls-remote`.

**Proposed change**: Decide on and implement a sync strategy, e.g. one of:

1. Treat the repo copy as canonical and copy it into dotfiles on a
   schedule or before each use (a small `just`/script target that rsyncs
   `skills/setup-project-page/` from the clone or fetches it from GitHub).
2. Symlink the dotfiles skill directory to the local clone's copy.
3. Keep the dotfiles copy authoritative and delete the repo copy
   (requires a change in project-page-starter).

Until one is chosen, at minimum re-copy the current repo version to pick
up the workflow.md action updates.
