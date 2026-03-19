---
name: patterns-and-practices
description: Cherri best practices, efficiency tips, common patterns, compilation, signing, and anti-patterns
metadata:
  tags: cherri, best-practices, efficiency, signing, compilation, anti-patterns
---

## Efficiency at runtime

### Clear unused outputs

Add `nothing()` after actions whose output you won't use:

```ruby
someActionWithOutput()
nothing()  // prevents output from consuming memory
```

Control flow blocks (`if`, `menu`, `for`, `repeat`) add `nothing()`
automatically at the end.

### Avoid large pre-defined arrays

```ruby
// SLOW — each item creates an Add to Variable action
@items = ["a", "b", "c", "d", "e", "f", "g", "h"]

// BETTER — use a dictionary if structure allows
@data = {"items": ["a", "b", "c"]}

// BEST — build incrementally when needed
@items: array
@items += computedValue()
```

### Prefer constants over variables

Every `const` saves one Set Variable action compared to `@var`:

```ruby
// GOOD — 1 action (the action output itself)
const result = someAction()
show("{result}")

// WORSE — 2 actions (action + Set Variable)
@result = someAction()
show("{@result}")
```

## Small file size

### Use `nil` to skip optional arguments

```ruby
// GOOD — skips the optional arg, smaller output
someAction(required, nil, "third")

// WORSE — fills in the default explicitly
someAction(required, "default", "third")
```

### Use type declarations instead of empty values

```ruby
// FAST compilation, no unnecessary action
@builder: text

// SLOW compilation, creates an empty Text action
@builder = ""
```

### Use raw text when interpolation isn't needed

```ruby
// FASTER — skips interpolation parsing
@msg = 'Hello, world!'

// SLOWER — parses for {variables}
@msg = "Hello, world!"
```

## Compilation

### CLI hygiene

When invoking `cherri` from an AI agent, follow these rules to avoid
permission issues with shell command execution:

- ALWAYS write `.cherri` source to a file first, then compile from the
  file path. NEVER pipe source code into the compiler.
- ALWAYS issue each `cherri` invocation as its own separate Bash tool
  call. NEVER chain multiple `cherri` calls with `;`, `&&`, or `|`.
- NEVER append shell constructs like `2>&1`, `2>/dev/null`,
  `; echo "exit:$?"`, or `; echo "---DONE---"` to cherri commands.
  These trigger permission prompts. Just run the bare command.
- NEVER use `for` loops or other shell constructs to iterate over
  multiple `cherri` calls. Issue them as separate Bash tool calls.
- Use `--no-ansi` ONLY with `--action`, `--docs`, and `--glyph` lookups.
  Do NOT use `--no-ansi` when compiling `.cherri` files.
- Silent output (no stdout, exit code 0) means compilation succeeded.
  Error messages appear on stdout when compilation fails.

### CLI usage

```bash
cherri input.cherri                      # Compile and sign (macOS)
cherri input.cherri --skip-sign          # Compile without signing
cherri input.cherri --hubsign            # Compile and sign via HubSign (non-macOS)
cherri input.cherri --signing-server=URL # Custom signing server
cherri input.cherri --debug              # Debug mode (stack traces, plist output)
cherri input.cherri --open               # Open in Shortcuts after compile (macOS)
cherri input.cherri --comments           # Include // comments as Shortcut comment actions
cherri input.cherri --share=anyone       # Sign for public distribution (vs contacts-only default)
```

### Signing

- **macOS**: automatic via `/usr/bin/shortcuts sign`
- **Non-macOS**: use `--hubsign` for the RoutineHub signing service, or
  `--signing-server=URL` for a self-hosted
  [shortcut-signing-server](https://github.com/scaxyz/shortcut-signing-server)
- Unsigned shortcuts CANNOT be imported on iOS 15+ / macOS 12+

Signing modes (macOS):
- Default: `people-who-know-me` (contacts)
- Public: use `--share=anyone` for broad distribution

## Common patterns

### HTTP API call with response handling

```ruby
#include 'actions/web'
#include 'actions/scripting'

@token = "my-token"
const headers = {
    "Authorization": "Bearer {@token}",
    "Content-Type": "application/json"
}
const body = {"url": "{@pageUrl}"}

const response = jsonRequest(@apiEndpoint, "POST", body, headers)
const dict = getDictionary(response)
const errorField = getValue(dict, "error")

if errorField {
    alert("Failed: {errorField}", "Error")
} else {
    showNotification("Saved!", "Success")
}
```

### Extract URL from share sheet input

```ruby
#include 'actions/web'
#include 'actions/scripting'

#define inputs url, text
#define from sharesheet

// ShortcutInput may be a URL directly or text containing a URL
const urls = getURLs(ShortcutInput)
const pageUrl = getFirstItem(urls)

if !pageUrl {
    alert("No URL found in the shared content", "Error")
    stop()
}
```

Note: `getFirstItem()` requires `#include 'actions/scripting'`.

### Dictionary manipulation

```ruby
#include 'actions/scripting'

@dictVar = {
    "key1": "value",
    "key2": 5,
    "key3": true
}

// Read
@value = @dictVar['key1']              // bracket syntax (raw string only)
@value = getValue(@dictVar, "key1")    // function (supports variable keys)

// Write
setValue(@dictVar, "key4", "new value")

// Inspect
@keys = getKeys(@dictVar)
@values = getValues(@dictVar)
```

### Menu-based user interaction

```ruby
menu "What would you like to do?" {
    item "Add Bookmark":
        alert("Adding bookmark...")
    item "Search":
        alert("Searching...")
    item "Cancel":
        stop()
}
```

### VCard menus (rich menus with images)

```ruby
#include 'stdlib'
#include 'actions/scripting'
#include 'actions/text'
#include 'actions/web'

const icon = embedFile("assets/icon.png")

@items = []
repeat i for 3 {
    @items += makeVCard("Title {i}", "Subtitle {i}", icon)
}
@menuItems = "{@items}"
@vcf = setName(@menuItems, "menu.vcf")
@contact = @vcf.contact
@chosenItem = chooseFromList(@contact, "Prompt")
alert(@chosenItem, "You chose:")
```

### System setting toggles

```ruby
#include 'actions/settings'

setBrightness(0.75)
setVolume(0.5)
DNDOn()
DNDOff()
lightMode()
darkMode()
```

## Compiler quirks and workarounds

These are known compiler behaviors that differ from what you might expect.

### Action return values need explicit coercion for comparisons

Action outputs cannot be used directly in numeric comparisons. Wrap them
with `number()` and store in a typed variable:

```ruby
#include 'actions/device'

// WRONG — compiler rejects action output in comparison
const level = getBatteryLevel()
if level < 20 {}

// CORRECT — coerce and store in typed variable
@level: number
@level = number(getBatteryLevel())
if @level < 20 {}
```

### Boolean-returning actions must use `@var`, not `const`

Some actions that return booleans (e.g., `isCharging()`,
`connectedToCharger()`) crash the compiler when assigned to `const`.
Always use `@var`:

```ruby
// WRONG — compiler panic
const charging = isCharging()

// CORRECT
@charging = isCharging()
```

### Avoid calling the same detail-getter multiple times in one expression

Calling actions like `getWeatherDetail()` multiple times on the same
source variable can crash the compiler. Workaround: interleave each
call with a variable append:

```ruby
// WRONG — may crash
@msg = "Temp: {getWeatherDetail(weather, "Temperature")} Wind: {getWeatherDetail(weather, "Wind Speed")}"

// CORRECT — serialize calls via variable building
@msg: text
@temp = getWeatherDetail(weather, "Temperature")
@msg += "Temp: {@temp}\n"
@wind = getWeatherDetail(weather, "Wind Speed")
@msg += "Wind: {@wind}"
```

### `runShellScript()` requires `input` even when unused

The `input` parameter is not optional. Pass `nil` when no stdin is needed:

```ruby
#include 'actions/mac'

@output = runShellScript("ls -la", nil)
```

### `detectLanguage()` returns human-readable names

Returns `"English"`, `"German"`, etc. — NOT locale codes like `en_US`.
But `translate()` uses locale codes for `to`/`from`. Plan accordingly.

### Strict `number` vs `float` type separation

`number` means integer, `float` means decimal. The compiler enforces
this strictly in both directions:

```ruby
// WRONG
wait(0.2)           // number param rejects float literal
setBrightness(1)    // float param rejects integer literal

// CORRECT
wait(1)             // integer for number param
setBrightness(1.0)  // decimal for float param
```

### Globals cannot be assigned to `const`

`ShortcutInput`, `CurrentDate`, `Clipboard`, `Device` are variable
references, not action outputs. They must use `@var`:

```ruby
// WRONG — "Type variable values cannot be constants"
const input = ShortcutInput

// CORRECT
@input = ShortcutInput
```

### `#include 'actions/music'` may be broken

The `seek` action definition references `timerDuration` as an unknown
type, causing the entire include to fail. Workaround: define only the
needed music actions manually:

```ruby
action 'is.workflow.actions.getmusicdetail' getMusicDetail(
    variable music: 'WFInput',
    text! detail: 'WFMusicDetailType'
)
```

### Curly braces in strings are always parsed as references

Both double-quoted and single-quoted strings treat `{N}` as a variable
reference attempt. This means regex quantifiers like `{50}` are
unusable in string literals — use character classes or loops instead.

### Menu item bodies must be statements

Bare string literals in menu items fail. Use variable assignment or
action calls:

```ruby
// WRONG — "Illegal character"
menu "Pick" {
    item "A":
        "Hello"
}

// CORRECT
@result: text
menu "Pick" {
    item "A":
        @result = "Hello"
}
```

### No `break` statement in loops

Loops always run to completion. Use a counter variable with an `if`
guard to skip iterations after a condition is met.

### `speak()` is in `actions/text`, not `actions/media`

### `--docs=photos` may be empty (compiler bug)

Some compiler versions have a broken docs generator for the photos
category — `--docs=photos` shows no actions even though they exist.
If `--docs=photos` returns actions, use that. If it's empty, these
are the known photo actions (look up signatures with `--action=`):
`savePhoto`, `selectPhotos`, `deletePhotos`, `createAlbum`,
`renameAlbum`, `searchPhotos`, `getLastImport`, `getLatestPhotos`,
`getLatestVideos`, `getLatestScreenshots`, `getLatestBursts`,
`getLatestLivePhotos`, `removeFromAlbum`.

## Anti-patterns

### FORBIDDEN: Wrong string interpolation syntax

```ruby
// FORBIDDEN — this is NOT JavaScript or shell
@msg = "Hello, ${name}!"

// CORRECT — use {varName} or {@varName}
@msg = "Hello, {@name}!"
```

### Variable referencing — `@` prefix is optional

Both bare names and `@`-prefixed forms work when referencing variables:

```ruby
// Both are valid:
alert(message, "Title")
alert(@message, "Title")
```

Constants always use bare names (no `@`).

### FORBIDDEN: Missing includes

```ruby
// FORBIDDEN — will fail to compile
const response = jsonRequest("https://api.example.com", "POST", body)

// CORRECT — include the action category first
#include 'actions/web'
const response = jsonRequest("https://api.example.com", "POST", body)
```

### FORBIDDEN: Using `@var` for immutable values

```ruby
// FORBIDDEN — wastes an action
@url = "https://api.example.com"

// CORRECT — use const for values that don't change
const url = "https://api.example.com"
```

### NEVER: Inline import question identifiers in strings

```ruby
// NEVER — import questions cannot be inlined
#question token "Token" ""
const header = "Bearer {token}"  // WILL NOT WORK

// CORRECT — store in a Text action first
#question token "Token" ""
const tokenValue = text(token)
const header = "Bearer {tokenValue}"
```

Import questions can only be used ONCE as a direct action argument:

```ruby
#question name "What is your name?" "Brandon"
#question age "What is your age?" "24"

alert(name, "Name")  // direct action argument — OK
alert(age, "Age")    // direct action argument — OK
```

### NEVER: Mix AND and OR conditions

```ruby
// NEVER — Shortcuts only supports all-AND or all-OR
if @a == "x" && @b == "y" || @c == "z" {
    // compiler error
}

// CORRECT — nest if needed
if @a == "x" && @b == "y" {
    if @c == "z" {
        // ...
    }
}
```

### NEVER: Nest action calls as arguments

```ruby
// NEVER — crashes the compiler
@chosen = chooseFromList(list("A", "B", "C"), "Pick one")

// CORRECT — assign to variable first, then pass
@items = list("A", "B", "C")
@chosen = chooseFromList(items, "Pick one")
```

Always assign action results to a variable or constant before passing
them as arguments to another action.

### NEVER: Use bracket syntax on constants

```ruby
// NEVER — bracket syntax only works on variables
const dict = {"key": "value"}
const val = dict['key']  // WRONG

// CORRECT — use getValue for constants
const val = getValue(dict, "key")
```

