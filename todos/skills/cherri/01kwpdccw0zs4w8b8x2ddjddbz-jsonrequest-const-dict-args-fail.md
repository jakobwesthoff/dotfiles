# jsonRequest rejects `const` dictionary args — flagship HTTP examples in the skill do not compile

**Skill**: cherri
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "HTTP requests"
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/common-patterns.md`, section "HTTP API call with response handling"
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/share-sheet-shortcut.md`, section "Complete example"

**Current state**: actions-and-includes.md says:

> Note the `dictionary!` type on HTTP action params — headers and body
> require **literal dictionary values** (inline dicts or constants), not
> `@` variable references.

and shows this pattern (also used verbatim in common-patterns.md and in the
complete share-sheet example):

```ruby
const headers = { ... }
const body = {"url": "{pageUrl}"}
const response = jsonRequest("https://api.example.com", "POST", body, headers)
```

**Problem**: Two inaccuracies, one of which breaks the skill's flagship examples:

1. Passing a `const` dictionary to `jsonRequest`'s `body`/`headers` fails to
   compile in the installed compiler. Only **inline dictionary literals**
   work — `!` on a parameter type means the value must be written inline,
   and `const` references do not qualify. Every HTTP example in the skill
   that routes `body`/`headers` through a `const` fails with a compile
   error.
2. The `dictionary!` marker is real in the compiler's bundled definition
   (`actions/web.cherri:126-133` in the source checkout at
   `/Users/jakob/Development/github/electrikmilk/cherri` defines
   `dictionary! ?body: 'WFJSONValues', dictionary! ?headers:
   'WFHTTPHeaders'`), but `cherri --action=jsonRequest --no-ansi` STRIPS
   the `!` and prints `dictionary ?body, dictionary ?headers`. An agent
   told to look for `dictionary!` in CLI signatures will never see it and
   will wrongly conclude variables are allowed.

**Grounding** (local verification, Cherri Compiler v2.1.0, binary
`/Users/jakob/.local/bin/cherri`, 2026-07-04):

- Test file with `const body = {...}; const headers = {...};
  jsonRequest("https://api.example.com", "POST", body, headers)` fails:

  ```
  Error: Shortcuts does not allow variable values for this argument, use a literal for the argument value.
  jsonRequest(..., ..., dictionary ?body, ...)
  ```

- Same error with `@var` dictionaries (so the `@`-variable half of the claim
  is correct).
- Passing inline dict literals directly in the call compiles silently:

  ```ruby
  const response = jsonRequest("https://api.example.com", "POST", {"url": "https://example.com"}, {"Content-Type": "application/json"})
  ```

- `cherri --action=jsonRequest --no-ansi` output shows `dictionary ?body,
  dictionary ?headers` with no `!` marker.

**Proposed change**:
1. In actions-and-includes.md: correct the `dictionary!` note to the
   verified rule: `jsonRequest` `body`/`headers` accept **only inline
   dictionary literals**; both `@var` and `const` references fail with
   "Shortcuts does not allow variable values for this argument". Note that
   the `!` marker is NOT visible in `--action` signature output (it is
   stripped), so signatures cannot be used to detect this restriction.
   String interpolation inside the inline literal still works, so dynamic
   values go into the dict via `{varName}` interpolation.
2. Rewrite the HTTP examples in common-patterns.md and
   share-sheet-shortcut.md to pass inline dict literals in the
   `jsonRequest(...)` call, e.g.:

   ```ruby
   const response = jsonRequest(endpoint, "POST",
       {"url": "{pageUrl}"},
       {"Authorization": "Bearer {storedToken}", "Content-Type": "application/json"})
   ```

3. The fix is verified: the complete share-sheet example compiles
   end-to-end (exit 0, v2.1.0) with the `jsonRequest` call changed to
   inline dict literals and everything else unchanged:

   ```ruby
   const response = jsonRequest(endpoint, "POST", {
       "url": "{pageUrl}"
   }, {
       "Authorization": "Bearer {storedToken}",
       "Content-Type": "application/json"
   })
   ```

   All other elements of the example (import-question `text()` storage,
   `getURLs`/`getFirstItem`, `if !pageUrl` on a const, interpolated
   `endpoint` const, `getDictionary`/`getValue` response handling) compile
   as written.
