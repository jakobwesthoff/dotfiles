# Tier 3 trigger "~40 lines of code" is an invented threshold presented as the decision criterion in three files

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, Tier 3 "Use when" (lines 144-145: ">40 lines of uninterrupted code") and Tier Decision Tree item 3 (line 151: "Do code examples exceed ~40 lines each? → Tier 3"); `references/creation-workflow.md`, "Choose the Tier" tree (line 103: "Are code examples >40 lines each?"); `references/skill-examples.md`, Tier 3 example (lines 190-191: "Use Tier 3 when: code examples exceed ~40 lines and must be complete, runnable files")

## Current state

All three tier-selection surfaces make "code examples exceed ~40 lines" the test for moving code out of reference files into `assets/`.

## Problem

No official source ties asset extraction to a line count (all sources fetched 2026-07-04):

- The Claude Code docs describe supporting files by role, not size: "templates for Claude to fill in, example outputs showing the expected format, scripts Claude can execute, or detailed reference documentation".
- The platform best-practices doc gives functional criteria: bundle scripts when operations are deterministic or fragile ("Prefer scripts for deterministic operations"), bundle comprehensive resources freely because there is "no context penalty until accessed". Its only numeric size guidance is the 500-line SKILL.md body figure.
- The agentskills.io spec asks only that reference files stay focused; no code-length rule.
- Anthropic's skill-creator uses a repetition heuristic for extraction (bundle a script when test runs show subagents independently rewriting it), not a length one.

This is the same defect class as the sibling size-budget todo (`01kwpcv8q3tah932e2njv3jyea`), which covers the ~400-line reference cap and the total-size caps but not the 40-line figure. Because the number sits inside both tier decision trees, it directly steers every Tier 2 vs Tier 3 choice the meta-skill makes.

## Grounding

- https://code.claude.com/docs/en/skills (fetched 2026-07-04), skill directory structure and "Add supporting files" sections.
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices (fetched 2026-07-04), "Runtime environment" bullets and "Provide utility scripts"; searched for a code-length threshold, none present.
- anthropics/skills, skills/skill-creator/SKILL.md, "Look for repeated work across test cases" (fetched 2026-07-04).

## Proposed change

Replace the line-count test with the functional criterion in all three files: move code to `assets/` when the example must be a complete, runnable file (compilable, executable, or fillable as a template) rather than an illustrative snippet, or when a script performs a deterministic operation the agent would otherwise regenerate. If a rough size cue is kept for the decision tree, label it a house heuristic ("as a rule of thumb, snippets past a few dozen lines usually want to be files"), not a threshold.
