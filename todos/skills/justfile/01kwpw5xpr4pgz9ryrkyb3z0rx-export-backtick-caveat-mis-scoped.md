# Export/backtick caveat is mis-scoped: recipe-body backticks DO see exported variables

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/variables-and-expressions.md` — "Export / Unexport" section

**Current state**:
> **Caveat:** exported variables are NOT available to backtick expressions in
> the same scope — backticks evaluate before recipes run.

**Problem**: The restriction only applies to backticks in other top-level
variable assignments. Backticks inside recipe bodies and in parameter
default values DO see exported variables, and exported parameters are
visible to backticks in the recipe as well. The stated rationale
("backticks evaluate before recipes run") is wrong for those backticks:
recipe-body interpolations evaluate when the containing line runs. As
written, the caveat steers authors away from working patterns (e.g. a
recipe-body backtick reading an `export`ed variable).

**Grounding** — local tests, just 1.55.0:

```just
export TOP := 'top-val'
bt := `echo "${TOP:-unset-top-assign}"`

r $P:
  @echo "assign-bt={{bt}}"
  @echo "inline-top={{ `echo "${TOP:-unset-top-inline}"` }}"
  @echo "inline-param={{ `echo "${P:-unset-param-inline}"` }}"
```

`just r pval` printed (exit 0):

```
assign-bt=unset-top-assign
inline-top=top-val
inline-param=pval
```

Parameter-default backticks also see exported variables:

```just
export TOP := 'top-val'

r p=`echo "${TOP:-unset-default}"`:
  @echo "p={{p}}"
```

`just r` printed `p=top-val` (exit 0).

README (casey/just master, "Export" section): "Exported variables and
parameters are not exported to backticks in the same scope." — its example
is a top-level assignment backtick (`BAR := `echo hello $WORLD``), i.e. the
module scope; recipe backticks are a child scope and are not covered by
that sentence.

**Proposed change**: Reword the caveat to the verified semantics:
1. Exported variables are NOT visible to backticks in other top-level
   variable assignments (the module scope).
2. They ARE visible to backticks inside recipe bodies and in parameter
   default values; exported parameters (`$P`) are too.
3. Drop the "backticks evaluate before recipes run" rationale, or restrict
   it to top-level assignment backticks (recipe-body interpolations
   evaluate at line execution — see the separate interpolation-timing todo
   `01kwpw5xpr4pgz9ryrkyb3z0rz`).
