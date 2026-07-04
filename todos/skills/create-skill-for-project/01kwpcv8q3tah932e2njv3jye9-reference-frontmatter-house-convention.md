# Mandatory YAML frontmatter on reference files is a house convention, not official guidance

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md` ("Reference File Anatomy": "Every reference file follows this internal structure: 1. **YAML frontmatter** — `name`, `description`, `tags`"); `references/creation-workflow.md` Phase 4 Step 2 and Phase 5 check ("Each reference file has YAML frontmatter (`name`, `description`, `tags`)"); `references/writing-principles.md` Pre-Ship Checklist ("Every reference file has YAML frontmatter")

## Current state

Three files present per-reference-file YAML frontmatter (`name`, `description`, `metadata.tags`) as a hard requirement, enforced by two checklists.

## Problem

No official source defines or uses frontmatter on supporting files:

- The Agent Skills specification (https://agentskills.io/specification, fetched 2026-07-04) defines frontmatter for `SKILL.md` only; `references/` files are described simply as "additional documentation that agents can read when needed".
- The Claude Code docs' supporting-file examples (`reference.md`, `examples.md`) and the platform best-practices progressive-disclosure patterns show plain markdown reference files without frontmatter (both fetched 2026-07-04).
- Anthropic's own skill-creator skill ships `references/schemas.md` starting directly with `# JSON Schemas` — no frontmatter (verified via `gh api repos/anthropics/skills/contents/skills/skill-creator/references/schemas.md` on 2026-07-04).

The frontmatter has no functional effect (nothing in Claude Code reads `name`/`description`/`tags` from non-SKILL.md files) yet costs tokens on every load of every reference file and adds checklist burden. Presenting it as required misleads authors into thinking it does something.

## Proposed change

Either drop the requirement (align with official practice: reference files are plain markdown with a clear H1 and descriptive filename) or explicitly label it an optional house convention for human maintainers, remove it from both verification checklists, and state that it has no runtime effect. The platform best-practices alternative for orienting partial reads is a table of contents at the top of long reference files (see the separate ToC todo).
