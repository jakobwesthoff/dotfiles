# "Description loaded for ALL installed skills" is inaccurate, and invocation control is missing from the design phase

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md` ("Description as Trigger Mechanism": "The `description` field is loaded for ALL installed skills on every interaction."; Progressive Disclosure Layer 1: "name + description loaded at startup for ALL installed skills"); `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/writing-principles.md` ("The `description` field is loaded for ALL installed skills on every interaction."); `references/creation-workflow.md` Phase 3 (no invocation-control decision)

## Current state

Three places state descriptions of all installed skills are always in context. The frontmatter table lists `disable-model-invocation` and `user-invocable` but the design workflow (Phase 3) never asks which invocation mode the new skill needs, and no file explains the context-loading consequences.

## Problem

Per the official docs the "ALL skills" claim has exceptions that matter for context budgeting and triggering:

| Frontmatter | You can invoke | Claude can invoke | Context loading |
|---|---|---|---|
| (default) | Yes | Yes | Description always in context; full skill on invocation |
| `disable-model-invocation: true` | Yes | No | **Description not in context**; full skill loads when you invoke |
| `user-invocable: false` | No | Yes | Description always in context; full skill on invocation |

So a `disable-model-invocation: true` skill costs zero listing tokens and cannot auto-trigger, which is the officially recommended mode for side-effect workflows: "Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`... You don't want Claude deciding to deploy because your code looks ready." Conversely `user-invocable: false` is for "background knowledge that isn't actionable as a command". The docs also frame content types along the same axis (reference content vs task content).

This is a design decision the meta-skill should force in Phase 3: who invokes the new skill? The answer changes how much trigger-keyword engineering the description needs (a manual-only skill's description never participates in auto-trigger matching).

## Grounding

https://code.claude.com/docs/en/skills (fetched 2026-07-04), "Control who invokes a skill" (table and quotes verbatim) and "Types of skill content" sections.

## Proposed change

- Correct the three "ALL installed skills" statements to "all skills that allow model invocation (`disable-model-invocation` not set)".
- Add the three-row invocation table to skill-structure.md.
- Add a Phase 3 design decision to creation-workflow.md: choose default / user-only (`disable-model-invocation: true`, recommended for side-effect workflows) / model-only (`user-invocable: false`, for background knowledge), and note the description-token consequence.
