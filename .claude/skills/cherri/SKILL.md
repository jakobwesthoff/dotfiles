---
name: cherri
description: >-
  Write, edit, and debug Cherri (.cherri) iOS Shortcut source files. Use when
  working with Shortcuts, .cherri files, or the share sheet integration.
---

## When to use

Use this skill when creating or modifying `.cherri` files, building iOS
Shortcuts, or working on the Squirly share sheet integration.

Cherri is a compiled language that produces signed `.shortcut` files for
iOS/macOS. Source files use the `.cherri` extension and compile via the
`cherri` CLI.

## Quick orientation

Cherri looks like a C-style scripting language with these key differences:

- **Variables** use `@` prefix for declaration: `@name = "value"`
- **Constants** (magic variables) use `const`: `const x = action()`
- **String interpolation** uses `{varName}` inside double-quoted strings (no `$`)
- **Includes** use `#include 'actions/web'` for action categories
- **Definitions** use `#define` for shortcut metadata (color, glyph, inputs)
- **Import questions** use `#question` for first-run setup prompts

## Critical rules

- NEVER use `${}` for string interpolation. Cherri uses `{varName}`.
- NEVER omit `#include` statements. Actions outside basic require explicit includes.
- NEVER use `@variable` when the value won't change. Use `const` for smaller shortcuts.
- NEVER use bracket syntax (`dict['key']`) on constants — use `getValue(dict, "key")` instead.
- ALWAYS use `const` over `@var` when the value is assigned once and never mutated.
- ALWAYS add `nothing()` after actions whose output you won't use.
- ALWAYS use `text()` to store import question values before using them in string interpolation.

## Variable referencing

Variables are declared with `@` prefix. When referencing them later (in
action arguments, conditions, string interpolation), both the bare name
and `@`-prefixed form work:

```ruby
@myVar = "hello"
const myConst = "hello"

// Both forms work for variables:
alert(myVar, "Title")       // bare name
alert(@myVar, "Title")      // @prefix — also valid
show("{myVar}")             // interpolation without @
show("{@myVar}")            // interpolation with @ — also valid

// Constants always use bare name:
alert(myConst, "Title")
show("{myConst}")
```

## Reference files

- [references/language-fundamentals.md](references/language-fundamentals.md) — Variables, constants, types, control flow, functions, string interpolation, globals
- [references/actions-and-includes.md](references/actions-and-includes.md) — Standard library actions, includes, HTTP requests, action definitions, stdlib
- [references/shortcut-metadata.md](references/shortcut-metadata.md) — #define directives, import questions, input/output types, share sheet config
- [references/patterns-and-practices.md](references/patterns-and-practices.md) — Best practices, efficiency tips, common patterns, compilation, signing, anti-patterns
- [references/share-sheet-shortcut.md](references/share-sheet-shortcut.md) — Complete pattern for building a share sheet bookmark shortcut with API integration

## Looking up actions

ALWAYS use the `cherri` CLI to look up action signatures — it reflects
the exact compiler version installed and is the source of truth.

```bash
# Look up a specific action
cherri --action=jsonRequest --no-ansi

# Browse all actions in a category
cherri --docs=web --no-ansi

# Search for a glyph
cherri --glyph=bookmark --no-ansi
```

Categories: `basic`, `web`, `scripting`, `text`, `documents`, `calendar`,
`contacts`, `crypto`, `sharing`, `shortcuts`, `intelligence`, `translation`,
`pdf`, `math`, `mac`, `images`, `photos`, `music`, `media`, `network`,
`device`, `settings`, `location`, `a11y`, `dropbox`.
