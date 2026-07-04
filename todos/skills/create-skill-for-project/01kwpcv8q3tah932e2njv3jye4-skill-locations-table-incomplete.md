# Skill locations table omits enterprise, plugin, and nested skills plus precedence rules

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, "How Skills Work" table; `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/creation-workflow.md`, Phase 2 checklist (".claude/commands/ — any legacy commands?")

## Current state

The locations table lists only two scopes: Project (`.claude/skills/<name>/SKILL.md`) and Personal (`~/.claude/skills/<name>/SKILL.md`). The workflow calls `.claude/commands/` files "legacy commands".

## Problem

The official Claude Code docs list four locations plus discovery rules the skill omits:

- **Enterprise** (managed settings) — applies to all users in the organization.
- **Plugin** (`<plugin>/skills/<skill-name>/SKILL.md`) — namespaced as `plugin-name:skill-name`, so plugin skills cannot conflict with other levels.
- **Nested project skills**: skills also load from `.claude/skills/` directories in parent directories up to the repo root, and on demand from subdirectories whose files Claude touches (monorepo support). Name clashes get directory-qualified names like `apps/web:deploy`.
- **Precedence**: "enterprise overrides personal, and personal overrides project", and a same-named skill at any level overrides a bundled skill. Relevant when advising where to create a skill.
- **Commands merge**: "Custom commands have been merged into skills." A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy`; commands support the same frontmatter; if a skill and a command share a name, the skill wins. Calling them "legacy" understates that they remain a fully supported equivalent form.
- A `<skill-name>` entry may be a symlink to a directory elsewhere on disk; Claude Code follows it.

For a meta-skill whose Phase 2 explicitly audits existing skills and whose Phase 3 decides where a new skill lives, the missing scopes and precedence rules are directly actionable gaps (e.g. checking for a personal or plugin skill that would shadow or duplicate the new project skill).

## Grounding

https://code.claude.com/docs/en/skills (fetched 2026-07-04), "Where skills live" section; all quotes verbatim.

## Proposed change

Extend the locations table to all four scopes, add the precedence sentence, mention nested/monorepo discovery in one line, and reword the Phase 2 checklist item on `.claude/commands/` from "legacy commands" to the merged-equivalence framing (also: check `~/.claude/skills/` for personal skills that would overlap the planned project skill).
