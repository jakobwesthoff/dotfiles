# Quirk "Boolean-returning actions must use @var, not const" is not reproducible in v2.1.0

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md`, section "Boolean-returning actions must use `@var`, not `const`"

**Current state**:

> Some actions that return booleans (e.g., `isCharging()`,
> `connectedToCharger()`) crash the compiler when assigned to `const`.
> Always use `@var`:
> ```ruby
> // WRONG — compiler panic
> const charging = isCharging()
> ```

**Problem**: The claim does not hold for the installed compiler. Following
it costs nothing functionally, but it contradicts the skill's own "ALWAYS
use `const` over `@var`" efficiency rule for no reason, and an agent
debugging a real panic may waste time on this stale workaround.

**Grounding** (local verification, Cherri Compiler v2.1.0, 2026-07-04):

```ruby
#include 'actions/device'
const charging = isCharging()
```

compiles silently with exit code 0 (`--skip-sign`). `cherri
--action=isCharging --no-ansi` reports `isCharging(): bool`. The installed
binary is built from a source checkout at
`/Users/jakob/Development/github/electrikmilk/cherri` at commit `2ca7dfe`
(2026-01-24, `v2.1.0` + 18 commits on `main`).

**Proposed change**: Remove the quirk entry, or if it is kept because older
compiler versions are still in use somewhere, rewrite it to state the
version where it was observed and that v2.1.0 (commit 2ca7dfe) compiles
`const charging = isCharging()` without error. See also the companion todo
about version-tagging all quirk entries.
