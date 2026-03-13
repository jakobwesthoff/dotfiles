---
name: create-skill-for-project
description: >-
  Create a new Claude Code skill tailored to a specific project. Use when the
  user wants to "create a skill", "new skill", or add a custom /command for
  their codebase. Analyzes the project first, then builds a complete skill.
---

You are creating a Claude Code skill tailored to this specific project.

**Task:** $ARGUMENTS

If no task was provided above (empty or blank), ask the user what skill they
want to create before proceeding.

## Workflow

Follow these five phases in order. Do not skip phases.

### Phase 1: Understand the Request

Identify the skill's purpose, triggers, expected output, and scope boundaries.
Ask clarifying questions if the request is ambiguous.

### Phase 2: Explore the Target Project

Read the project's documentation (`CLAUDE.md`, `README.md`, package manifests),
existing skills (`.claude/skills/`), and codebase patterns relevant to the
skill's domain. Extract real code examples, import paths, naming conventions,
and anti-patterns.

> **Read [references/creation-workflow.md](references/creation-workflow.md)** for the
> full exploration checklist. This is the most important phase — a project-specific
> skill is only as good as the project knowledge baked into it.

### Phase 3: Design the Skill

Choose the archetype (generative / knowledge / hybrid) and the simplest
architectural tier that fits. Plan the file structure and draft the description.

> **Read [references/skill-structure.md](references/skill-structure.md)** for
> archetypes, tier decision tree, frontmatter fields, and size budgets.

### Phase 4: Write the Skill Files

Create the skill directory at `.claude/skills/<name>/`. Write reference files
first, then SKILL.md last so it accurately links to all files. Use
project-specific code examples — not generic textbook patterns.

> **Read [references/writing-principles.md](references/writing-principles.md)** for
> prescriptive style, code-first approach, anti-pattern formatting, and the
> pre-ship checklist.

### Phase 5: Verify

Run through structural, content, and functional checks. Suggest test prompts
to the user.

> **Read [references/creation-workflow.md](references/creation-workflow.md)** (Phase 5
> section) for the full verification checklist.

## Critical Rules

- Create the skill in `.claude/skills/<name>/` — NEVER at the project root
- Directory name MUST match the `name` frontmatter field exactly
- Start with the simplest tier (Tier 1) unless the domain clearly needs more
- Use the project's real code patterns, not generic examples
- Include anti-patterns with strong language (FORBIDDEN, NEVER, MUST NOT)
- Keep `description` under 200 characters with WHAT + WHEN trigger keywords

## Reference Files

- [references/skill-structure.md](references/skill-structure.md) — Architecture: frontmatter, tiers, progressive disclosure, size budgets
- [references/writing-principles.md](references/writing-principles.md) — Writing guide: prescriptive style, code-first, anti-patterns, checklist
- [references/creation-workflow.md](references/creation-workflow.md) — Five-phase workflow: understand, explore, design, write, verify
- [references/skill-examples.md](references/skill-examples.md) — Concrete examples at each tier, good/bad patterns, anti-pattern catalog
