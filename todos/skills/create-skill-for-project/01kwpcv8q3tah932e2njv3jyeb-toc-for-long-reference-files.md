# Missing official guidance: table of contents for long reference files (partial-read mitigation)

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, "Reference File Anatomy" section (defines internal structure: frontmatter, orientation, prerequisites, core pattern, variations, anti-patterns)

## Current state

The prescribed reference-file anatomy contains no table-of-contents guidance, and no file in the skill explains why partial reads make one necessary.

## Problem / opportunity

The platform best-practices doc (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices, fetched 2026-07-04) gives a concrete, grounded rule the skill omits:

- "For reference files longer than 100 lines, include a table of contents at the top. This ensures Claude can see the full scope of available information even when previewing with partial reads."
- Rationale from the same doc: "When encountering nested references, Claude might use commands like `head -100` to preview content rather than reading entire files, resulting in incomplete information."

Anthropic's skill-creator skill states the same pattern with a different threshold: "For large reference files (>300 lines), include a table of contents" (skills/skill-creator/SKILL.md in anthropics/skills, fetched 2026-07-04).

Since the reviewed skill targets 50-200-line reference files, many generated files cross the 100-line threshold, so this is directly applicable to nearly every Tier 2/3 skill it produces. The ToC also delivers what the (unofficial) per-file YAML frontmatter tries to: quick orientation on partial read — see the sibling todo on reference-file frontmatter.

## Proposed change

Add to the Reference File Anatomy: reference files longer than ~100 lines start with a short table of contents listing their sections, so partial reads still reveal the file's full scope. Add a corresponding line to the Phase 5 content checks and the Pre-Ship Checklist.
