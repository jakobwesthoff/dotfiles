# Type declaration list omits `rawtext` and `color`

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/language-fundamentals.md`, section "Type declarations"

**Current state**: The type-declarations example lists exactly seven types:

```ruby
@t: text
@num: number
@list: array
@obj: dictionary
@flag: bool
@ref: variable
@real: float
```

**Problem**: The compiler recognizes nine declarable types. `rawtext` and
`color` are missing from the skill entirely (rawtext is only implied via
single-quoted strings; color never appears as a type).

**Grounding** (local verification, Cherri Compiler v2.1.0, 2026-07-04):
Compiling a file with an unknown type in an action definition prints the
authoritative list:

```
Unknown type 'timerDuration'

Available types:
- text
- rawtext
- number
- float
- bool
- array
- dictionary
- variable
- color
```

(Observed while compiling `#include 'actions/music'`, which fails on the
`seek` definition in v2.1.0.)

**Proposed change**: Add `rawtext` and `color` to the type-declarations
list in language-fundamentals.md. Cross-link `rawtext` to the raw-text
section (single-quoted strings produce this type; see the separate todo on
rawtext argument rejection). Before documenting `color` usage beyond the
type name, verify with a test compile what values a `color`-typed
variable/parameter accepts.
