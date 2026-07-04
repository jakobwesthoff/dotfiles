# Several language-fundamentals.md examples fail to compile as written

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/language-fundamentals.md`

**Current state / Problem**: Three example blocks contain code that fails
compilation, in a skill whose SKILL.md declares "NEVER omit `#include`
statements" as a critical rule:

1. Section "If/else": the example declares `@intVar`, `@textVar`,
   `@textVar2` and then uses `if @intVar > @intVar2 {}` — `@intVar2` is
   never declared.
2. Section "Control flow output": the `connectionName` example calls
   `getCellularDetail()` / `getWifiDetail()` with no include.
3. Section "URLs, dates, and other action-result types": the block calls
   `date()`, `location()`, `emailAddress()`, `phoneNumber()` with no
   includes.

(The Functions section's fibonacci example is also broken; it has its own
todo because the cause is a non-obvious compiler behavior.)

**Grounding** (local test compiles, Cherri Compiler v2.1.0, commit
2ca7dfe, 2026-07-04, all with `--skip-sign --no-ansi`):

1. Isolated if/else block fails: `Error: Undefined variable reference
   'intVar2' (4:22)`.
2. Isolated `connectionName` example fails: `Error: Action
   'getCellularDetail()' requires include: #include 'actions/network'`.
3. Isolated action-result-types block fails at `date()`: `Error: Action
   'date()' requires include: #include 'actions/calendar'`; the block
   compiles with `#include 'actions/calendar'`, `#include
   'actions/location'`, `#include 'actions/contacts'` added.

**Proposed change**:
1. Declare `@intVar2` in the if/else example (e.g. `@intVar2 = 5`) or drop
   the `>` comparison line.
2. Add `#include 'actions/network'` to the control-flow-output example.
3. Add the three includes above to the action-result-types example (or a
   comment naming the include next to each action).
After editing, re-verify each block compiles standalone.

## Correction (second pass)

The enumeration above is incomplete: a fourth block in the same file
also fails to compile as written.

4. Section "Control flow output", "Menu as output" example: the
   `deviceDetail` menu calls `getBatteryLevel()` and `getClipboard()`
   with no includes.

Grounding (Cherri Compiler v2.1.0, commit 2ca7dfe, test compiles with
`--skip-sign --no-ansi`, 2026-07-04):

- Verbatim block fails: `Error: Action 'getBatteryLevel()' requires
  include: #include 'actions/device'`.
- With `#include 'actions/device'` added it fails next with:
  `Error: Action 'getClipboard()' requires include: #include
  'actions/sharing'` (this suggestion is correct: `getClipboard` is
  defined in the compiler's bundled `actions/sharing.cherri`).
- With both `#include 'actions/device'` and `#include 'actions/sharing'`
  the block compiles (exit 0).

Extend the proposed change with: add both includes to the "Menu as
output" example. Also verified during the same pass: the "Repeat as
output" block in the same section compiles as written and needs no
change.
