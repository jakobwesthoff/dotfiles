# "Bad — too long" description example propagates the corrected length rule and punishes officially recommended trigger coverage

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-examples.md`, "Good vs Bad Descriptions", "Bad — too long (wastes tokens on every interaction)" block (lines 244-252)

## Current state

The section labels this description bad solely for its length:

> **Bad — too long (wastes tokens on every interaction):**
> "This skill helps you generate TypeScript API clients from OpenAPI specifications. It supports OpenAPI 3.0 and 3.1, handles complex nested types, generates both request and response types, creates fetch-based client functions with proper error handling, and can also generate React Query hooks for each endpoint. Use this whenever you need to interact with a REST API that has an OpenAPI spec."

Measured length: 392 characters (`python3` on the folded scalar, 2026-07-04).

## Problem

Under the corrections already filed, the example's verdict is wrong on both counts:

1. **Length**: 392 chars is well inside every limit that applies to a Claude Code project skill: the spec's 1024-char maximum and Claude Code's 1,536-char combined `description` + `when_to_use` truncation (see sibling todo `01kwpcv8q3tah932e2njv3jye3`). The parenthetical "wastes tokens on every interaction" restates the token-cost framing the sibling todo replaces.
2. **Content**: the closing sentence ("Use this whenever you need to interact with a REST API that has an OpenAPI spec") is exactly the broad, "pushy" trigger phrasing the official skill-creator recommends to combat undertriggering (see sibling todo `01kwpcv8q3tah932e2njv3jyej`). The example teaches authors to delete it.

Real weaknesses the example could illustrate instead go unmentioned: the key use case is not first (Claude Code truncates the tail, and the docs say "Put the key use case first"), and the feature enumeration ("supports OpenAPI 3.0 and 3.1, handles complex nested types...") adds capability detail that belongs in the body, not trigger signal.

Todo `01kwpcv8q3tah932e2njv3jye3` fixes the rule in SKILL.md, skill-structure.md, writing-principles.md, and creation-workflow.md but does not list skill-examples.md, so this example would survive the fix and re-teach the removed rule.

## Grounding

- https://code.claude.com/docs/en/skills (fetched 2026-07-04): `description` row ("Put the key use case first: the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing").
- anthropics/skills, skills/skill-creator/SKILL.md line 67 (fetched 2026-07-04): "make the skill descriptions a little bit 'pushy'".
- Character count: command output above.

## Proposed change

Rework the example in the same pass as the description-length todo. Either relabel it around the real defects (key use case buried, capability detail crowding out trigger phrases) or replace it with an example that is genuinely bad under current rules, e.g. one that exceeds the 1,536-char truncation with the use case at the end, or one written in first person ("I can help you...", the platform best-practices anti-example). Keep the pushy trigger sentence out of the "bad" side.
