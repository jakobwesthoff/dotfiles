# CLAUDE.md references a "Bash subagent type" that does not exist in current Claude Code

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/CLAUDE.md lines 201-204

## Current state

```
When spawning Task agents that primarily run shell commands rather than
requiring deep reasoning, always explicitly set `model: "sonnet"`. The Bash
subagent type inherits the parent model when no model is specified, which
wastes Opus tokens on mechanical work
```

## Problem

There is no "Bash" subagent type in current Claude Code:

- The sub-agents documentation lists the built-in subagents as Explore,
  Plan, and general-purpose
  (https://code.claude.com/docs/en/sub-agents, "Claude Code includes
  several built-in subagents such as Explore, Plan, and
  general-purpose").
- A Claude Code v2.1.201 session on this machine (2026-07-04) offers
  the agent types: claude, claude-code-guide, Explore, general-purpose,
  Plan, statusline-setup. No `agents/` directory exists in
  `dotfiles/.claude/` or `~/.claude/` that could define a custom "Bash"
  agent.

The rationale sentence is therefore dead: it explains the instruction
by the behavior of a type that no longer exists. The surrounding
premise ("wastes Opus tokens") also assumes an Opus parent session,
while `settings.json` currently selects Fable 5.

The instruction itself (set `model: "sonnet"` for mechanical
shell-running agents) still works: the subagent `model` field accepts
`sonnet` and defaults to `inherit` (sub-agents docs, frontmatter field
table: "`model` ... Defaults to `inherit`").

## Grounding

- Quoted CLAUDE.md lines 201-204.
- https://code.claude.com/docs/en/sub-agents (built-in list and `model`
  field default, quoted above).
- Session agent-type list of 2026-07-04 (v2.1.201).

## Proposed change

Rewrite the paragraph in terms that exist today, e.g.: "When spawning
general-purpose or custom Task agents that primarily run shell commands
rather than requiring deep reasoning, explicitly set `model: "sonnet"`;
subagents default to inheriting the parent model, which wastes
premium-model tokens on mechanical work." Also add the missing final
period (see the grouped nits todo).
