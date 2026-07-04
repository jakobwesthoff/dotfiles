# Size-budget tables mix official limits with invented numbers presented as authoritative

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, "Size Budgets" table; `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/writing-principles.md`, "Sizing Guidelines" table and Pre-Ship Checklist ("Total skill stays under ~3,000-5,000 lines"); `references/creation-workflow.md` Phase 5 ("No reference file exceeds ~400 lines", "Total line count is under ~5,000 lines")

## Current state

Both tables state: SKILL.md body 30-80 lines (max 500); single reference file 50-200 lines (max ~400); total across all files 1,500-3,000 lines (max ~5,000). Checklists enforce the ~400 and ~5,000 figures.

## Problem

Only some of these numbers trace to official guidance (all sources fetched 2026-07-04):

- **Grounded**: "Keep SKILL.md under 500 lines" (Claude Code docs tip, agentskills.io spec, platform best-practices "Keep SKILL.md body under 500 lines for optimal performance"). "Instructions < 5,000 tokens recommended" for the SKILL.md body (agentskills.io spec).
- **Ungrounded**: the ~400-line reference-file max, the 1,500-3,000-line total target, and the ~5,000-line total max appear in no official source. The spec says only "Keep individual reference files focused. Agents load these on demand, so smaller files mean less use of context", and the platform best-practices doc says the opposite of a total cap: "Bundle comprehensive resources: Include complete API docs, extensive examples, large datasets; no context penalty until accessed."

The invented total-size cap actively contradicts official guidance: since resources load on demand, a large `references/` corpus is officially fine, and the platform's Pattern 2 (domain-specific organization) exists precisely for large multi-domain reference sets. "Split into multiple skills if exceeded" (Sizing Guidelines rationale column) is likewise unsourced.

## Proposed change

Keep the two official numbers (500-line SKILL.md, <5k-token body) with their status as official recommendations. For reference files, replace the line caps with the official principles: keep each file focused on one domain so only relevant content loads; bundled resources have no context cost until read, so total skill size needs no cap. If the author wants house target ranges, label them explicitly as house preferences, not limits, and drop them from the pass/fail checklists.
