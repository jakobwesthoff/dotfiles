# Scripts guidance is thin, partly unsourced (`--help` mandate), and misses official script principles

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/creation-workflow.md`, Phase 4 Step 4 ("Scripts must be self-contained executables with `--help` support / Assets must be complete and runnable — not fragments"); `references/skill-structure.md`, Standard Directories table (`scripts/`: "Self-contained scripts with clear error messages")

## Current state

Total script guidance is three bullet points. The `--help` requirement is stated as a hard rule.

## Problem / opportunity

- **`--help` mandate is unsourced.** The agentskills.io spec (fetched 2026-07-04) asks that scripts "Be self-contained or clearly document dependencies; Include helpful error messages; Handle edge cases gracefully" — no `--help` requirement in the spec, Claude Code docs, or platform best-practices. Keep it only if relabeled a house preference.
- **Missing official principles** (platform best-practices, "Advanced: Skills with executable code", fetched 2026-07-04):
  - *Solve, don't punt*: scripts should handle error conditions themselves (create missing files, fall back to defaults) "rather than punting to Claude".
  - *No voodoo constants*: every timeout/retry/threshold gets a justifying comment — "If you don't know the right value, how will Claude determine it?"
  - *Execution intent must be explicit*: instructions must distinguish "Run `analyze_form.py` to extract fields" (execute; output only costs tokens) from "See `analyze_form.py` for the algorithm" (read as reference). Execution is preferred for deterministic operations.
  - *Why bundle scripts at all*: more reliable than generated code, save tokens and time, ensure consistency across uses. The official skill-creator adds the discovery heuristic: if test runs show subagents independently writing the same helper script, bundle it in `scripts/` (anthropics/skills, skills/skill-creator/SKILL.md, "Look for repeated work across test cases").
  - *Plan-validate-execute*: for batch or destructive operations, have the skill emit an intermediate plan file and validate it with a script before executing; make validator messages verbose and specific.
  - *MCP tool names fully qualified*: skills invoking MCP tools must use `ServerName:tool_name` ("Without the server prefix, Claude may fail to locate the tool"). Directly relevant to project skills in MCP-using repos.
- **Path robustness** (Claude Code docs): generated skills should invoke bundled scripts via `${CLAUDE_SKILL_DIR}/scripts/...` so paths resolve regardless of working directory (see also the dynamic-content todo).

## Proposed change

Expand Phase 4 Step 4 (or a small scripts section in skill-structure.md) with: solve-don't-punt, justified constants, explicit execute-vs-read intent, the repeated-work bundling heuristic, plan-validate-execute for risky batch operations, fully qualified MCP tool names, and `${CLAUDE_SKILL_DIR}`-based invocation. Downgrade `--help` from requirement to house preference or replace it with the spec's actual asks (documented dependencies, helpful errors, graceful edge cases).
