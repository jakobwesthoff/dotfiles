# Using `function` requires `#include 'actions/scripting'` — the skill's fibonacci example does not compile

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/language-fundamentals.md`, section "Functions"

**Current state**: The Functions section shows the fibonacci example with
no `#include` at all:

```ruby
function fibonacci(number n) {
    ...
}
const output = fibonacci(7)
show("{output}") // 13
```

It explains the Run Shortcut mechanism and overhead but never mentions any
include requirement for functions.

**Problem**: Defining/calling any function makes the compiler emit
dictionary-handling actions (`getDictionary` and friends) for the
function-dispatch machinery. Without `#include 'actions/scripting'` the
example fails to compile — and the compiler's error suggests the WRONG
include, so an agent without this knowledge gets stuck in a misleading
loop.

**Grounding** (local verification, Cherri Compiler v2.1.0, commit 2ca7dfe,
2026-07-04):

- The fibonacci example, exactly as written in the skill, fails with:
  `Error: Action 'getDictionary()' requires include: #include
  'actions/settings'` (suggestion is wrong; `getDictionary` is a
  scripting action).
- The same file with `#include 'actions/scripting'` prepended compiles
  silently (exit 0).
- Mechanism cross-check: cherrilang.org/language/functions.html documents
  that function calls compile into dictionary-based structures passed to
  Run Shortcut (`runSelf()`), which is why dictionary actions appear.

**Version note**: This requirement is specific to the installed v2.1.0
build. Upstream v2.2.0 release notes (gh api
repos/electrikmilk/cherri/releases, 2026-07-04) state: "Scripting actions
are automatically included if functions are used, meaning you are no
longer required to add the scripting actions include to use functions."

**Proposed change**: In the Functions section of language-fundamentals.md,
add `#include 'actions/scripting'` to the fibonacci example and state the
rule: on the installed compiler (v2.1.0), any use of `function` requires
`actions/scripting` because the generated dispatch code uses dictionary
actions; compilers >= v2.2.0 include it automatically. Optionally
cross-link from the compiler-quirks "Include error messages may be
misleading" entry (the wrong `actions/settings` suggestion reproduces
here).
