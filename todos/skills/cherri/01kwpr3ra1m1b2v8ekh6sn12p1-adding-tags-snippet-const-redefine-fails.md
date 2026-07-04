# share-sheet-shortcut.md "Adding tags" snippet fails: constants cannot be redefined across if/else branches

**Skill**: cherri
**File**: `/Users/jakob/dotfiles/.claude/skills/cherri/references/share-sheet-shortcut.md`, section "Adapting the pattern" (subsections "Adding tags or categories" and "Adding page title")

**Current state**: The "Adding tags or categories" snippet declares
`const body = {...}` in both branches of an if/else:

```ruby
@tags = prompt("Tags (comma-separated, or leave empty):", "Text", "")

if @tags {
    const body = { "url": "{pageUrl}", "tags": "{@tags}" }
} else {
    const body = { "url": "{pageUrl}" }
}
```

**Problem**: This does not compile. Cherri constants are single-assignment
with no branch-local scoping, so the second `const body` is rejected. The
skill nowhere states that constants cannot be redefined. On top of that,
even a single `const body` could not be passed to `jsonRequest` (see todo
`01kwpdccw0zs4w8b8x2ddjddbz-jsonrequest-const-dict-args-fail.md`), so the
snippet is doubly broken as a template.

**Grounding** (Cherri Compiler v2.1.0, commit 2ca7dfe, test compiles with
`--skip-sign --no-ansi`, 2026-07-04):

- The snippet (with `@pageUrl` declared and `#include 'actions/web'`)
  fails: `Error: Cannot redefine constant 'body'. (11:15)`, exit 1.
- Secondary, same section: the "Adding page title" snippet compiles but
  emits `Warning: Value for action argument 'separator' is the same as
  the default value.` because `splitText(inputText, "\n")` passes the
  documented default (`splitText(..., text ?separator = "\n")` per
  `cherri --action=splitText`). Dropping the second argument removes the
  warning.

**Proposed change**:
1. Rewrite the tags snippet without const redefinition and without
   passing a dict variable to `jsonRequest` — e.g. one `jsonRequest`
   call per branch with the dictionary written inline, or a single
   inline dict where `tags` is interpolated from a `@tags` variable
   that is set to empty when the user skips the prompt. Verify the
   replacement compiles standalone.
2. Change `splitText(inputText, "\n")` to `splitText(inputText)` in the
   "Adding page title" snippet.
3. Add one line to language-fundamentals.md's Constants section:
   constants cannot be reassigned or redefined, including once per
   if/else branch (`Cannot redefine constant '<name>'.`); use `@var`
   when a value differs per branch.
