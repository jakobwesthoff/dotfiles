# Internal inconsistency: Tier 1 allows 500 lines but the Monolith pitfall demands splitting at ~200

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md` ("Tier 1: Single-File Skill ... Everything in one file (<=500 lines)"); `references/creation-workflow.md` ("Choose the Tier" tree: "Tier 1 (single SKILL.md, <=500 lines)"; Common Pitfalls, The Monolith: "If it exceeds ~200 lines of content, split into Tier 2"); tier decision tree in skill-structure.md ("3+ distinct topics that would exceed ~200 lines combined")

## Current state

Three thresholds coexist for the same decision:

- Tier 1 is defined as a single file up to 500 lines (both files).
- The Monolith pitfall says to split into Tier 2 above ~200 lines of content.
- The Tier 2 trigger is "3+ distinct topics that would exceed ~200 lines combined".

## Problem

An agent following the workflow gets contradictory instructions for a 250-line single-topic skill: Tier 1 by definition (<=500), but "split into Tier 2" by the pitfall (>200). The pitfall also drops the "3+ distinct topics" condition, making line count alone the trigger, while the decision tree makes topic count primary. This is exactly the kind of ambiguity an LLM resolves arbitrarily.

For calibration, official guidance uses a single number and a single condition (fetched 2026-07-04): "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files" (Claude Code docs tip; same 500-line figure in the agentskills.io spec and platform best-practices), and split when approaching that limit (platform: "Split content into separate files when approaching this limit"). Official guidance has no 200-line split point.

## Proposed change

Pick one consistent rule and state it in both files. Aligned with official guidance: split when SKILL.md approaches 500 lines, or earlier when the content has 3+ distinct topics that load independently (the progressive-disclosure motive). Rewrite the Monolith pitfall to use the same condition instead of the bare ~200-line threshold, or explicitly label ~200 lines as the house preference for when splitting starts to pay off, subordinate to the topic-count criterion.
