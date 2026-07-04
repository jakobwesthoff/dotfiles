# `canonicalize()` "path must exist at parse time" is wrong; recipe interpolations evaluate per line at execution

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/functions.md` — "Path Manipulation / Fallible" table, `canonicalize` row: "Resolves symlinks; path must exist **at parse time**"
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/variables-and-expressions.md` — "Interpolation in Recipe Bodies" section (no evaluation-timing statement anywhere in the skill)

**Current state**: The `canonicalize` row claims the path must exist at
parse time. The skill nowhere states when `{{…}}` interpolations in recipe
bodies are evaluated.

**Problem**: The path must exist when the expression is *evaluated*, not
when the justfile is parsed. For a recipe-body interpolation that is the
moment the containing line runs, so a file created by an earlier line of
the same recipe is perfectly usable. The "parse time" claim would make an
author needlessly avoid `canonicalize()` (and other filesystem functions)
on files their own recipe creates.

**Grounding** — local tests, just 1.55.0, marker files removed before each
run:

```just
r:
  @touch {{justfile_directory()}}/cz-marker
  @echo "canon={{ canonicalize(justfile_directory() / 'cz-marker') }}"
```

`just r` → exit 0, printed the resolved absolute path of `cz-marker`. If
the interpolation had been evaluated at parse time (or upfront before the
recipe body), `canonicalize` would have aborted because the file did not
exist yet.

Same result with `path_exists()`:

```just
timing:
  @touch {{justfile_directory()}}/marker-t1
  @echo "exists={{ path_exists(justfile_directory() / 'marker-t1') }}"
```

printed `exists=true` (exit 0) with the marker absent before the run —
line 2's interpolation was evaluated only after line 1 had executed.

**Proposed change**:
1. functions.md: change the `canonicalize` note to "path must exist when
   the expression is evaluated (justfile load for variable assignments,
   line execution for recipe interpolations)".
2. variables-and-expressions.md "Interpolation in Recipe Bodies": add one
   line stating that each line's `{{…}}` interpolations are evaluated
   when that line runs, so they can observe effects of earlier lines.
