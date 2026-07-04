# Frontmatter reference omits eight current Claude Code fields and misstates `allowed-tools` format

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, "SKILL.md Frontmatter" example block and "Field Constraints" table

## Current state

The frontmatter example documents: `name`, `description`, `license`, `compatibility`, `dependencies`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `context`, `agent`, `argument-hint`, `metadata`. The Field Constraints table says `allowed-tools` is "Space-delimited pre-approved tools."

## Problem

The official Claude Code frontmatter reference documents these additional fields the skill never mentions:

- `when_to_use` — additional trigger context; appended to `description` in the skill listing and counts toward the combined 1,536-character cap.
- `arguments` — named positional arguments enabling `$name` substitution in the body (space-separated string or YAML list; names map to positions in order).
- `disallowed-tools` — tools removed from Claude's available pool while the skill is active (restriction clears on the next user message).
- `model` — model override while the skill is active (applies for the rest of the turn; accepts `/model` values or `inherit`).
- `effort` — effort-level override (`low`, `medium`, `high`, `xhigh`, `max`).
- `hooks` — hooks scoped to the skill's lifecycle.
- `paths` — glob patterns limiting automatic activation to when Claude works with matching files.
- `shell` — `bash` (default) or `powershell` for `` !`command` `` execution.

Format inaccuracy: `allowed-tools` "Accepts a space- or comma-separated string, or a YAML list" per the official reference, not space-delimited only.

Also missing: if `description` is omitted, Claude Code "uses the first paragraph of markdown content".

`paths` is especially relevant to this meta-skill's purpose: project skills scoped to a subsystem (e.g. a frontend-only skill) can use it to avoid firing on unrelated work.

## Grounding

https://code.claude.com/docs/en/skills (fetched 2026-07-04), "Frontmatter reference" table; all field descriptions above are paraphrased or quoted from that table.

## Proposed change

Add the eight missing fields to the frontmatter example and Field Constraints table, correct the `allowed-tools` format note, and document the `description` first-paragraph fallback. Flag `paths` in the design phase (creation-workflow.md Phase 3) as a scoping decision for project skills.
