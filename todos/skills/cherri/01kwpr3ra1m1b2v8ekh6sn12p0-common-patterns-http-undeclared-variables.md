# common-patterns.md HTTP example references undeclared variables (`@apiEndpoint`, `@pageUrl`)

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/common-patterns.md`, section "HTTP API call with response handling"

**Current state**: The example declares only `@token`:

```ruby
@token = "my-token"
const headers = { "Authorization": "Bearer {@token}", ... }
const body = {"url": "{@pageUrl}"}
const response = jsonRequest(@apiEndpoint, "POST", body, headers)
```

`@apiEndpoint` and `@pageUrl` are never declared.

**Problem**: The example fails to compile on the undeclared variable
before even reaching the known `jsonRequest` const-dictionary problem
(separate todo `01kwpdccw0zs4w8b8x2ddjddbz-jsonrequest-const-dict-args-fail.md`).
Applying that todo's inline-dictionary fix alone leaves this example
still broken. This defect is not recorded in any first-pass todo (the
broken-examples todo `...ddjddcb` covers language-fundamentals.md only).

**Grounding** (Cherri Compiler v2.1.0, commit 2ca7dfe, test compiles
with `--skip-sign --no-ansi`, 2026-07-04):

- Verbatim example: `Error: Undefined variable reference 'apiEndpoint'
  (10:42)`, exit 1.
- With `@apiEndpoint = "https://api.example.com"` added, the next
  failure is the const-dictionary error from the jsonRequest todo
  (`Shortcuts does not allow variable values for this argument...`).
  Undefined `{@pageUrl}` inside the `const body` dict is not reported
  before that error, but undefined inline references in dictionary
  values do error in isolation (`@dictVar = {"url": "{@doesNotExist}"}`
  fails with `Error: Undefined reference 'doesNotExist'`), so it must
  be declared as well.

**Proposed change**: When rewriting this example for the jsonRequest
todo, also declare both missing variables, e.g.
`@apiEndpoint = "https://api.example.com"` and
`@pageUrl = "https://example.com/page"` (or derive `pageUrl` from
`ShortcutInput` as the share-sheet example does). Re-verify the block
compiles standalone afterwards.
