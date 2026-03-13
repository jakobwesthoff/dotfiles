---
name: creation-workflow
description: >-
  Five-phase workflow for creating a project-specific skill — from understanding
  the request through exploration, design, writing, and verification.
metadata:
  tags: workflow, creation, process, exploration, verification
---

## Overview

Creating a project-specific skill follows five phases. Each phase builds on
the previous — do not skip ahead.

1. **Understand** the request
2. **Explore** the target project
3. **Design** the skill
4. **Write** the skill files
5. **Verify** the result

---

## Phase 1: Understand the Request

Read `$ARGUMENTS` (or ask the user if empty) and identify:

- **Purpose** — What should the skill help the agent do?
- **Triggers** — What user phrases or tasks should activate it?
- **Output** — What does the skill produce? (code, documents, behavior changes, guidance)
- **Scope** — What is explicitly NOT in scope?

If the request is ambiguous, ask clarifying questions NOW. Examples:

- "Should this skill cover only React components, or all frontend code?"
- "Do you want this to generate boilerplate, or guide writing from scratch?"
- "Are there existing patterns in the codebase I should follow?"

DO NOT proceed to Phase 2 until purpose, triggers, and output are clear.

---

## Phase 2: Explore the Target Project

This is the critical phase that makes the skill project-specific. Systematically
explore the codebase to extract patterns the skill will encode.

### Exploration Checklist

**Project documentation:**
- [ ] `CLAUDE.md` — existing agent instructions, coding standards
- [ ] `README.md` — project purpose, architecture overview
- [ ] `CONTRIBUTING.md` — contribution guidelines, code standards

**Package manifests and config:**
- [ ] `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, etc.
- [ ] Key dependencies and their versions
- [ ] Build scripts and tooling

**Existing skills:**
- [ ] `.claude/skills/` — what skills already exist?
- [ ] `.claude/commands/` — any legacy commands?
- [ ] Avoid duplicating or conflicting with existing skills

**Codebase analysis (focused on the skill's domain):**
- [ ] Languages and frameworks in use
- [ ] Directory structure and naming conventions
- [ ] Import patterns and module organization
- [ ] Error handling patterns
- [ ] Testing patterns and test file locations
- [ ] Configuration patterns (env vars, config files)
- [ ] Relevant code examples from the project itself

### What to Extract

For each pattern you discover, note:
1. The **canonical example** from the codebase (file path + code snippet)
2. The **convention** it represents (naming, structure, imports)
3. Any **anti-patterns** present in the codebase that the skill should prevent

Spend enough time here. A skill with project-specific code examples and patterns
is vastly more useful than one with generic advice.

---

## Phase 3: Design the Skill

Using what you learned in Phases 1 and 2, make these design decisions:

### Choose the Archetype

| If the skill primarily... | Archetype |
|---------------------------|-----------|
| Produces files, code, or documents | **Generative** |
| Guides behavior, enforces patterns | **Knowledge** |
| Both reads and produces artifacts | **Hybrid** |

### Choose the Tier

```
Single concept, few examples?
  └─ YES → Tier 1 (single SKILL.md, <=500 lines)
  └─ NO → 3+ distinct topics?
       └─ YES → Are code examples >40 lines each?
       │    └─ YES → Tier 3 (hub + references + assets)
       │    └─ NO  → Tier 2 (hub + references)
       └─ NO → Tier 1 (probably fits in one file)
```

ALWAYS start with the simplest tier. You can upgrade later.

### Plan the File Structure

For Tier 2/3, plan which reference files you need. Each file should cover
**exactly one concept**. Draft the list:

```
my-skill/
├── SKILL.md                    # Router: 30-80 lines
├── references/
│   ├── <topic-a>.md            # ~X lines — one-line description
│   ├── <topic-b>.md            # ~X lines — one-line description
│   └── <topic-c>.md            # ~X lines — one-line description
└── assets/                     # Only if Tier 3
    └── <example>.ext
```

### Plan the Description

Draft the `description` field. It MUST include:
- Action verbs describing WHAT the skill does
- Trigger keywords matching WHEN users need it
- Keep under 200 characters for Claude.ai compatibility

---

## Phase 4: Write the Skill Files

### Step 1: Create the directory

```
.claude/skills/<skill-name>/
```

The directory name MUST match the `name` frontmatter field exactly.

### Step 2: Write reference files first (Tier 2/3)

For each reference file:

1. Add YAML frontmatter:
   ```yaml
   ---
   name: kebab-case-topic-name
   description: One-line purpose — what this covers
   metadata:
     tags: relevant, keywords
   ---
   ```

2. Follow this body structure:
   - Opening orientation (1-2 sentences)
   - Prerequisites (if any)
   - Core pattern — the "right way" with a code example **from this project**
   - Variations (if needed)
   - Anti-patterns (FORBIDDEN, NEVER, MUST NOT)

3. Use **project-specific code examples** wherever possible. Pull real import
   paths, real function names, real patterns from the codebase. Generic examples
   are a last resort.

4. Cross-reference related files with relative links.

### Step 3: Write SKILL.md last

Write it last so you can accurately reference all existing files.

1. Frontmatter:
   ```yaml
   ---
   name: <skill-name>
   description: >-
     <WHAT it does>. <WHEN to use it — trigger keywords>.
   ---
   ```

2. Body structure for a router (Tier 2/3):
   ```markdown
   ## When to use

   Use this skill when [specific triggers].

   ## Reference Files

   - [references/topic-a.md](references/topic-a.md) — One-line description
   - [references/topic-b.md](references/topic-b.md) — One-line description
   ```

3. Body structure for a single file (Tier 1):
   - Orientation, core patterns, variations, anti-patterns — all inline.

### Step 4: Write scripts/assets (if needed)

- Scripts must be self-contained executables with `--help` support
- Assets must be complete and runnable — not fragments
- Use the project's actual language, framework, and patterns

---

## Phase 5: Verify

### Structural Checks

- [ ] Directory name matches `name` frontmatter field
- [ ] `name` is lowercase alphanumeric + hyphens, max 64 chars
- [ ] `description` specifies WHAT and WHEN
- [ ] `SKILL.md` body is under 500 lines
- [ ] Each reference file has YAML frontmatter (`name`, `description`, `tags`)
- [ ] All relative links in SKILL.md resolve to existing files
- [ ] No reference file exceeds ~400 lines
- [ ] Total line count is under ~5,000 lines

### Content Checks

- [ ] Code examples use the project's actual patterns, imports, and conventions
- [ ] The "right way" appears before variations in every file
- [ ] Anti-patterns use strong language (FORBIDDEN, NEVER, MUST NOT)
- [ ] No hardcoded secrets or credentials
- [ ] No generic advice that could apply to any project — everything is specific
- [ ] Each reference file covers exactly one concept

### Functional Checks

Suggest the user test with:
1. Prompts that SHOULD trigger the skill — does the agent activate it?
2. Prompts that should NOT trigger it — does the agent leave it alone?
3. A real task in the skill's domain — does the output follow the skill's rules?

---

## Common Pitfalls

**The Monolith:** Putting everything in SKILL.md instead of using reference files.
If it exceeds ~200 lines of content, split into Tier 2.

**The Empty Router:** A SKILL.md that is just a list of links with no context.
Add a "When to use" section and brief orientation.

**Generic Content:** Using textbook examples instead of the project's own code.
Always prefer real patterns from the codebase.

**Missing Anti-Patterns:** Showing only the right way without forbidding the wrong
way. The AI will fall back to general training if not explicitly told what to avoid.

**Over-Engineering:** Starting at Tier 3 when Tier 1 would suffice. Start simple,
iterate up when the skill outgrows its tier.

**Vague Description:** Writing "Helps with testing" instead of "Run and write Vitest
unit tests. Use when the user mentions 'test', 'spec', or 'vitest'."
