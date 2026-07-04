# Description length guidance conflates a claude.ai upload limit with Claude Code behavior

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/SKILL.md` (Critical Rules: "Keep `description` under 200 characters with WHAT + WHEN trigger keywords"); `references/skill-structure.md` (Field Constraints: "Max 1024 chars (spec), **200 chars for Claude.ai**"; Size Budgets table); `references/writing-principles.md` ("Keep descriptions under 200 characters for Claude.ai compatibility"); `references/creation-workflow.md` Phase 3 ("Keep under 200 characters for Claude.ai compatibility")

## Current state

The skill imposes a blanket under-200-characters rule on descriptions, justified by "Claude.ai compatibility". The 1024-char spec limit is mentioned only in one table.

## Problem

The skill creates **Claude Code project skills** (it writes to `.claude/skills/<name>/`), and Claude Code's actual behavior is different:

- The 200-character description limit is real but applies to skills uploaded to the claude.ai web app (Claude Help Center, "How to create custom skills", https://support.claude.com/en/articles/12512198: description "200 characters maximum"). A project skill in a git repo is never uploaded there.
- In Claude Code, the combined `description` + `when_to_use` text is truncated at 1,536 characters in the skill listing, with the guidance "Put the key use case first". The cap is configurable via `skillListingMaxDescChars`.
- Separately, the whole skill listing has a character budget scaling at 1% of the model's context window; when it overflows, descriptions of least-used skills are shortened or dropped first. `/doctor` reports affected skills.
- The Agent Skills spec limit is 1-1024 characters.
- The official skill-creator skill actively recommends *longer*, "pushy" descriptions to combat undertriggering (see the separate todo on trigger-strength guidance) — a 200-char ceiling works against that.

Squeezing every description under 200 chars sacrifices trigger keywords for a constraint that doesn't apply to the artifact being produced.

## Grounding

- https://code.claude.com/docs/en/skills (fetched 2026-07-04): frontmatter reference (`description`, `when_to_use` rows), "Skill descriptions are cut short" troubleshooting section.
- https://agentskills.io/specification (fetched 2026-07-04): description 1-1024 chars.
- https://support.claude.com/en/articles/12512198 (fetched 2026-07-04): 200-char limit for claude.ai custom skills.

## Proposed change

Replace the blanket 200-char rule with: front-load the key use case in the first sentence; stay within the spec's 1024 chars; know that Claude Code truncates combined `description` + `when_to_use` at 1,536 chars and shortens listings under context pressure. Mention the 200-char figure only as a claude.ai-upload constraint for skills intended to be shared there. Update all four files listed above consistently.
