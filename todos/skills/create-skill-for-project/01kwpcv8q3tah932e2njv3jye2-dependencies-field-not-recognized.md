# `dependencies` frontmatter field does not exist in any current official source

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, frontmatter example (`dependencies: python>=3.8, pandas   # Optional`) and Field Constraints table row (`dependencies` — "Packages the agent can install (PyPI, npm).")

## Current state

The skill documents `dependencies` as an optional frontmatter field for declaring installable packages.

## Problem

No current official source defines a `dependencies` frontmatter field:

- The Agent Skills specification (https://agentskills.io/specification, fetched 2026-07-04) defines exactly these fields: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. No `dependencies`.
- The Claude Code frontmatter reference (https://code.claude.com/docs/en/skills, fetched 2026-07-04) does not list it.
- The platform skill-authoring best-practices page (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices, fetched 2026-07-04) handles dependencies in prose: "List required packages in your SKILL.md", i.e. in the body, not frontmatter.
- The spec's `compatibility` field (max 500 chars) is the sanctioned place for environment requirements: "Can indicate intended product, required system packages, network access needs, etc.", with the note "Most skills do not need the `compatibility` field."

A generated skill carrying a `dependencies` field would have it silently ignored, while its author believes packages are declared.

## Proposed change

Remove the `dependencies` row and example line. Where dependency handling is needed, instruct authors to list install commands in the SKILL.md body or a Prerequisites section (matching the platform best-practices guidance) and to use `compatibility` only for genuine environment requirements, noting most skills don't need it.
