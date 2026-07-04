# Missing discovery tool: `cherri --action=` (empty) prints ALL action definitions, covering actions absent from `--docs`

**Skill**: cherri
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "Caveats about `--docs` and `--action`"
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/compiler-quirks.md`, section "Some actions are missing from `--docs` output"

**Current state**: For actions missing from `--docs` category listings,
the skill's only fallback is exact/substring lookup with
`cherri --action=name`, which requires already suspecting a name. No
complete listing is documented.

**Problem / opportunity**: The compiler has a built-in complete dump the
skill does not mention. It closes the "action exists but appears in no
category listing" gap: an agent can dump everything once and grep it for
keywords, instead of guessing names against `--action=` one at a time.

**Grounding** (Cherri Compiler v2.1.0, commit 2ca7dfe, 2026-07-04):

- `cherri --help`: `--action=  Search for available actions. Empty prints
  all definitions.`
- `cherri --action= --no-ansi` prints 367 `###`-headed definition blocks
  (name, description, signature) — counted with `grep -c "^###"`.
- `randomNumber`, which appears in no `--docs` category, is present in
  the dump with its full signature
  (`randomNumber(number min, number max): number`).
- Limitation (same as `--action=name`): the dump contains no
  category/include information, so it identifies actions but not their
  `#include`. It also exits 1 despite succeeding, like other `--action`
  lookups (see todo `...ddjddc2-compile-success-detection-imprecise.md`).

**Proposed change**: Add one bullet to the "Caveats about `--docs` and
`--action`" section (and cross-reference from the compiler-quirks
"missing from `--docs`" entry): to search across ALL actions including
those missing from category listings, dump the complete definition list
with `cherri --action= --no-ansi` and grep it; the dump has no include
information, so resolve the `#include` separately (per the existing
source-checkout grep technique).
