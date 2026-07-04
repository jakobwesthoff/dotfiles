# CLAUDE.md text nits: typo, missing word, missing period, trailing whitespace

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/CLAUDE.md

Grouped trivial fixes, all verified against the file on 2026-07-04:

1. **Line 256** — typo and missing word: "reflect all the topic
   relevant collected information as well discusisons and decisions"
   should read "... as well as discussions and decisions".

2. **Line 204** — missing final period: "wastes Opus tokens on
   mechanical work" ends the paragraph without punctuation. (The
   paragraph itself is also stale; see the separate
   `...qf-claude-md-stale-bash-subagent.md` todo. Fix the period as
   part of that rewrite.)

3. **Line 227** — trailing whitespace: "In addition please try to
   craft commands in order to NOT trigger those checks: " (only line in
   the file with a trailing space; verified with `grep -n ' $'`).

## Proposed change

Apply the three edits above in one pass.
