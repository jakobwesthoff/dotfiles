# "You typically only need #include 'stdlib'" is wrong — stdlib does not pull in its dependency includes

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "Standard library functions (`stdlib`)"

**Current state**:

> The stdlib internally uses actions from `actions/text`, `actions/web`,
> and `actions/scripting`. The compiler resolves these — you typically
> only need `#include 'stdlib'`.

**Problem**: The compiler does NOT resolve the stdlib's action
dependencies. A file with only `#include 'stdlib'` and a `runJS()` call
fails to compile, and the missing includes are revealed one error at a
time (three compile rounds), with the first suggestion even pointing at
the wrong category.

**Grounding** (local verification, Cherri Compiler v2.1.0, commit 2ca7dfe,
2026-07-04):

- `#include 'stdlib'` + `@jsResult = runJS("console.log('hello')")` fails:
  `Error: Action 'getDictionary()' requires include: #include
  'actions/settings'` — note the suggested include is wrong;
  `getDictionary` lives in `actions/scripting`.
- Adding `#include 'actions/scripting'` fails next with: `Error: Action
  'replaceText()' requires include: #include 'actions/text'`.
- Adding that fails next with: `Error: Action 'urlDecode()' requires
  include: #include 'actions/web'`.
- With all four includes (`stdlib`, `actions/scripting`, `actions/text`,
  `actions/web`) the file compiles silently.

The note in common-patterns.md's "VCard menus" example already lists all
four includes, which is consistent with this behavior.

**Proposed change**: Rewrite the stdlib paragraph in
actions-and-includes.md: using stdlib functions requires including the
stdlib's action dependencies yourself; for `runJS`/`chooseFromVCard` the
verified working set is:

```ruby
#include 'stdlib'
#include 'actions/scripting'
#include 'actions/text'
#include 'actions/web'
```

Also note the wrong `actions/settings` suggestion for `getDictionary` as a
concrete instance under the existing "Include error messages may be
misleading" quirk in compiler-quirks.md.
