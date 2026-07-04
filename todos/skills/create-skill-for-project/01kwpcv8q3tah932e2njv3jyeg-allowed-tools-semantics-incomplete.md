# `allowed-tools` semantics incomplete: grants permission without restricting, gated by workspace trust

**Skill**: create-skill-for-project
**File**: `/Users/jakob/dotfiles/.claude/skills/create-skill-for-project/references/skill-structure.md`, frontmatter example (`allowed-tools: Read Grep Bash(bun:*)  # Optional. Space-delimited pre-approved tools`) and Field Constraints row ("Space-delimited pre-approved tools.")

## Current state

`allowed-tools` is described in five words as pre-approved tools. No semantics, no security note.

## Problem

The official docs ("Pre-approve tools for a skill", https://code.claude.com/docs/en/skills, fetched 2026-07-04) attach semantics an author needs to generate correct, safe skills:

- **Grant, not restriction**: "It does not restrict which tools are available: every tool remains callable, and your permission settings still govern tools that are not listed." An author wanting to *limit* a skill must use `disallowed-tools` (removes tools from the pool while the skill is active; clears on the next user message) or permission deny rules.
- **Trust gate for project skills**: "For skills checked into a project's `.claude/skills/` directory, `allowed-tools` takes effect after you accept the workspace trust dialog for that folder... Review project skills before trusting a repository, since a skill can grant itself broad tool access." This is a review point the meta-skill's Phase 5 security check ("No hardcoded secrets or credentials") should extend to: does the generated `allowed-tools` list grant more than the skill needs?
- Official example format uses patterns like `Bash(git add *) Bash(git commit *) Bash(git status *)` scoped to exact command prefixes, not broad grants.
- `${CLAUDE_PROJECT_DIR}` substitution also applies inside `allowed-tools` (v2.1.196+), enabling rules like `Bash(${CLAUDE_PROJECT_DIR}/scripts/lint.sh *)`.

## Proposed change

Expand the `allowed-tools` row/example: it pre-approves (never restricts) the listed tools while the skill is active; scope Bash grants to narrow command prefixes; mention `disallowed-tools` as the restriction counterpart; note the workspace-trust gate for project skills. Add a Phase 5 check: `allowed-tools` grants are minimal for what the skill actually runs.

## Correction (second pass): colon-vs-space Bash rule syntax settled

The first pass left open whether the skill's example `Bash(bun:*)` (colon form) or the docs' `Bash(git add *)` (space form) is correct. The permissions reference (https://code.claude.com/docs/en/permissions, fetched 2026-07-04) settles it — **both forms are valid and equivalent for a trailing wildcard**:

- "The space before `*` matters: `Bash(ls *)` matches `ls -la` but not `lsof`, while `Bash(ls*)` matches both. The `:*` suffix is an equivalent way to write a trailing wildcard, so `Bash(ls:*)` matches the same commands as `Bash(ls *)`."
- "The `:*` form is only recognized at the end of a pattern. In a pattern like `Bash(git:* push)`, the colon is treated as a literal character and won't match git commands."
- "Bash rules support glob patterns with `*`. Wildcards can appear at any position in the command", and "A single `*` matches any sequence of characters including spaces" (`Bash(git * main)` matches `git push origin main`).
- "The permission dialog writes the space-separated form when you select 'Yes, don't ask again' for a command prefix."

So `Bash(bun:*)` in the skill's frontmatter example is valid documented syntax (equivalent to `Bash(bun *)`: matches `bun install` but not `bunx`) and needs no correction. Two refinements to this todo's text follow from the same page: "scoped to exact command prefixes" above is imprecise (a trailing `* `-rule is a prefix wildcard with a word boundary, and mid-pattern wildcards exist too), and the fix should state the equivalence explicitly plus prefer the space form for consistency with what the docs and the permission dialog write. One caveat worth carrying into the skill: "Claude Code is aware of shell operators, so a rule like `Bash(safe-cmd *)` won't give it permission to run the command `safe-cmd && other-cmd`" — a rule must match each subcommand independently.
