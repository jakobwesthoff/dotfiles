# CLAUDE.md's "macOS-compatible" sed invocation fails with stock macOS sed — it works only through the gsed alias

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/CLAUDE.md lines 238-242

## Current state

```
### sed (macOS)

Use the macOS-compatible invocation: `sed -e "s|PAT|REPL|g" -i file`.
Flags must appear in that order (`-e` expression, then `-i` for
in-place, then filename — no `''` after `-i`).
```

## Problem

The documented invocation is GNU sed syntax, not macOS syntax. Stock
macOS `/usr/bin/sed` (BSD sed) requires an argument to `-i`, so it
consumes the filename as the backup extension and then has no input
file. Tested 2026-07-04:

```
$ printf 'hello\n' > f.txt
$ /usr/bin/sed -e "s|hello|world|g" -i f.txt </dev/null
sed: -I or -i may not be used with stdin
(exit 1, f.txt unchanged)
```

The form the instruction explicitly forbids ("no `''` after `-i`") is
exactly the one BSD sed needs; that form works:

```
$ /usr/bin/sed -i '' -e "s|hello|world|g" f3.txt
(exit 0, file now contains "world")
```

The instruction happens to work in Claude Code sessions on this machine
only because `.zshrc.d/050_aliases.sh:3-4` aliases `sed` to `gsed` when
GNU sed is installed (Brewfile line 36: `brew "gnu-sed"`), and the Bash
tool's shell loads that alias. Verified in-session: `type sed` reports
"sed is an alias for gsed" and the documented invocation succeeds via
`gsed (GNU sed) 4.10`. Anywhere the alias does not apply — shell
scripts, `sh`/`bash` invocations, other Macs without these dotfiles,
remote sessions — a Claude following this global instruction produces a
failing command.

## Grounding

- Command outputs above (2026-07-04).
- `.zshrc.d/050_aliases.sh:3-4`:
  `if which gsed &>/dev/null; then alias sed="gsed" ...`
- Brewfile:36 `brew "gnu-sed"`.

## Proposed change

Make the instruction match what it actually relies on. Either:

- Rewrite to state the portable BSD form:
  `sed -i '' -e "s|PAT|REPL|g" file` (works with stock macOS sed;
  GNU sed instead needs `-i` with no separate `''`), or
- Keep the GNU form but rename the section and state the dependency:
  "sed (GNU sed via gsed)" and instruct `gsed -e "s|PAT|REPL|g" -i
  file` explicitly, so the command does not silently depend on the
  shell alias.

Calling `gsed` explicitly is the least fragile option since the
Brewfile already installs it.
