# Dynamic Content table misses named arguments, environment substitutions, and shell-injection details

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, "Dynamic Content" table

## Current state

The table documents three items: `$ARGUMENTS`, `$ARGUMENTS[N]` / `$N`, and `` !`command` ``.

## Problem

The official substitution list is substantially larger, and several omissions are directly useful for generated project skills:

- `$name` — named arguments declared via the `arguments` frontmatter field (names map to argument positions in order).
- `${CLAUDE_SKILL_DIR}` — the directory containing the skill's SKILL.md. The official docs use it so bundled scripts resolve "regardless of the current working directory" (e.g. `python3 ${CLAUDE_SKILL_DIR}/scripts/visualize.py`). Any generated Tier 2/3 skill with `scripts/` should use this instead of relative paths.
- `${CLAUDE_PROJECT_DIR}` — project root (v2.1.196+); also substituted inside `allowed-tools`.
- `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`.
- Multi-line shell injection via a fenced block opened with ` ```! ` (inline form is single-command).
- Inline `` !`cmd` `` is only recognized at start of line or after whitespace; `` KEY=!`cmd` `` stays literal.
- If `$ARGUMENTS` is absent but arguments were passed, Claude Code appends `ARGUMENTS: <value>` to the skill content.
- Indexed arguments use shell-style quoting (`/my-skill "hello world" second` → `$0` = `hello world`); a backslash escapes a literal `$` before a digit/`ARGUMENTS`/argument name.
- Substitution runs once; command output is not re-scanned for further placeholders.
- Shell injection can be disabled by policy (`disableSkillShellExecution` setting); commands are then replaced with `[shell command execution disabled by policy]`.

## Grounding

https://code.claude.com/docs/en/skills (fetched 2026-07-04), "Available string substitutions" table and "Inject dynamic context" section; all details above verbatim or closely paraphrased.

## Proposed change

Extend the Dynamic Content table with `$name`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`, and the ` ```! ` block form. Add the appended-`ARGUMENTS:` fallback and the start-of-line recognition rule as one-line notes. In the writing guidance (Phase 4, scripts step), make `${CLAUDE_SKILL_DIR}` the required way for generated skills to reference their own `scripts/` files.
