---
name: shortcut-metadata
description: Cherri #define directives, import questions, input/output types, share sheet and workflow configuration
metadata:
  tags: cherri, define, metadata, glyph, color, sharesheet, inputs, outputs, questions
---

## Shortcut icon

### Color

```ruby
#define color blue
```

Available colors: `red`, `darkorange`, `orange`, `yellow`, `green`, `teal`,
`lightblue`, `blue`, `darkblue`, `violet`, `purple`, `pink`, `taupe`,
`gray`, `darkgray`.

### Glyph

```ruby
#define glyph bookmark
```

Browse glyphs at [glyphs.cherrilang.org](https://glyphs.cherrilang.org/)
or search via CLI:

```bash
cherri --glyph=bookmark --no-ansi
```

Verified glyphs: `bookmark`, `globe`, `star`, `smileyFace`,
`chainlink`, `airplane`, `paperAirplane`, `checklist`,
`circledCheckmark`, `circledPlus`.

NEVER guess glyph names from SF Symbols — Cherri uses its own
identifiers. Always verify with `cherri --glyph=name --no-ansi`.

## Input and output types

Define what content types the Shortcut accepts and produces:

```ruby
#define inputs text, url
#define outputs text
```

Available content item types: `app`, `article`, `contact`, `date`,
`dictionary`, `email`, `folder`, `file`, `image`, `itunes`, `location`,
`maplink`, `media`, `number`, `pdf`, `phonenumber`, `richtext`, `url`,
`webpage`, `text`.

Inputs default to ALL types if not specified. Outputs default to NONE.

## No-input behavior

Define what happens when the Shortcut runs without input:

```ruby
// Stop and respond with a message
#define noinput stopwith "Please share a URL with this shortcut"

// Fall back to clipboard
#define noinput getclipboard

// Ask the user for a specific type
#define noinput askfor url
```

## Workflows (where the Shortcut appears)

```ruby
#define from sharesheet, spotlight
```

Available workflows:
- `menubar` — macOS menu bar
- `quickactions` — Quick Actions
- `sharesheet` — iOS/macOS Share Sheet
- `notifications` — Notification Center widget
- `sleepmode` — Sleep Mode
- `watch` — Apple Watch
- `onscreen` — Receive On-Screen Content
- `search` — Show in Search/Spotlight
- `spotlight` — Accept input from Spotlight search

For share sheet shortcuts, ALWAYS include `sharesheet` in the `from`
definition.

### Quick action types

```ruby
#define from quickactions
#define quickactions finder, services
```

## Shortcut name

Override the filename-based name:

```ruby
#define name Add to Squirly
```

This produces `Add to Squirly.shortcut` regardless of the `.cherri` filename.

## Platform targeting

```ruby
#define mac true   // macOS-only, errors on iOS-only actions
#define mac false  // iOS-only, errors on macOS-only actions
```

## Minimum iOS version

```ruby
#define version 16.0
```

Warns if you use actions unsupported in the target version.

## Import questions (first-run setup)

Import questions prompt the user ONCE when they first install the Shortcut.
Values persist across runs.

```ruby
#question apiUrl "Enter your Squirly API URL" "https://squirly.example.com"
#question apiToken "Enter your API token" ""
```

Usage: reference the identifier as an action argument:

```ruby
#question name "Enter your name" "User"
alert(name, "Hello")
```

IMPORTANT: Import question values can only be used ONCE as a direct action
argument. They CANNOT be used as inline variables in strings or as variable
values.

### Storing question values for reuse

To use an import question value multiple times or in string interpolation,
store it in a Text action first:

```ruby
#question apiToken "Enter your API token" ""
const token = text(apiToken)

// Now `token` can be used in strings
const authHeader = "Bearer {token}"
```

This is the ONLY way to use import question values in string interpolation.
NEVER try to inline a `#question` identifier directly in a string.

## Importing actions from installed apps

Use `#import` to access actions provided by third-party apps installed on
the device. This works natively on macOS (reads the local Shortcuts
toolkit database).

```ruby
// Import by bundle identifier
#import 'com.sindresorhus.Color-Picker'

// Or by app name as shown in Shortcuts
#import 'Color Picker'

// Import standard Shortcuts actions (usually not needed — prefer #include)
#import 'is.workflow.actions'
```

After importing, search available actions with the CLI:

```bash
cherri file.cherri --action=colorpicker
```

Use `--toolkit-locale=` to set the language for imported actions.

Note: `#import` reads from the device's Shortcuts toolkit DB. On
non-macOS platforms, use `--toolkit=` to point to a macOS-sourced DB.
Prefer `#include 'actions/...'` for standard actions — `#import` is
primarily for third-party app integrations.

## Complete share sheet shortcut metadata

A typical share sheet shortcut for Squirly:

```ruby
#define name Add to Squirly
#define color blue
#define glyph bookmark
#define inputs url, text
#define from sharesheet
#define noinput askfor url

#question apiUrl "Enter your Squirly instance URL" "https://app.squirly.example.com"
#question apiToken "Paste your API token" ""
```
