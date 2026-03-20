---
name: compiler-quirks
description: Known Cherri compiler bugs, unexpected behaviors, and their workarounds
metadata:
  tags: cherri, compiler, bugs, workarounds, quirks
---

Read this when a compile fails unexpectedly or behavior differs from
what the language docs suggest. These are known issues with workarounds.

## Expressions cannot contain action calls

Action return values cannot appear as operands in arithmetic
expressions. Store the result first:

```ruby
// WRONG — "Value of type 'action' not allowed in expression"
@cents = number(@amountText) * 100

// CORRECT
@raw: number
@raw = number(@amountText)
@cents = @raw * 100
```

The same applies to passing action calls as arguments to other actions
(nested calls crash the compiler). Always assign to a variable first.

## Action return values need explicit coercion for comparisons

Action outputs cannot be used directly in numeric comparisons. Wrap
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

Same applies to using action outputs in arithmetic expressions — store
in a typed `@var` first.

## Boolean-returning actions must use `@var`, not `const`

Some actions that return booleans (e.g., `isCharging()`,
`connectedToCharger()`) crash the compiler when assigned to `const`.
Always use `@var`:

```ruby
// WRONG — compiler panic
const charging = isCharging()

// CORRECT
@charging = isCharging()
```

## Avoid calling the same detail-getter multiple times in one expression

Calling actions like `getWeatherDetail()` multiple times on the same
source variable can crash the compiler. Workaround: interleave each
call with a variable append:

```ruby
// WRONG — may crash
@msg = "Temp: {getWeatherDetail(@weather, "Temperature")} Wind: {getWeatherDetail(@weather, "Wind Speed")}"

// CORRECT — serialize calls via variable building
@msg: text
@temp = getWeatherDetail(@weather, "Temperature")
@msg += "Temp: {@temp}\n"
@wind = getWeatherDetail(@weather, "Wind Speed")
@msg += "Wind: {@wind}"
```

## `runShellScript()` requires `input` even when unused

The `input` parameter is not optional. Pass `nil` when no stdin is
needed:

```ruby
#include 'actions/mac'

@output = runShellScript("ls -la", nil)
```

## `detectLanguage()` returns human-readable names

Returns `"English"`, `"German"`, etc. — NOT locale codes like `en_US`.
But `translate()` uses locale codes for `to`/`from`. Plan accordingly.

## Strict `number` vs `float` type separation

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

Check the action signature with `cherri --action=name --no-ansi` to
see whether a parameter expects `number` or `float`.

## Globals cannot be assigned to `const`

`ShortcutInput`, `CurrentDate`, `Clipboard`, `Device` are variable
references, not action outputs. They must use `@var`:

```ruby
// WRONG — "Type variable values cannot be constants"
const input = ShortcutInput

// CORRECT
@input = ShortcutInput
```

## `#include 'actions/music'` may be broken

Some compiler versions have a broken `seek` action definition that
references `timerDuration` as an unknown type, causing the entire
include to fail. Workaround: define only the needed music actions
manually:

```ruby
action 'is.workflow.actions.getmusicdetail' getMusicDetail(
    variable music: 'WFInput',
    text! detail: 'WFMusicDetailType'
)
```

## Curly braces in strings are always parsed as references

Both double-quoted and single-quoted strings treat `{N}` as a variable
reference attempt. This means regex quantifiers like `{50}` are
unusable in string literals — use character classes or loops instead.

## Menu item bodies must be statements

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

## No `break` statement in loops

Loops always run to completion. Use a counter variable with an `if`
guard to skip iterations after a condition is met.

## `speak()` is in `actions/text`, not `actions/media`

## `--docs=photos` may be empty (compiler bug)

Some compiler versions have a broken docs generator for the photos
category — `--docs=photos` shows no actions even though they exist.
If `--docs=photos` returns actions, use that. If it's empty, these
are the known photo actions (look up signatures with `--action=`):
`savePhoto`, `selectPhotos`, `deletePhotos`, `createAlbum`,
`renameAlbum`, `searchPhotos`, `getLastImport`, `getLatestPhotos`,
`getLatestVideos`, `getLatestScreenshots`, `getLatestBursts`,
`getLatestLivePhotos`, `removeFromAlbum`.

## `variable` typed params reject string literals

Some action parameters are typed `variable` (not `text`), meaning they
require a variable/constant reference, not a string literal. Store the
value in a `@var` first:

```ruby
// WRONG — hash() takes variable input, not a string literal
const h = hash("my text", "SHA256")

// CORRECT
@text = "my text"
const h = hash(@text, "SHA256")
```

Similarly, `sendEmail()` requires a `variable` for the contact param.
Use `emailAddress()` to create the right type:

```ruby
#include 'actions/sharing'

const recipientText = prompt("Email:")
const recipient = emailAddress("{recipientText}")
sendEmail(recipient, "", "Subject", "Body", false, true)
```

## Custom action definitions for missing functionality

When a built-in action doesn't accept the parameters you need, define
a custom action binding with the raw Shortcuts identifier:

```ruby
// addQuickReminder() takes no args — useless for setting title
// Define a custom binding with the WFInput parameter:
action 'is.workflow.actions.addnewreminder' addNewReminder(
    text title: 'WFInput'
)

addNewReminder("Buy groceries")
```

Find Shortcuts action identifiers by inspecting existing shortcuts or
searching online. The `action 'identifier' name(...)` syntax lets you
bind any parameter key.

## Output filename derives from `#define name`

The compiled filename is always based on `#define name`, not the source
filename. With `--skip-sign`, `_unsigned` is appended. The `-o` flag
does not override this.

## `showNotification` needs no include

`showNotification()` is in the basic category — no `#include` needed.
This is easy to confuse since `setClipboard()`, `share()`, and other
similar "output" actions require `#include 'actions/sharing'`.

## Some actions are missing from `--docs` output

Not all actions appear when browsing categories with `--docs=`. For
example, `randomNumber` does not show up in any category. Use
`cherri --action=name --no-ansi` to confirm an action exists and get
its signature. The `--action=` flag supports substring matching.

## Include error messages may be misleading

When the compiler reports "requires include: `#include 'actions/X'`",
the suggested include may be wrong. The compiler sometimes cycles
through incorrect suggestions on successive compiles. If the first
suggestion doesn't work, try `#include 'actions/scripting'` as a
common fallback, or use `cherri --action=name --no-ansi` to check
whether the action is a built-in that needs no include.

## `formatNumber` has a deep dependency chain

`formatNumber` requires multiple includes (settings, shortcuts, text,
web) — the compiler reveals them one at a time. Consider manual
arithmetic for formatting instead:

```ruby
// Instead of formatNumber(value, 2), do:
@cents: number
@cents = @value * 100
@rounded: number
@rounded = round(@cents)
@formatted: number
@formatted = @rounded / 100
```
