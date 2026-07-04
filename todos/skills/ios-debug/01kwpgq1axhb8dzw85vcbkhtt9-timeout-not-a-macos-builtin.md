# `timeout` is not a macOS system utility; the tip silently depends on Homebrew coreutils

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Tips" ("Always wrap `uv run` scripts with `timeout N` to prevent hangs.") and frontmatter `Bash(timeout *)`

**Current state**: The skill instructs wrapping every `uv run` invocation with `timeout N`, and pre-approves `Bash(timeout *)`, without stating where `timeout` comes from.

**Problem**: macOS ships no `/usr/bin/timeout`. On this machine the command resolves only because Homebrew coreutils' gnubin is on PATH. On a Mac without coreutils (or without gnubin on PATH, where the binary is only reachable as `gtimeout`), every wrapped command in this skill fails with "command not found" — a confusing failure for a debugging skill. The prerequisite is real but undocumented.

**Grounding** (local command output, 2026-07-04):
- `ls /usr/bin/timeout` → `ls: cannot access '/usr/bin/timeout': No such file or directory` (macOS 26.3.1, `sw_vers`).
- `which timeout gtimeout` → `/opt/homebrew/opt/coreutils/libexec/gnubin/timeout` and `/opt/homebrew/bin/gtimeout` (Homebrew coreutils).

**Proposed change**: Either
1. document the dependency in Prerequisites ("`timeout` from GNU coreutils: `brew install coreutils`, gnubin on PATH — otherwise use `gtimeout`"), or
2. remove the outer `timeout` wrapper and enforce the deadline inside the Python snippet with `asyncio.wait_for(run(), N)`, which needs no extra tooling and pairs with dropping the over-broad `Bash(timeout *)` grant (see the allowed-tools todo).

Option 2 is the smaller total surface.
