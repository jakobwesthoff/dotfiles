# Tier 2 example ships per-reference-file YAML frontmatter, propagating the house convention flagged in the frontmatter todo

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-examples.md`, Tier 2 Example: api-guide, "references/endpoint-patterns.md (one spoke)" block (lines 120-128)

## Current state

The Tier 2 example presents this as the model spoke file:

```yaml
---
name: endpoint-patterns
description: Route structure, validation, and response format for REST endpoints
metadata:
  tags: api, routes, validation, response
---
```

## Problem

The sibling todo `01kwpcv8q3tah932e2njv3jye9-reference-frontmatter-house-convention.md` establishes that YAML frontmatter on reference files is a house convention with no runtime effect and no official precedent (spec defines frontmatter for SKILL.md only; Anthropic's skill-creator ships `references/schemas.md` with no frontmatter, re-verified 2026-07-04 via `gh api repos/anthropics/skills/contents/skills/skill-creator/references/schemas.md`: the file starts directly with `# JSON Schemas`).

That todo lists skill-structure.md, creation-workflow.md, and writing-principles.md as the places to fix, but not skill-examples.md. If the rule is dropped or downgraded there while this example keeps modeling the frontmatter, the skill contradicts itself: examples are the strongest instruction mechanism in this skill's own philosophy ("Code First, Prose Second"), so the example wins and generated skills keep the frontmatter.

## Grounding

- Sibling todo `01kwpcv8q3tah932e2njv3jye9` (grounded against agentskills.io/specification, Claude Code docs supporting-file examples, and anthropics/skills skill-creator, all fetched 2026-07-04).
- skill-examples.md lines 120-128 quoted above.

## Proposed change

Fix in the same pass as the reference-frontmatter todo. If the convention is dropped: remove the frontmatter block from the example and start the spoke with `# Endpoint Patterns` plus the orientation line. If it is kept as an optional house convention: label it as such inside the example so the example does not reassert it as required.
