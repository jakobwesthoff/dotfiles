# Variadic parameter values are space-joined; argument boundaries are lost in `{{…}}`

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — "Parameters" section (variadic examples and the quoting caveat below them)

**Current state**: The variadic examples interpolate directly
(`scp {{FILES}} server:~/backups/`). The quoting caveat that follows
covers word splitting for a single parameter and recommends quoting the
interpolation or `set positional-arguments` + `"$1"`.

**Problem**: For variadic parameters neither fix restores correctness when
individual arguments contain spaces, because the parameter's value is the
arguments joined with single spaces before interpolation. Unquoted, an
argument containing a space splits into separate words; quoted, all
arguments merge into one word. The original argument boundaries are
unrecoverable from `{{FILES}}` in both cases. The space-safe pattern
(`set positional-arguments` + `"$@"`) exists in settings.md's
"Positional Arguments" section, but the variadic documentation never
routes readers there.

**Grounding** — local test, just 1.55.0:

```just
unq +FILES:
  @printf '[%s]\n' {{FILES}}

q +FILES:
  @printf '[%s]\n' "{{FILES}}"
```

- `just unq "a b" c` → `[a]` `[b]` `[c]` (three words; the "a b" argument
  was split).
- `just q "a b" c` → `[a b c]` (one word; the two arguments were merged).

Neither invocation can distinguish arguments `"a b", c` from `a, "b c"`.

**Proposed change**: Add a note to the variadic block: a variadic
parameter's value is all matched arguments joined with single spaces, so
`{{FILES}}` cannot preserve boundaries of arguments containing spaces;
for space-safe forwarding use `set positional-arguments` (or the
`[positional-arguments]` attribute) with `"$@"`, cross-linking
settings.md's existing forwarding example.
