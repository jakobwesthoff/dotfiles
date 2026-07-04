# No naming-style guidance: gerund/noun-phrase conventions, vague-name avoidance, reserved words

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md` (Field Constraints: format rules only); `references/creation-workflow.md` Phase 3/4 (no naming step beyond "Directory name MUST match")

## Current state

The skill covers only the mechanical `name` format (lowercase, hyphens, 64 chars). Nothing guides what makes a good name, even though choosing the name is an explicit output of Phase 3/4.

## Problem / opportunity

The platform best-practices doc (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices, "Naming conventions", fetched 2026-07-04) provides concrete guidance the skill omits:

- Recommended: **gerund form** (verb + -ing) — `processing-pdfs`, `analyzing-spreadsheets`, `testing-code` — "as this clearly describes the activity or capability".
- Acceptable alternatives: noun phrases (`pdf-processing`) and action-oriented names (`process-pdfs`).
- Avoid: vague names (`helper`, `utils`, `tools`), overly generic names (`documents`, `data`, `files`), and inconsistent patterns within a skill collection.
- Reserved words: the platform validation rules bar "anthropic" and "claude" in skill names (also "no XML tags"). Note when adopting this: it is a platform/claude.ai validation rule, and Claude Code's own bundled `claude-api` skill shows Claude Code does not enforce it — present it as a portability consideration.

Two Claude Code-specific facts belong in the same section (https://code.claude.com/docs/en/skills, fetched 2026-07-04): the **directory name** is what users type after `/`, so it should be comfortable to type and unambiguous; and a project skill named identically to a bundled or personal skill overrides/shadows it ("A skill at any of these levels also overrides a bundled skill with the same name", "personal overrides project"), so name collisions with existing skills should be checked in Phase 2.

## Proposed change

Add a short "Choosing the name" subsection (Phase 3 or skill-structure.md): prefer gerund or noun-phrase names describing the capability; avoid vague/generic names; keep the pattern consistent with the project's existing skills; check for collisions with bundled, personal, and plugin skills; treat the platform reserved-word rule as a portability note. The name is the `/command` users type, so optimize for that.
