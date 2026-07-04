# Missing: skill content lifecycle (persists across turns; compaction budgets) as the grounding for "keep it lean"

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, "How Skills Work" ("When activated, Claude loads the `SKILL.md` into its context window.") and "Progressive Disclosure" ("Full SKILL.md body loaded when activated — keep it lean")

## Current state

The skill describes loading as a one-time event and justifies leanness only via the load itself. Nothing covers what happens after activation.

## Problem / opportunity

The Claude Code docs ("Skill content lifecycle", fetched 2026-07-04) document behavior that changes how skill bodies should be written:

- "The rendered `SKILL.md` content enters the conversation as a single message and stays there for the rest of the session. Claude Code does not re-read the skill file on later turns, so write guidance that should apply throughout a task as standing instructions rather than one-time steps."
- Conciseness rationale: "Once a skill loads, its content stays in context across turns, so every line is a recurring token cost."
- Compaction: auto-compaction re-attaches the most recent invocation of each skill, "keeping the first 5,000 tokens of each", with a combined budget of 25,000 tokens filled from the most recently invoked skill; older skills can drop entirely after compaction.
- Debugging note: if a skill "seems to stop influencing behavior", the content is usually still present and the model is choosing other approaches; the fixes are a stronger description/instructions or hooks for deterministic enforcement.

Two concrete authoring consequences for generated skills: (a) durable rules belong in standing-instruction form, not "first do X" phrasing that reads as a one-shot step; (b) the most important rules should sit in the first ~5,000 tokens of SKILL.md so they survive compaction.

## Proposed change

Add a short "After activation" note to skill-structure.md with the persists-across-turns fact, the standing-instructions phrasing rule, and the 5,000/25,000-token compaction budgets (front-load critical rules). Link it from the Progressive Disclosure section as the concrete reason behind "keep it lean".
