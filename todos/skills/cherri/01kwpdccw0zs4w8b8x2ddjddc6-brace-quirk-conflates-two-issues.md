# "Curly braces in strings" quirk conflates brace parsing with the rawtext argument restriction

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md`, section "Curly braces in strings are always parsed as references"

**Current state**:

> Both double-quoted and single-quoted strings treat `{N}` as a variable
> reference attempt. This means regex quantifiers like `{50}` are
> unusable in string literals — use character classes or loops instead.

**Problem**: The blanket "always parsed" claim is wrong for one case and
hides a second, different failure mode. Verified v2.1.0 behavior:

1. Double-quoted `"a{50}"`: fails at declaration — `Error: Undefined
   inline reference '50'`.
2. Single-quoted `'a{50}'` passed directly as an action argument: fails —
   `Error: Undefined reference '50'`.
3. Single-quoted `'a{50}'` assigned to a variable, variable not passed to
   any action: **compiles cleanly** — braces are NOT parsed at raw-text
   declaration.
4. But that variable is then unusable as a `text` argument anyway, for an
   unrelated reason: `Error: Invalid variable value a{50} (rawtext) for
   argument 'alert' (text).` (Same failure with brace-free raw text; see
   the separate rawtext-argument todo.)

The practical conclusion ("regex quantifiers are unusable in string
literals") survives, but the mechanism description is inaccurate and the
error messages an agent will actually see are undocumented.

**Grounding**: All four cases test-compiled locally on Cherri Compiler
v2.1.0 (commit 2ca7dfe), 2026-07-04, with `--skip-sign --no-ansi`; error
messages quoted verbatim above.

**Proposed change**: Rewrite the entry to enumerate the observed cases and
exact error messages: double-quoted strings always parse `{...}` as an
inline reference; single-quoted strings parse it when the literal is used
as an action argument; a declared-but-unused raw-text variable compiles
but cannot be passed to `text` parameters (rawtext restriction). Keep the
recommendation (character classes or repeat loops instead of `{n}`
quantifiers).
