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
| Enterprise | Managed settings location | All users in the organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Namespaced as `plugin-name:skill-name`; cannot conflict with other levels |

Project skills also load from `.claude/skills/` directories in parent
directories up to the repo root, and on demand from subdirectories whose
files Claude touches — this is what gives monorepos per-package skills. A
name clash between nested skills is resolved with a directory-qualified name
such as `apps/web:deploy`.

### Skill Discovery and Precedence

Enterprise overrides personal, and personal overrides project. A skill at
any of these levels also overrides a bundled skill with the same name. This
matters when deciding where to create a new skill: a project skill that
happens to share a name with a personal or plugin skill is shadowed by it.

A `<skill-name>` entry may be a symlink to a directory elsewhere on disk;
Claude Code follows it like any other skill directory.

Custom commands have been merged into skills: a command file at
`.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md`
both create `/deploy`, and commands support the same frontmatter as skills.
If a skill and a command share a name, the skill wins.

When activated, Claude loads the `SKILL.md` into its context window. Everything
that file links to via relative markdown links is available for lazy loading —
Claude follows links on demand to pull in additional files.

## SKILL.md Frontmatter

All fields are optional in Claude Code; only `description` is recommended. The
`/command` name comes from where the skill file lives — the directory name for
a project or personal skill — not from the `name` field. Still set `name` equal
to the directory name: the Agent Skills open standard (agentskills.io) requires
that match for portability, even though Claude Code itself only uses `name` as
a display label in skill listings (defaulting to the directory name if
omitted).

```yaml
---
name: my-skill                       # Optional. Display label; defaults to directory name
description: What this skill does    # Recommended. Used for auto-invocation decisions
when_to_use: Additional trigger context appended to description  # Optional
license: MIT                         # Optional
compatibility: Requires git, node    # Optional
disable-model-invocation: true       # Optional. Manual /name only (no auto-trigger)
user-invocable: false                # Optional. Hidden from menu (Claude-only)
allowed-tools: Bash(git add *) Bash(git commit *)  # Optional. Pre-approved tools (grant, not restriction)
disallowed-tools: Bash(rm *)         # Optional. Removed from the pool while the skill is active
context: fork                        # Optional. Run in isolated subagent context
agent: Explore                       # Optional. Subagent type
model: inherit                       # Optional. Model override while the skill is active
effort: high                         # Optional. low | medium | high | xhigh | max
argument-hint: "[issue-number]"      # Optional. Autocomplete hint for arguments
arguments: issue-number priority     # Optional. Named positional args for $name substitution
paths: "src/frontend/**"             # Optional. Glob limiting automatic activation
shell: bash                          # Optional. bash (default) or powershell for !`command`
hooks:                               # Optional. Hooks scoped to the skill's lifecycle
  ...
metadata:
  author: my-org
  version: "1.0"
  tags: keyword1, keyword2
---
```

If `description` is omitted, Claude Code uses the first paragraph of the
skill's markdown body instead.

### Field Constraints

| Field | Required | Constraints |
|-------|:--------:|-------------|
| `name` | No | Display name shown in skill listings; defaults to the directory name. The Agent Skills spec (not Claude Code) requires it, max 64 chars, lowercase alphanumeric + hyphens, matching the directory name, no leading/trailing/consecutive hyphens — worth following for portability. |
| `description` | Recommended | Max 1024 chars (spec), **200 chars for Claude.ai**. Describe WHAT it does AND WHEN to use it. Include trigger keywords. Falls back to the body's first paragraph if omitted. |
| `when_to_use` | No | Additional trigger context, appended to `description` in the skill listing. Counts toward the combined 1,536-character cap. |
| `license` | No | License name or reference to bundled license file. |
| `compatibility` | No | Max 500 chars. Environment requirements (intended product, required system packages, network access needs). Most skills do not need this field. |
| `allowed-tools` | No | Pre-approves the listed tools while the skill is active. Does not restrict — every other tool remains callable per normal permission settings. Accepts a space- or comma-separated string, or a YAML list. See "allowed-tools semantics" below. |
| `disallowed-tools` | No | Removes the listed tools from Claude's available pool while the skill is active. Restriction clears on the next user message. The counterpart to `allowed-tools`. |
| `model` | No | Model override while the skill is active, for the rest of the turn. Accepts `/model` values or `inherit`. |
| `effort` | No | Effort-level override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `hooks` | No | Hooks scoped to the skill's lifecycle. |
| `paths` | No | Glob patterns limiting automatic activation to when Claude works with matching files. Useful for scoping a project skill to one subsystem (e.g. a frontend-only skill). |
| `shell` | No | `bash` (default) or `powershell` for `` !`command` `` execution. |
| `arguments` | No | Named positional arguments enabling `$name` substitution in the body. Space-separated string or YAML list; names map to positions in order. |
| `metadata` | No | Arbitrary string key-value mapping. |

Dependency handling has no dedicated frontmatter field. List required packages
and install commands in the SKILL.md body (a "Prerequisites" section works
well); use `compatibility` only for genuine environment requirements.

### `allowed-tools` Semantics

`allowed-tools` is a grant, not a restriction: it pre-approves the listed
tools for the duration of the skill's activation, but every other tool
remains callable and governed by the normal permission settings. To actually
limit what a skill can do, use `disallowed-tools` or a permission deny rule.

Scope Bash grants to narrow command prefixes rather than broad tool names,
e.g. `Bash(git add *)` rather than `Bash`. The space form (`Bash(git add *)`)
and the `:*` suffix form (`Bash(git add:*)`) are equivalent for a trailing
wildcard; the space form is what the permission dialog writes and what the
official docs use, so prefer it for consistency. `:*` is only recognized at
the end of a pattern — `Bash(git:* push)` treats the colon as a literal
character. Claude Code is aware of shell operators, so a rule like
`Bash(safe-cmd *)` does not grant `safe-cmd && other-cmd`; each subcommand
must match its own rule. `${CLAUDE_PROJECT_DIR}` substitution also works
inside `allowed-tools`, enabling rules like
`Bash(${CLAUDE_PROJECT_DIR}/scripts/lint.sh *)`.

For skills checked into a project's `.claude/skills/` directory,
`allowed-tools` takes effect only after the workspace trust dialog for that
folder has been accepted. Review a project skill's `allowed-tools` before
trusting the repository, since a skill can grant itself broad tool access.

### Dynamic Content

| Variable | Resolves to |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed at invocation |
| `$ARGUMENTS[N]` or `$N` | Specific argument by index (0-based) |
| `$name` | A named argument declared via the `arguments` frontmatter field; names map to argument positions in order |
| `${CLAUDE_SKILL_DIR}` | The directory containing the skill's `SKILL.md`. Use it so bundled scripts resolve regardless of the current working directory (e.g. `python3 ${CLAUDE_SKILL_DIR}/scripts/visualize.py`) |
| `${CLAUDE_PROJECT_DIR}` | The project root (v2.1.196+); also substituted inside `allowed-tools` |
| `${CLAUDE_SESSION_ID}` | The current session identifier |
| `${CLAUDE_EFFORT}` | The current effort level |
| `` !`command` `` | Output of a single shell command, injected before the agent sees the skill |
| ` ```! ` fenced block | Output of a multi-line shell script, for injection cases the single-command inline form can't express |

Any generated Tier 2/3 skill with a `scripts/` directory MUST reference those
scripts via `${CLAUDE_SKILL_DIR}` rather than a relative path, since the
skill's working directory at invocation is not guaranteed to be the skill
directory.

Notes on the substitutions above:

- If the skill body has no `$ARGUMENTS` placeholder but arguments were passed
  at invocation, Claude Code appends `ARGUMENTS: <value>` to the skill content
  instead of silently dropping them.
- Inline `` !`cmd` `` is only recognized at the start of a line or after
  whitespace; `` KEY=!`cmd` `` stays literal.

### Description as Trigger Mechanism

The `description` field is loaded for all skills that allow model invocation
(`disable-model-invocation` not set). It is how the agent decides which skill
matches the current task.

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

### Controlling Who Can Invoke a Skill

| Frontmatter | You can invoke | Claude can invoke | Context loading |
|-------------|:--------------:|:------------------:|------------------|
| (default) | Yes | Yes | Description always in context; full skill loads on invocation |
| `disable-model-invocation: true` | Yes | No | Description not in context; full skill loads when you invoke |
| `user-invocable: false` | No | Yes | Description always in context; full skill loads on invocation |

`disable-model-invocation: true` costs zero listing tokens and never
auto-triggers. It is the recommended mode for workflows with side effects or
whose timing you want to control (e.g. `/commit`, `/deploy`) — cases where
Claude should not decide on its own that the moment is right. `user-invocable:
false` fits background knowledge that isn't actionable as a command; it stays
in the auto-trigger listing but never appears for manual invocation.

### Running in a Subagent

The `context: fork` field (paired with `agent`, see the frontmatter table
above) runs the skill in an isolated subagent rather than the main
conversation.

- `context: fork` only makes sense for skills with explicit task
  instructions. A knowledge-archetype skill ("use these API conventions")
  has no task for the subagent to execute: it receives the guidelines but no
  actionable prompt and returns without meaningful output. Reserve forking
  for task-style (generative) skills with explicit steps.
- The forked subagent has no access to the conversation history. The skill
  content becomes the subagent's entire prompt.
- `agent` selects the execution environment (model, tools, permissions):
  built-in `Explore`, `Plan`, `general-purpose`, or any custom subagent
  defined in `.claude/agents/`. If omitted, it defaults to `general-purpose`.
- `Explore` and `Plan` skip loading `CLAUDE.md` and git status at startup, so
  a skill forked with `agent: Explore` or `agent: Plan` sees only the
  SKILL.md content and that agent's system prompt. Project conventions from
  `CLAUDE.md` do not apply unless the skill restates them.

### Choosing the Name

The directory name is the `/command` users type, so optimize for that:
comfortable to type, unambiguous, consistent with the naming pattern already
used by the project's other skills.

- Prefer the **gerund form** (verb + `-ing`): `processing-pdfs`,
  `analyzing-spreadsheets`, `testing-code`. It clearly describes the activity
  or capability.
- Acceptable alternatives: noun phrases (`pdf-processing`) or action-oriented
  names (`process-pdfs`).
- Avoid vague names (`helper`, `utils`, `tools`) and overly generic names
  (`documents`, `data`, `files`) — they don't trigger reliably and don't
  distinguish the skill from others.
- Check for collisions before creating the skill: a project skill sharing a
  name with a bundled, personal, or plugin skill overrides/shadows it (see
  "Skill Discovery and Precedence" above). Verify the name is free, or that
  shadowing is intentional.
- The platform validation rules for claude.ai / the Agent Skills spec bar
  "anthropic" and "claude" in skill names. This is a portability constraint
  for that platform, not something Claude Code itself enforces — Claude Code
  ships a bundled `claude-api` skill under that same name.

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
    │     name + description loaded at startup for all skills that allow
    │     model invocation (`disable-model-invocation` not set)
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
