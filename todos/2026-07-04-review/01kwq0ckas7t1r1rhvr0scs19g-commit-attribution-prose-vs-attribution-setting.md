# CLAUDE.md bans Co-Authored-By trailers by prose only — the `attribution` setting would enforce it mechanically

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/CLAUDE.md line 315; /Users/jakob/dotfiles/.claude/settings.json (key absent)

## Current state

CLAUDE.md line 315 (Git workflow, commit rules):

```
- Never mention AI, Claude, or Anthropic. Never add Co-Authored-By or similar.
```

`settings.json` contains no `attribution` key.

## Problem

Claude Code adds commit/PR attribution itself and injects the
instruction per tool call: in a session on this machine (v2.1.201,
2026-07-04), the Bash tool description directs ending commit messages
with `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` plus a
`Claude-Session:` trailer, and PR bodies with a "Generated with Claude
Code" footer. Every commit therefore pits a per-call harness
instruction against the CLAUDE.md prose rule; the model has to resolve
the conflict correctly every time.

A dedicated setting exists for exactly this. Settings reference
(https://code.claude.com/docs/en/settings, "Attribution settings",
fetched 2026-07-04):

> "`commit` — Attribution for git commits, including any trailers.
> Empty string hides commit attribution"
> "`pr` — Attribution for pull request descriptions. Empty string hides
> pull request attribution"
> "`sessionUrl` — Whether to append the claude.ai session link as a
> `Claude-Session` trailer on commits ... Defaults to `true`."
> "To hide all attribution, set `commit` and `pr` to empty strings and
> `sessionUrl` to `false`."

With the setting in place, the harness stops injecting the trailer
instruction at the source instead of relying on instruction precedence.

## Grounding

- CLAUDE.md line 315 (quoted above).
- `settings.json` read 2026-07-04 — no `attribution` key.
- Bash tool description observed in this session (v2.1.201), quoted
  above.
- https://code.claude.com/docs/en/settings — Attribution settings
  section, quotes inlined above.

## Proposed change

Add to `.claude/settings.json`:

```json
"attribution": { "commit": "", "pr": "", "sessionUrl": false }
```

Keep the CLAUDE.md line as a backstop for tools the setting does not
cover (e.g. "never mention AI" in commit bodies is broader than
trailer suppression).
