# Python `->` annotations work in `[script("python3")]` recipes; the skill's ban is false

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/advanced-patterns.md` — "Body tokenization caveat" section

**Current state**:
> NEVER use Python `->` return type annotations inside `[script("python3")]` recipes — the `->` token is not valid in just's lexer. Remove annotations or move annotated functions to an external `.py` file.

**Problem**: False on just 1.55.0. Recipe body lines are not lexed as just expressions; apart from `{{…}}` interpolation, arbitrary text (including `->`) is passed through.

**Grounding**: Local test (just 1.55.0), exit 0, printed `42`:
```just
[script("python3")]
arrow:
  def f() -> int:
      return 42
  print(f())
```

**Proposed change**: Delete the `->` paragraph. If the surrounding "Body tokenization caveat" section is kept, limit it to the verified facts: `{{` sequences anywhere in the body (including comments) are interpolated or cause `error: unterminated interpolation` (verified locally), and less-indented lines end the recipe body.
