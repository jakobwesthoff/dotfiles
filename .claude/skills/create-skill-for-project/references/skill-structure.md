---
name: skill-structure
description: >-
  Architectural reference for Claude Code skill structure — discovery, frontmatter,
  tiers, progressive disclosure, and size budgets.
metadata:
  tags: architecture, structure, tiers, frontmatter, progressive-disclosure
---

## How Skills Work

A skill is a directory containing a `SKILL.md` file. Claude Code discovers skills
from these locations:

| Scope | Path | Visibility |
|-------|------|------------|
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |

When activated, Claude loads the `SKILL.md` into its context window. Everything
that file links to via relative markdown links is available for lazy loading —
Claude follows links on demand to pull in additional files.

## SKILL.md Frontmatter

At minimum, provide `name` and `description`:

```yaml
---
name: my-skill                      # Required. Becomes /my-skill command
description: What this skill does   # Required. Used for auto-invocation decisions
license: MIT                        # Optional
compatibility: Requires git, node   # Optional
dependencies: python>=3.8, pandas   # Optional
disable-model-invocation: true      # Optional. Manual /name only (no auto-trigger)
user-invocable: false               # Optional. Hidden from menu (Claude-only)
allowed-tools: Read Grep Bash(bun:*)  # Optional. Space-delimited pre-approved tools
context: fork                       # Optional. Run in isolated subagent context
agent: Explore                      # Optional. Subagent type
argument-hint: "[issue-number]"     # Optional. Autocomplete hint for arguments
metadata:
  author: my-org
  version: "1.0"
  tags: keyword1, keyword2
---
```

### Field Constraints

| Field | Required | Constraints |
|-------|:--------:|-------------|
| `name` | Yes | Max 64 chars. Lowercase alphanumeric + hyphens only. Must match directory name. No leading/trailing/consecutive hyphens. |
| `description` | Yes | Max 1024 chars (spec), **200 chars for Claude.ai**. Describe WHAT it does AND WHEN to use it. Include trigger keywords. |
| `license` | No | License name or reference to bundled license file. |
| `compatibility` | No | Max 500 chars. Environment requirements. |
| `dependencies` | No | Packages the agent can install (PyPI, npm). |
| `allowed-tools` | No | Space-delimited pre-approved tools. |
| `metadata` | No | Arbitrary string key-value mapping. |

### Dynamic Content

| Variable | Resolves to |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed at invocation |
| `$ARGUMENTS[N]` or `$N` | Specific argument by index (0-based) |
| `` !`command` `` | Output of a shell command, injected before the agent sees the skill |

### Description as Trigger Mechanism

The `description` field is loaded for ALL installed skills on every interaction.
It is how the agent decides which skill matches the current task.

A good description includes **what** the skill does and **when** to use it:

```yaml
# Good — specific triggers and keywords
description: >-
  Create, read, edit, and manipulate Word documents (.docx files). Use when
  the user mentions "Word doc", ".docx", or requests professional documents.

# Bad — too vague to trigger reliably
description: Helps with documents.
```

Include the exact terms users are likely to say so the agent can match on them.

## Skill Archetypes

### Generative Skills
Produce artifacts (files, documents, code). Structure emphasizes templates,
QA/verification workflows, and output format specifications.

### Knowledge Skills
Shape the agent's behavior without producing specific artifacts. Structure
emphasizes decision trees, anti-patterns, and reference material loaded on demand.

### Hybrid Skills
Both read and produce artifacts (e.g., a PDF skill that extracts text AND fills
forms, or a meta-skill that reads a project and generates a new skill).

## Standard Directories

| Directory | Purpose | Contents |
|-----------|---------|----------|
| `scripts/` | Executable code the agent can run | Self-contained scripts with clear error messages |
| `references/` | Additional docs loaded on demand | Domain-specific guides, templates. Keep files focused. |
| `assets/` | Static resources | Templates, images, data files, schemas, runnable code examples |

These are conventions, not requirements. Use whichever directories fit the domain.

## Architectural Tiers

Choose the **simplest tier** that fits.

### Tier 1: Single-File Skill
```
my-skill/
└── SKILL.md          # Everything in one file (<=500 lines)
```
**Use when:** the skill covers a single concept with a handful of code examples.

### Tier 2: Hub-and-Spokes
```
my-skill/
├── SKILL.md          # Router/index (30-80 lines)
├── references/       # Topic files (50-200 lines each)
│   ├── topic-a.md
│   └── topic-b.md
└── scripts/          # Optional executable scripts
```
**Use when:** the domain has 3+ distinct topics that would exceed ~200 lines combined.

### Tier 3: Hub-and-Spokes with Code Assets
```
my-skill/
├── SKILL.md
├── references/
│   ├── topic-a.md
│   └── topic-b.md
└── assets/           # Complete, runnable reference implementations
    ├── example-a.tsx
    └── example-b.tsx
```
**Use when:** the domain requires complete reference implementations that would
overwhelm a reference file (>40 lines of uninterrupted code).

### Tier Decision Tree

1. Does the skill cover a single concept with few examples? → **Tier 1**
2. Does the domain have 3+ distinct topics? → **Tier 2**
3. Do code examples exceed ~40 lines each? → **Tier 3**

## Progressive Disclosure

Skills load information in layers so the agent only pays context cost for what
it actually needs:

```
Layer 1: Metadata (~100 tokens)
    │     name + description loaded at startup for ALL installed skills
    ▼
Layer 2: Instructions (<5,000 tokens recommended)
    │     Full SKILL.md body loaded when activated — keep it lean
    ▼
Layer 3: Resources (as needed)
          Files in references/, scripts/, assets/ loaded only
          when the agent follows a link from SKILL.md
```

### Size Budgets

| Layer | Target | Max |
|-------|--------|-----|
| `description` field | 1-2 sentences | 1024 chars (200 for Claude.ai) |
| `SKILL.md` body | 30-80 lines | 500 lines |
| Single reference file | 50-200 lines | ~400 lines |
| Total across all files | 1,500-3,000 lines | ~5,000 lines |

### File Reference Depth

Keep references **one level deep** from `SKILL.md`. The agent should reach any
information in at most two hops: `SKILL.md` -> reference file -> asset (if needed).

## Reference File Anatomy

Every reference file follows this internal structure:

1. **YAML frontmatter** — `name`, `description`, `tags`
2. **Opening orientation** — 1-2 sentences: what and when
3. **Prerequisites** (optional) — install commands, dependencies
4. **Core pattern** — the primary "right way" example
5. **Variations** (optional) — additional use cases, each with own heading
6. **Anti-patterns** (optional) — FORBIDDEN / NEVER / MUST NOT

The core pattern appears early — the agent encounters the correct approach before
any alternatives.

## Template Pattern

For generative skills producing complex output, provide a template file. Mark
which parts are fixed and which are variable:

```
<!-- === FIXED: Do not modify === -->
<script src="https://cdn.example.com/lib.js"></script>
<!-- === END FIXED === -->

<!-- === VARIABLE: Replace with generated content === -->
<div id="content"><!-- Agent fills this in --></div>
<!-- === END VARIABLE === -->
```

Instruct the agent to read the template FIRST, keep FIXED sections unchanged,
and replace only VARIABLE sections.
