# Minor wording fixes: inexact warning quote, incomplete version-attribute syntax

**Skill**: cherri

Grouped small wording corrections; each item verified independently.

## 1. Deprecation warning quoted inexactly

**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/language-fundamentals.md`, section "Referencing variables"

**Current state**: quotes the compiler warning as "Prefix variable
reference with @ for compilation speed".

**Grounding**: Actual v2.1.0 output (test compile, 2026-07-04, with
`--no-ansi`): `Warning: Deprecated: Prefix variable reference 'myVar'
with @ for compilation speed and readability. (1:12)`.

**Fix**: Quote the message exactly (agents pattern-match warnings against
documented text): `Deprecated: Prefix variable reference '<name>' with @
for compilation speed and readability.`

## 2. Custom action version attribute lacks the `>`/`<` suffix forms

**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "Definition syntax" (attributes list)

**Current state**: "`v17` — minimum iOS version".

**Grounding**: cherrilang.org/language/action-definitions.html (fetched
2026-07-04): version constraints are `v{number}` with an optional `>`
(minimum) or `<` (maximum) suffix, defaulting to minimum; example
`action v17> 'identifier' functionName()`.

**Fix**: "`v17` / `v17>` — minimum iOS version (default); `v17<` —
maximum iOS version."
