# Tier 3 example claims the asset "compiles as part of the project's build pipeline" — unsourced and not something the workflow sets up

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-examples.md`, Tier 3 Example: component-library (lines 187-188)

## Current state

> The asset file (`assets/form-select.tsx`) is a complete, runnable component — not a fragment. It compiles as part of the project's build pipeline.

## Problem

The second sentence states a build-integration fact nothing establishes:

- No official source describes skill assets as participating in the host project's build. The Claude Code docs treat supporting files as material Claude reads or executes on demand; the platform best-practices doc's asset guidance is about bundling resources with "no context penalty until accessed" (both fetched 2026-07-04).
- Nothing in the skill's own workflow makes it true either: Phase 4 Step 4 says assets must be "complete and runnable — not fragments" but never instructs adding `.claude/skills/**` to a tsconfig, build glob, or CI job. A `.tsx` file under `.claude/skills/component-library/assets/` is outside a project's build inputs unless the project is configured for it, and typically it should stay outside: skill assets are reference implementations for the agent, and compiling them into the shipped artifact is not a goal any source states.

An agent following this example may either assert the same untrue property about the skill it generates or start editing the project's build configuration to make the assertion true. Both are wrong outcomes.

## Grounding

- https://code.claude.com/docs/en/skills (fetched 2026-07-04): supporting files are "templates for Claude to fill in, example outputs ... scripts Claude can execute, or detailed reference documentation"; no build-pipeline integration anywhere on the page.
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices (fetched 2026-07-04): asset/script guidance covers execution and on-demand reading only; explicit check for build-pipeline statements found none.
- Skill's own creation-workflow.md Phase 4 Step 4: no build-integration step exists.

## Proposed change

Replace the sentence with a verifiable property, e.g.: the asset is a complete, self-contained file that type-checks/compiles on its own (verify once with a one-off `tsc --noEmit` or equivalent during Phase 5), using the project's real imports and conventions. Do not claim or create project-build integration.
