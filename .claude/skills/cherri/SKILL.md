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

## Action catalog

Complete action signatures and include requirements, organized by domain:

- [references/actions-basic.md](references/actions-basic.md) — Core actions (no include needed): output, alerts, prompts, count, search
- [references/actions-web.md](references/actions-web.md) — HTTP requests, URLs, Safari, RSS, Giphy
- [references/actions-scripting.md](references/actions-scripting.md) — Dictionaries, lists, numbers, passwords
- [references/actions-text.md](references/actions-text.md) — Text manipulation, regex, rich text, dictation, speech
- [references/actions-files.md](references/actions-files.md) — File operations, archives, notes, QR codes, Dropbox
- [references/actions-datetime.md](references/actions-datetime.md) — Calendar events, reminders, dates, timers, formatting
- [references/actions-contacts.md](references/actions-contacts.md) — Contacts, phone, sharing, clipboard, email, SMS, AirDrop
- [references/actions-images.md](references/actions-images.md) — Image editing, GIFs, photo library
- [references/actions-audio-video.md](references/actions-audio-video.md) — Music playback, audio/video recording, camera, Shazam, podcasts
- [references/actions-device.md](references/actions-device.md) — Device info, settings, network, location, weather, accessibility
- [references/actions-ai.md](references/actions-ai.md) — Apple Intelligence LLMs, Writing Tools, translation
- [references/actions-math-crypto.md](references/actions-math-crypto.md) — Math, statistics, rounding, hashing, base64, PDF
- [references/actions-macos.md](references/actions-macos.md) — macOS-only: shell scripts, AppleScript, windows, Shortcuts management
