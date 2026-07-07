---
name: compiler-quirks
description: Known Cherri compiler bugs, unexpected behaviors, and their workarounds
metadata:
  tags: cherri, compiler, bugs, workarounds, quirks
---

This file's baseline verification version is Cherri v2.3.0
(2026-07-07). Entries without a version tag are current as of that
baseline. Entries tagged with an older version were observed on that
version and have not been individually re-verified since; re-test
before relying on them after a compiler upgrade.

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
(nested calls crash the compiler with a Go panic, exit code 2). Always
assign to a variable first.

Action calls are also not allowed inline inside string interpolation.
`{...}` in a string accepts only a variable/constant/global reference,
never a call:

```ruby
// WRONG — "Undefined inline reference 'getBatteryLevel()'"
@msg = "Battery: {getBatteryLevel()}"

// CORRECT — store the result first
@battery = getBatteryLevel()
@msg = "Battery: {@battery}"
```

This applies regardless of repetition: calling the same action (e.g.
`getWeatherDetail()`) multiple times on the same source variable is
fine as long as each call result is stored in a variable first; nothing
about repeated calls specifically triggers a failure.

## Action return values need explicit coercion for comparisons

Action outputs cannot be used directly in numeric comparisons. Wrap
with `number()` and store in a typed variable:

```ruby
#include 'actions/device'

// WRONG — compiler rejects action output in comparison
const level = getBatteryLevel()
if level < 20 {}

// CORRECT — coerce, but do NOT nest the call: store the action's own
// output first, then wrap that variable with number()
const raw = getBatteryLevel()
@level: number
@level = number(raw)
if @level < 20 {}
```

Note the two-step coercion: `@level = number(getBatteryLevel())` is a
nested action call (`number()` wrapping `getBatteryLevel()`) and
crashes the compiler with the same Go panic as any other nested call
(see "Expressions cannot contain action calls" above). Store the inner
action's result in its own variable first.

Same applies to using action outputs in arithmetic expressions — store
in a typed `@var` first.

## `runShellScript()`'s `input` parameter is optional

`runShellScript(text script, variable ?input, ...)` — `input` can be
omitted:

```ruby
#include 'actions/mac'

@output = runShellScript("ls -la")
```

## `translate()`'s locale codes are a strict 19-value enum

`translate(text, to, ?from)` requires `actions/translation`. The
`to`/`from` parameters are typed with an enum of exactly 19 locale
codes; any other string literal is a compile error:

```
Error: Invalid value 'English' for argument 'to'.
```

```
ar_AE, zh_CN, zh_TW, nl_NL, en_GB, en_US, fr_FR, de_DE, id_ID, it_IT,
jp_JP, ko_KR, pl_PL, pt_BR, ru_RU, es_ES, th_TH, tr_TR, vn_VN
```

Two codes are nonstandard: `jp_JP` (not ISO `ja_JP`) and `vn_VN` (not
ISO `vi_VN`).

The enum check only applies to string literals. A variable argument
skips it and compiles regardless of content:

```ruby
#include 'actions/translation'

@t = "Hello"
const lang = detectLanguage(@t)
translate(@t, lang)  // compiles even though `lang`'s value is unchecked
```

This means a locale-code mistake routed through a variable (e.g. the
output of `detectLanguage()`) surfaces only at runtime, not at compile
time. What `detectLanguage()` actually returns at runtime (a locale
code, a human-readable language name, or something else) is not
verified here — verifying it requires running the compiled shortcut
on-device.

## `number` vs `float` type strictness is one-directional

`number` means integer, `float` means decimal, but the compiler only
enforces the mismatch one way: a `float`-typed parameter rejects an
integer literal, while a `number`-typed parameter now accepts a
decimal literal.

```ruby
// WRONG — float param rejects integer literal
setBrightness(1)
// Error: Invalid value 1 (number) for argument 'brightness' (float).

// Both compile — number param accepts a decimal literal too
wait(0.2)
wait(1)

// CORRECT — decimal literal for a float param
setBrightness(1.0)
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

## Curly braces in double-quoted strings are always parsed as references

This means regex quantifiers like `{50}` are unusable in a
double-quoted string literal:

```ruby
// WRONG — "Undefined inline reference '50'"
@a = "a{50}"
```

Single-quoted (`rawtext`) strings behave differently by context:

- A single-quoted literal passed directly as an action argument does
  NOT get its braces parsed — `show('a{50}')` compiles.
- A single-quoted literal assigned to a variable and never passed
  anywhere compiles fine — braces are not parsed at declaration.
- A single-quoted variable then passed to an action still fails, but
  for an unrelated reason: the `rawtext`/`text` parameter mismatch
  (see "Raw text" in language-fundamentals.md), not brace parsing. The
  same failure happens with brace-free raw text.

Use character classes or repeat loops instead of `{n}` quantifiers
wherever the string reaches a double-quoted literal or a passed
variable.

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

## `variable` typed params reject string literals

Some action parameters are typed `variable` (not `text`), meaning they
require a variable/constant reference, not a string literal. Store the
value in a `@var` first:

```ruby
#include 'actions/crypto'

// WRONG — hash() takes variable input, not a string literal
const h = hash("my text", "SHA256")
// Error: Invalid value "my text" (text) for argument 'input' (variable).

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

## Confirming an action exists

`cherri --docs=<category>` lists every action in a category, and
`cherri --action=name --no-ansi` confirms whether a specific action
exists and shows its signature (the flag supports substring matching).
When an action fails to compile with "requires include", the suggested
`#include` line is the category to add.

## Multi-line `function` parameter lists fail to parse

A `function` signature whose parentheses span multiple lines fails
with an unrelated-looking parser error, regardless of parameter count
or modifiers:

```ruby
// WRONG — "Illegal character 'f'"
function myFunc(
    text a,
    text b
) {
    show(@a)
}
```

Keep the full parameter list on one line:

```ruby
// CORRECT
function myFunc(text a, text b) {
    show(@a)
}
```
