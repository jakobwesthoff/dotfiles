# Raw action variable reference example uses bare name; docs specify `${@var}` and one variable per parameter

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "Raw actions (one-off, no reusable definition)"

**Current state**:

```ruby
@file = nil
rawAction("is.workflow.actions.documentpicker.save", {
    "WFInput": "${file}"
})
```

> `${}` is ONLY for raw action variable references. NEVER use it for
> normal string interpolation.

**Problem / opportunity**:
1. The example writes `"${file}"` (bare name). The official docs write
   the reference with the `@` prefix: `"${@file}"`, and elsewhere the
   compiler deprecates bare variable references (hard-required with `@`
   from v2.2.0 per upstream release notes). The skill should model the
   `@` form.
2. The docs state a constraint the skill omits: "only a single variable
   is permitted per parameter value" for `${...}` references.

**Grounding**:
- cherrilang.org/language/raw-actions.html (fetched 2026-07-04) shows:

  ```
  rawAction("is.workflow.actions.documentpicker.save", {
       "WFInput": "${@file}"
  })
  ```

  and states: "To use a variable value for a parameter that only accepts
  a variable value, prepend an inline variable reference's brackets in a
  string value with the character `$`", with the pattern `${@variableName}`
  and a single variable per parameter value.
- v2.2.0 release notes (gh api repos/electrikmilk/cherri/releases):
  "@-prefix for variable references is now required and no longer
  deprecated."

**Proposed change**: Change the example to `"WFInput": "${@file}"`, and
add the one-variable-per-parameter-value constraint next to the existing
"`${}` is ONLY for raw action variable references" warning. Verify with a
test compile on the installed compiler that the `${@file}` form is
accepted before landing.
