# formatNumber quirk is wrong: the action needs only `actions/scripting`, not a four-include chain

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md`, section "`formatNumber` has a deep dependency chain"

**Current state**:

> `formatNumber` requires multiple includes (settings, shortcuts, text,
> web) — the compiler reveals them one at a time. Consider manual
> arithmetic for formatting instead:

followed by a manual rounding workaround.

**Problem**: The premise is false. `formatNumber` is defined in the
scripting category and compiles with `#include 'actions/scripting'`
alone. The "multiple includes revealed one at a time" impression is the
known wrong-include-suggestion bug (suggestions cycle through incorrect
categories), not a real dependency chain. The recommended manual
arithmetic workaround is unnecessary complexity.

**Grounding** (local verification, Cherri Compiler v2.1.0, commit
2ca7dfe, 2026-07-04):

- No include: `Error: Action 'formatNumber()' requires include: #include
  'actions/settings'`.
- With `#include 'actions/settings'`: `Error: ... requires include:
  #include 'actions/sharing'` — the suggestion CHANGED, confirming the
  cycling-suggestion bug.
- With only `#include 'actions/scripting'`: compiles silently (exit 0).
- Source of truth: `grep -rln formatNumber
  /Users/jakob/Development/github/electrikmilk/cherri/actions/` matches
  only `actions/scripting.cherri` (the compiler's bundled action
  definitions).

**Proposed change**: Replace the entry with: `formatNumber` needs
`#include 'actions/scripting'`; the compiler's include suggestions for it
cycle through wrong categories (settings, sharing, ...). Drop the manual
arithmetic workaround. Generalize the lesson into the existing "Include
error messages may be misleading" entry: when suggestions cycle, the
definitive answer is `grep -l <actionName>` over the compiler source
checkout's `actions/*.cherri` files (available on this machine at
`/Users/jakob/Development/github/electrikmilk/cherri/actions/`); the same
technique resolved `randomNumber` (also defined in
`actions/scripting.cherri`, absent from every `--docs` category listing).

## Correction (second pass)

The central claim (scripting include alone suffices; the "dependency
chain" is the cycling-suggestion bug) is confirmed, but the verification
and proposed replacement are incomplete: they hold only for integer
input. `formatNumber`'s first parameter is typed `number` (integer), and
on v2.1.0 float values are rejected in every form, so the manual
workaround the entry recommends dropping still has a use case (formatting
float values).

Grounding (Cherri Compiler v2.1.0, commit 2ca7dfe, test compiles with
`--skip-sign --no-ansi`, 2026-07-04):

- Signature: `formatNumber(number number, number ?decimalPlaces = 2):
  number` (`cherri --action=formatNumber --no-ansi`).
- `@num = 42` + `formatNumber(@num, 2)` with `#include
  'actions/scripting'`: compiles, exit 0 (matches the original todo).
- `@num = 3.14` + `formatNumber(@num, 2)`: fails —
  `Error: Invalid variable value 3.14 (float) for argument 'number'
  (number).`
- Float literal `formatNumber(3.14, 2)`: fails —
  `Error: Invalid value 3.14 (float) for argument 'number' (number).`
- `.number` property coercion does not help: `@coerced = @n.number` with
  `@n = 3.14` still fails with the same variable-value error.

- The working route for float values compiles (exit 0): coerce through
  a `number`-typed variable with the `number()` action —

  ```ruby
  @f = 3.14
  @n: number
  @n = number(@f)
  const formatted = formatNumber(@n, 2)
  ```

Amend the proposed replacement entry to state: `formatNumber` needs
`#include 'actions/scripting'` and accepts only integer (`number`)
input on v2.1.0 — float literals and float variables are rejected, and
`.number` coercion does not change the compile-time type. For float
values, route through `number()` into a `number`-typed variable as
above (same pattern as the "Action return values need explicit
coercion" quirk).
