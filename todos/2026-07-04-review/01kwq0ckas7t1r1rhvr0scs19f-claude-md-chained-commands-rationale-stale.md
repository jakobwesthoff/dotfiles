# CLAUDE.md claims chained commands "bypass blanket permission rules" — current Claude Code matches each subcommand independently

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/CLAUDE.md lines 221-223

## Current state

```
Prefer issuing separate Bash tool calls over chaining commands with
`&&`, `;`, or `||`. Chained commands bypass blanket permission rules,
forcing manual approval each time.
```

## Problem

The stated mechanism no longer matches documented behavior. Current
permission docs (https://code.claude.com/docs/en/permissions, "Compound
commands", fetched 2026-07-04):

> "Claude Code is aware of shell operators, so a rule like
> `Bash(safe-cmd *)` won't give it permission to run the command
> `safe-cmd && other-cmd`. The recognized command separators are `&&`,
> `||`, `;`, `|`, `|&`, `&`, and newlines. A rule must match each
> subcommand independently."

So a chained command is auto-approved when every subcommand matches an
allow rule or the built-in read-only set; it does not force manual
approval "each time". Approvals also persist now:

> "When you approve a compound command with 'Yes, don't ask again',
> Claude Code saves a separate rule for each subcommand that requires
> approval ... Up to 5 rules may be saved for a single compound
> command."

The follow-up bullet on line 228 remains correct and current — the same
docs page states: "Combining `cd` with `git` in one compound command
always prompts, regardless of the target directory."

The preference itself (separate Bash calls) still has a basis: a chain
prompts whenever any one subcommand is uncovered, and `cd`+`git` chains
always prompt. Only the rationale sentence is wrong.

## Grounding

- CLAUDE.md lines quoted above (2026-07-04).
- https://code.claude.com/docs/en/permissions — "Compound commands"
  section, quotes inlined above.

## Proposed change

Replace the rationale sentence with the current mechanism, e.g.:
"A chained command is only auto-approved if every subcommand matches an
allow rule, so one uncovered part forces a prompt for the whole chain;
`cd` combined with `git` in one chain always prompts." Keep the
separate-calls preference and the line-228 bullet as is. Fix the
trailing whitespace on line 227 together with this edit (also listed in
the grouped nits todo 01kwppd9ezp2ebng09dbfrgfqk).
