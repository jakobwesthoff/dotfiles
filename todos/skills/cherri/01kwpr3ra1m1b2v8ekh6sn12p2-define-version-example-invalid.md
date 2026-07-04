# `#define version 16.0` example in shortcut-metadata.md does not compile — versions are a fixed key list

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/shortcut-metadata.md`, section "Minimum iOS version"

**Current state**:

> ```ruby
> #define version 16.0
> ```
>
> Warns if you use actions unsupported in the target version.

**Problem**: `16.0` is not an accepted version string. The compiler
validates the value against a fixed map of version keys; anything else is
a hard compile error, not a warning. An agent copying the skill's example
verbatim gets an immediate failure.

**Grounding** (Cherri Compiler v2.1.0, commit 2ca7dfe, 2026-07-04):

- Test compile of `#define version 16.0` fails, exit 1:

  ```
  Error: Invalid minimum version '16.0'

  Available versions:
  - 26
  - 18.4
  - 18
  - 17
  - 16.5
  - 16.4
  - 16.3
  - 16.2
  - 16
  - 15.7.2
  - 15
  - 14
  - 13
  - 12
  ```

- Compiler source (checkout
  `/Users/jakob/Development/github/electrikmilk/cherri`): the accepted
  keys are the `versions` map at `shortcut.go:219-234`; the exact-match
  lookup and error are at `parser.go:968-973`.
- `#define version 16` compiles (exit 0, verified in a combined
  metadata test file).

**Proposed change**: Change the example to `#define version 16` and add
the accepted values inline: `26, 18.4, 18, 17, 16.5, 16.4, 16.3, 16.2,
16, 15.7.2, 15, 14, 13, 12` (exact strings; no `.0` forms). Note that an
invalid value is a compile error that prints this list.
