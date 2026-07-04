# The skill's own description is 223 characters, violating its own under-200 rule

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/SKILL.md`, frontmatter `description` and Critical Rules bullet "Keep `description` under 200 characters with WHAT + WHEN trigger keywords"

## Current state

The frontmatter description reads:

> Create a new Claude Code skill tailored to a specific project. Use when the user wants to "create a skill", "new skill", or add a custom /command for their codebase. Analyzes the project first, then builds a complete skill.

## Problem

Measured length is 223 characters (`python3 -c 'print(len(...))'` on 2026-07-04 → `223`), so the skill violates the very rule it declares as critical. A meta-skill teaching skill authoring loses credibility when its own frontmatter fails its checklist, and an agent following the skill may notice the contradiction and treat the rule as optional.

## Resolution depends on a sibling todo

The companion todo `01kwpcv8q3tah932e2njv3jye3-description-length-guidance-conflates-products.md` establishes that the under-200 rule itself is wrong for Claude Code skills (200 chars is a claude.ai upload limit; Claude Code truncates combined `description` + `when_to_use` at 1,536 chars and the spec allows 1024). Fix the rule first; then this description is compliant as-is (223 < 1024) and only the internal inconsistency disappears. If the 200-char rule is instead kept for claude.ai portability, the description must be shortened.

## Grounding

- Character count: command output above.
- Limits: https://agentskills.io/specification (1-1024 chars), https://code.claude.com/docs/en/skills (1,536-char combined truncation), https://support.claude.com/en/articles/12512198 (200 chars, claude.ai uploads), all fetched 2026-07-04.

## Proposed change

Resolve together with the description-length todo so rule and frontmatter agree. Whichever limit is adopted, verify the description against it as part of the fix.
