# `context: fork` / `agent` fields documented without the official caveats

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, frontmatter example lines (`context: fork  # Optional. Run in isolated subagent context` and `agent: Explore  # Optional. Subagent type`)

## Current state

`context: fork` and `agent` appear only as two commented lines in the frontmatter example. No guidance on when forking is appropriate or what the forked skill can see.

## Problem

The official docs attach caveats that determine whether a generated skill will work at all when forked:

- Warning: "`context: fork` only makes sense for skills with explicit instructions. If your skill contains guidelines like 'use these API conventions' without a task, the subagent receives the guidelines but no actionable prompt, and returns without meaningful output." In this skill's own taxonomy, that means knowledge-archetype skills must not get `context: fork`; only task-style (generative) skills with explicit steps should.
- The forked subagent has no access to the conversation history; the skill content becomes the subagent's prompt.
- `agent` selects the execution environment (model, tools, permissions): built-in `Explore`, `Plan`, `general-purpose`, or any custom subagent from `.claude/agents/`. "If omitted, uses `general-purpose`."
- Explore and Plan skip CLAUDE.md and git status at startup, so a forked skill with `agent: Explore` sees only the SKILL.md content and the agent's system prompt — project conventions from CLAUDE.md do not apply unless restated in the skill.

Without these facts, the meta-skill can generate a knowledge skill with `context: fork` that returns nothing, or an Explore-forked skill that silently loses CLAUDE.md conventions.

## Grounding

https://code.claude.com/docs/en/skills (fetched 2026-07-04), "Run skills in a subagent" section; quotes verbatim.

## Proposed change

Add a short "Running in a subagent" subsection to skill-structure.md with the archetype rule (fork only task-style skills), the no-conversation-history and default-agent facts, and the Explore/Plan CLAUDE.md caveat. Reference it from the Phase 3 design decisions in creation-workflow.md.
