# Local `frontend-design` skill duplicates the enabled official plugin — both load, with overlapping triggers

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/skills/frontend-design/SKILL.md; /Users/jakob/dotfiles/.claude/settings.json lines 27-29

## Current state

Two sources provide a frontend-design skill simultaneously:

1. The repo-local skill `.claude/skills/frontend-design/` (deployed via
   the `~/.claude/skills` symlink), frontmatter:

   ```
   name: frontend-design
   description: Create distinctive, production-grade frontend interfaces with
     high design quality. Use this skill when the user asks to build web
     components, pages, or applications. ...
   ```

   File dated 2026-03-13; no `references/` directory; single 4.2 KB file.

2. The official plugin, enabled in `settings.json`:

   ```json
   "enabledPlugins": {
     "frontend-design@claude-plugins-official": true
   }
   ```

   Installed at user scope per `~/.claude/plugins/installed_plugins.json`
   (lastUpdated 2026-07-04, tracks upstream via git SHA).

## Problem

Both skills appear in the session skill list at the same time, as
`frontend-design` and `frontend-design:frontend-design`, with
overlapping trigger descriptions (both target building web UI). The
model has to pick between two near-identical skills on every frontend
task, and the local copy is frozen at its 2026-03-13 content while the
plugin version updates with the marketplace. The two descriptions have
already diverged (plugin: "Guidance for distinctive, intentional visual
design when building new UI or reshaping an existing one"; local: text
above), so they no longer even describe the same behavior.

Note: the per-skill reviews under `todos/skills/` cover the other six
local skills but not `frontend-design`, so no other todo addresses this.

## Grounding

- Session skill list of 2026-07-04 (Claude Code v2.1.201) shows both
  `frontend-design` and `frontend-design:frontend-design` entries.
- `~/.claude/plugins/installed_plugins.json`: `frontend-design@claude-plugins-official`,
  scope `user`, lastUpdated 2026-07-04T11:03:46Z.
- `settings.json` lines 27-29 (quoted above).
- `head -8 .claude/skills/frontend-design/SKILL.md` (quoted above).

## Proposed change

Keep exactly one. Either:

- Delete `.claude/skills/frontend-design/` from the dotfiles and rely on
  the enabled official plugin (auto-updating), or
- Remove `frontend-design@claude-plugins-official` from `enabledPlugins`
  if the pinned local copy is intentional (e.g. edited to taste).

If the local copy was never customized, deleting it is the simpler
option; `diff` it against the plugin's current SKILL.md in
`~/.claude/plugins/cache/claude-plugins-official/frontend-design/` first
to confirm nothing custom is lost.
