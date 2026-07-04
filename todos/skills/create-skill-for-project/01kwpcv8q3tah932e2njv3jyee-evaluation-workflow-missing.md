# Phase 5 verification lacks the official evaluation loop (baselines, fresh sessions, evals, live reload)

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/creation-workflow.md`, "Phase 5: Verify" (Functional Checks: "Suggest the user test with: 1. Prompts that SHOULD trigger... 2. Prompts that should NOT trigger... 3. A real task in the skill's domain"); `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/SKILL.md` Phase 5 ("Run through structural, content, and functional checks. Suggest test prompts to the user.")

## Current state

Verification ends at static checklists plus suggesting test prompts. No baseline comparison, no eval artifacts, no iteration loop, no mention of tooling.

## Problem / opportunity

Current official guidance treats evaluation as the core of skill development, not an afterthought (all sources fetched 2026-07-04):

- **Baseline comparison in fresh sessions** (Claude Code docs, "Evaluate and iterate on a skill"): "Collect a few realistic prompts, run each one in a fresh session with the skill available and again with it disabled, and compare the results. A fresh session matters because leftover context from authoring the skill will mask gaps in the written instructions." Also: "Seeing a skill trigger tells you Claude found it, not that it did what you intended" — measure triggering and output quality separately.
- **Evaluation-first development** (platform best-practices): "Create evaluations BEFORE writing extensive documentation"; establish a baseline without the skill; write minimal instructions to pass; iterate. Checklist requires "At least three evaluations created."
- **Tooling** (Claude Code docs): the skill-creator plugin (`/plugin install skill-creator@claude-plugins-official`) automates the loop — test cases in `evals/evals.json` inside the skill directory, isolated subagent runs, grading to `grading.json`, with-skill vs without-skill benchmark, blind A/B version comparison, and description tuning (should-trigger / should-not-trigger hit rate).
- **Trigger-test quality** (official skill-creator, anthropics/skills): "Claude only consults skills for tasks it can't easily handle on its own — simple, one-step queries like 'read this PDF' may not trigger a skill even if the description matches perfectly." So the Phase 5 "prompts that SHOULD trigger" must be substantive multi-step requests; the doc also wants realistic prompts with concrete detail (file names, typos, casual phrasing), and near-miss negatives rather than obviously irrelevant ones.
- **Live reload** (Claude Code docs): edits under `~/.claude/skills/` or the project `.claude/skills/` "take effect within the current session without restarting"; only a top-level skills directory created mid-session needs a restart. The generated skill can be smoke-tested immediately; only triggering must be checked in a fresh session.
- **Spec validation**: `skills-ref validate ./my-skill` checks frontmatter validity and naming conventions (agentskills.io/specification, "Validation" section) — a mechanical complement to the structural checklist.

## Proposed change

Upgrade Phase 5 into a short evaluation protocol: (1) run `skills-ref validate` if available, plus the existing structural checks; (2) instruct that trigger testing happens in a fresh session against a disabled-skill baseline; (3) require test prompts to be substantive and realistic, with near-miss negatives; (4) offer the skill-creator plugin for a measured eval loop on skills worth the investment, storing cases in `evals/evals.json`; (5) note live reload so the user knows no restart is needed. Optionally move "draft 2-3 eval prompts" earlier (Phase 1/3) to align with evaluation-first development.
