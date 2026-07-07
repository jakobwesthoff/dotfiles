---
name: actions-and-includes
description: How to discover actions via CLI, the include system, action definitions, raw actions, stdlib, and copy/paste macros
metadata:
  tags: cherri, actions, includes, http, stdlib, raw-actions, custom-actions
---

## Discovering actions via CLI

The `cherri` compiler has built-in documentation. Use these commands to
look up action signatures — they reflect the exact version installed.

Look up a specific action by name:

```bash
cherri --action=jsonRequest --no-ansi
```

Browse all actions in a category:

```bash
cherri --docs=web --no-ansi
```

Available categories: `basic`, `web`, `scripting`, `text`, `documents`,
`calendar`, `contacts`, `crypto`, `sharing`, `shortcuts`, `intelligence`,
`translation`, `pdf`, `math`, `mac`, `images`, `photos`, `music`,
`media`, `network`, `device`, `settings`, `location`, `a11y`, `dropbox`.

Filter a category by subcategory:

```bash
cherri --docs=web --subcat=HTTP --no-ansi
```

Search for glyphs:

```bash
cherri --glyph=bookmark --no-ansi
```

Use `--no-ansi` with `--action`, `--docs`, and `--glyph` to get clean
output. Also pass `--no-ansi` when compiling `.cherri` files: it
produces plain text instead of ANSI-escaped output, with no effect on
exit codes or compilation results.

Substring search: `--action=` accepts partial names and suggests matches:

```bash
cherri --action=random --no-ansi
```

This returns `randomNumber`, `getRandomItem`, etc. Use this when you
don't know the exact action name.

### Caveats about `--docs` and `--action`

- `--action` and `--docs` do NOT show which `#include` an action
  belongs to — `cherri --action=jsonRequest --no-ansi` prints only the
  title, description, enum, and signature. If unsure, search the docs
  categories one at a time with separate commands — do NOT chain
  multiple cherri calls into one. If no category listing turns it up,
  `grep -l <actionName>` over the compiler source checkout's
  `actions/*.cherri` files is the definitive answer.
- Some actions do not appear in `--docs` category output at all (e.g.,
  `randomNumber` is missing from every category). Use `--action=name`
  as fallback to confirm an action exists and get its signature.
- `cherri --action= --no-ansi` (empty name) is documented as printing
  all definitions, but on v2.3.0 it panics partway through (`index out
  of range`, exit code 2) after printing roughly a hundred entries —
  it is not a reliable way to dump the full action list. Use
  `--docs=<category>` per category, or grep the source checkout's
  `actions/*.cherri` files, instead.
- When the compiler reports "requires include: `#include 'actions/X'`"
  in an error, the suggested include may be wrong — it sometimes cycles
  through incorrect suggestions on successive compiles. If the first
  suggestion doesn't work, the definitive fix is `grep -l <actionName>`
  over the compiler source checkout's `actions/*.cherri` files.

## Include system

Actions outside the basic category require explicit includes:

```ruby
#include 'actions/web'        // HTTP requests, URLs, Safari
#include 'actions/scripting'  // dictionaries, lists, apps, numbers
#include 'actions/text'       // text manipulation, regex, rich text
#include 'actions/network'    // IP, WiFi, cellular, SSH
#include 'actions/sharing'    // share sheet, clipboard, email, SMS
#include 'actions/device'     // device details, battery
#include 'actions/documents'  // file operations, notes, QR codes
#include 'actions/location'   // GPS, maps, weather
#include 'actions/settings'   // brightness, volume, DND, appearance
#include 'actions/images'     // image editing, GIFs
#include 'actions/photos'     // photo library
#include 'actions/music'      // Apple Music playback
#include 'actions/media'      // audio, video, camera, Shazam
#include 'actions/calendar'   // events, reminders, dates, timers
#include 'actions/contacts'   // contacts, phone
#include 'actions/crypto'     // base64, hashing
#include 'actions/shortcuts'  // run/manage shortcuts
#include 'actions/intelligence' // Apple Intelligence, LLMs
#include 'actions/translation'  // translate text
#include 'actions/pdf'        // PDF creation, splitting
#include 'actions/math'       // calculations, statistics
#include 'actions/mac'        // macOS-only (shell scripts, windows)
#include 'actions/a11y'       // accessibility settings
#include 'actions/dropbox'    // Dropbox file saving
#include 'stdlib'             // standard library functions (runJS, etc.)
```

NEVER call an action without its include — the compiler will throw an
"undefined action" error. `--action=actionName --no-ansi` confirms the
action exists and shows its signature, but not its category (see
"Caveats about `--docs` and `--action`" above for how to find the
include).

### Including Cherri files

```ruby
#include 'path/to/file.cherri'
```

- File must exist and have `.cherri` extension
- Each path can only be included once — this applies to every include
  path (user files, `actions/...` categories, `stdlib`), not just
  `.cherri` files, and the dedup is global across the whole include
  tree: if the main file includes `actions/web` and a helper file it
  includes also includes `actions/web`, compilation fails with `Path
  'actions/web' has already been included.`. For multi-file projects,
  keep all `actions/...`/`stdlib` includes in the main file and none
  in helper files.
- Use `..` for parent directory paths

## Key usage patterns

### HTTP requests

```ruby
#include 'actions/web'

const headers = {
    "Authorization": "Bearer {token}",
    "Content-Type": "application/json"
}
const body = {"url": "{pageUrl}"}

// JSON POST (most common for APIs)
const response = jsonRequest("https://api.example.com", "POST", body, headers)

// GET request
const data = downloadURL("https://api.example.com/data", headers)
```

Methods: `POST`, `PUT`, `PATCH`, `DELETE`. GET uses `downloadURL()`.

`formRequest(url, method, body, headers)` sends a form-encoded
(`application/x-www-form-urlencoded`) body instead of JSON, and
`fileRequest(url, method, body, headers)` sends a file upload body —
both share `jsonRequest`'s signature shape and are defined alongside it
in `actions/web`.

Note the `dictionary!` type on HTTP action params — headers and body
(for `jsonRequest`, `formRequest`, and `fileRequest` alike) require
**literal dictionary values** (inline dicts or constants), not `@`
variable references.

### Dictionaries

```ruby
#include 'actions/scripting'

@dictVar = {"key1": "value", "count": 5}

// Bracket syntax — key MUST be a literal string, dict MUST be a variable
@val = dictVar['key1']

// getValue — works with both variables and constants for the dict,
// and supports variable keys (not just literal strings)
const dict = {"key": "value"}
const val = getValue(dict, "key")
@val2 = getValue(dictVar, someKeyVar)

// Modify and inspect
setValue(dictVar, "newKey", "newValue")
@keys = getKeys(dictVar)
@values = getValues(dictVar)
```

Use `getValue` when: the dictionary is a `const`, OR the key is a
runtime variable. Use bracket syntax only for `@var` dicts with
literal string keys.

### Lists

```ruby
#include 'actions/scripting'

@listVar = list("Item 1", "Item 2", "Item 3")
const first = getFirstItem(listVar)
const second = getListItem(listVar, 2)  // 1-indexed!
```

IMPORTANT: Shortcuts list indexes start at 1, not 0.

### Quantity fields (`qty()` syntax)

Some actions use quantity-typed parameters prefixed with `#`. These
require the `qty(value, unit)` constructor:

```ruby
#include 'actions/calendar'

// The # prefix on the type marks it as a quantity field
startTimer(qty(25, "min"))

// adjustDate uses #dateUnit
adjustDate(date, "Add", qty(7, "days"))
```

The available units depend on the enum for that quantity field. Use
`cherri --action=actionName --no-ansi` to see the exact type and
allowed values.

## Custom action definitions

For actions not built into Cherri, define them with the raw identifier
and parameter-key mappings:

```ruby
enum callType {
    'Audio',
    'Video'
}

action 'com.apple.facetime.facetime' callOnFaceTime(
    variable contact: 'WFFaceTimeContact',
    callType type: 'WFFaceTimeType' = "Video"
)

callOnFaceTime(Ask, "Audio")
```

### Definition syntax

```
action [attributes] ['identifier'] actionName(
    type[!] [?]paramName: 'WFParameterKey' [= default]
) [: outputType] [{ extra params }]
```

Attributes (optional, after `action`):
- `default` — preferred definition when multiple share same identifier
- `mac` / `!mac` — platform restriction
- `v17` / `v17>` — minimum iOS version (default); `v17<` — maximum iOS version

The `!` after type means literal value required (not variable).
The `?` before param name means optional.

### Identifier shorthand

Actions starting with `is.workflow.actions` can omit the prefix:

```ruby
action 'is.workflow.actions.alert' ...
action 'alert' ...  // equivalent
```

### Extra fixed parameters

```ruby
action 'downloadurl' jsonRequest(
    text url: 'WFURL',
    HTTPMethod ?method: 'WFHTTPMethod',
    dictionary! ?body: 'WFJSONValues',
    dictionary! ?headers: 'WFHTTPHeaders',
) {
    "WFHTTPBodyType": "JSON"
}
```

## Raw actions (one-off, no reusable definition)

```ruby
rawAction("is.workflow.actions.alert", {
    "WFAlertActionMessage": "Hello, world!",
    "WFAlertActionTitle": "Alert"
})
```

For variable values in raw action parameters, use the `${@varName}`
prefix:

```ruby
@file = nil
rawAction("is.workflow.actions.documentpicker.save", {
    "WFInput": "${@file}"
})
```

Only a single variable reference is permitted per parameter value.
Combining two (e.g. `"${@file}${@title}"`) is not caught at compile
time — it silently corrupts the output (the variable name and an
extra, unintended action get mangled into the compiled Shortcut), so
never chain multiple `${@var}` references in one value.

`${}` is ONLY for raw action variable references. NEVER use it for
normal string interpolation.

## Compiler built-in actions (always available)

These are built into the compiler — no `#include` needed:

```ruby
// Embed a file as base64 at compile time
const audioFile = embedFile("path/to/file.mp3")

// Create vCard items (for rich menus with images)
const card = makeVCard("Title", "Subtitle")
const cardWithIcon = makeVCard("Title", "Subtitle", iconImage)

// Text action — critical for storing import question values
const val = text(someInput)
```

## Standard library functions (`stdlib`)

Higher-level functions built on standard actions:

```ruby
#include 'stdlib'
#include 'actions/text'
#include 'actions/web'

// Run JavaScript in a web view
@jsResult = runJS("console.log('hello')")

// Choose from vCard-styled list (rich menu with icons)
@items = []
repeat i for 3 {
    @items += makeVCard("Title {i}", "Subtitle {i}")
}
@choice = chooseFromVCard(@items, "Prompt")
```

`stdlib` functions are plain Cherri (see `stdlib.cherri` in the
compiler source) that call regular actions internally — the compiler
does NOT resolve their action dependencies
for you. `#include 'stdlib'` alone is not enough; you must also
include whatever action categories the stdlib function you call uses
internally. `runJS` calls `replaceText()` and `urlDecode()`, so it
needs `actions/text` and `actions/web` in addition to `stdlib`.
`chooseFromVCard` needs no extra include beyond `stdlib` — the actions
it calls (`setName`, `chooseFromList`) require none. When a stdlib
function fails with a missing-include error, add the suggested
include and recompile; repeat until it succeeds, since one function
can depend on several categories.

## Copy/paste macros

Reusable code blocks without function overhead:

```ruby
copy carbon {
    alert("Hello, Cherri!")
}

paste carbon
paste carbon
```

A `paste` must come after the `copy` it references — pasting before
the declaration fails with `Unable to paste undefined copy '<name>'`.
Avoid long chains of pastables pasting other pastables.

Use pastables for code reuse WITHOUT arguments. Use functions when you
need arguments. Pastables duplicate actions at each paste site; functions
add overhead upfront but reuse efficiently.
