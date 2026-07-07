---
name: language-fundamentals
description: Cherri language basics — variables, constants, types, control flow, functions, string interpolation
metadata:
  tags: cherri, variables, constants, types, control-flow, functions, strings
---

## Comments

```ruby
// single-line comment

/* block
   comment */

comment('always included, regardless of --comments')
```

`//` and `/* */` comments are excluded from the compiled Shortcut by
default (to minimize file size). Pass `--comments` / `-c` to the
compiler to include them as Shortcut comment actions instead.

`comment('...')` adds a comment action to the shortcut unconditionally
(independent of the `--comments` flag). Its argument is `rawtext`
(single-quoted) — a double-quoted argument fails:

```ruby
comment("double quoted")
// Error: Invalid value "double quoted" (text) for argument 'text' (rawtext).
```

## Variables (`@` prefix)

Variables create a **Set Variable** action in Shortcuts. They are mutable.

```ruby
@name = "Alice"
@count = 0
@items: array

// Mutate
@count += 1
@count -= 1
@count *= 2
@count /= 2
@name += " Smith"
@items += "new item"
```

### Referencing variables

Variable references must be prefixed with `@` everywhere except inside
double-quoted string interpolation, where a bare name also compiles,
with no warning. A bare name used anywhere else (a direct action
argument, an `if` condition, a `for` loop header, a variable-to-variable
assignment) is a hard compile error:

```
Error: Unknown reference 'textVar'. Variable references must be prepended with @.
```

```ruby
@textVar = "test"
@intVar = 42

alert(@textVar, "Title")      // @prefix required as a direct argument

show("{textVar}")             // interpolation: bare name also works
show("{@textVar}")            // interpolation: @prefix also works

if @intVar > 5 {}             // @prefix required in conditions

@listVar = list("item 1", "item 2", "item 3")
for item in @listVar {}       // @prefix required in loop headers
```

Constants are the exception to the exception: they are always
referenced by bare name, in any context (see Constants below).

### Variable assignment from other variables

```ruby
@original = "test"
@copy = @original             // @prefix required
```

### Expression operands

```ruby
@intVar = 42
@expVar = 54 * @intVar + (6 * 7)
```

### Declaring without a value

Faster compilation than empty typed values:

```ruby
@builder: text       // typed, no value — fastest for typed empty
@empty = nil         // explicit empty
@raw                 // no type, no value
```

NEVER use `@variable = ""` or `@variable = []` when you can use type
declarations — they compile slower.

## Constants (magic variables)

Constants reference the output of an action directly. They produce smaller
shortcuts because they skip the Set Variable action.

```ruby
const message = "Hello, Cherri!"
const result = someAction()
```

Constants are referenced **without** `@` prefix — they use bare identifiers:

```ruby
const immutable = 5
@stringVar = "text {immutable}"
number(immutable)
```

ALWAYS prefer `const` when the value is assigned once and never mutated.

Constants CANNOT be arrays (arrays require Add to Variable) or variable
references (the value can change).

Constants cannot be reassigned or redefined, including once per
if/else branch — a second `const name = ...` anywhere in scope fails
with `Cannot redefine constant 'name'.`; use `@var` when a value
differs per branch.

## String interpolation

Use `{variableName}` inside double-quoted strings. Both `{varName}` and
`{@varName}` work for variables:

```ruby
@user = "Alice"
@greeting = "Hello, {user}!"

const immutable = 5
@mixed = "text {user} {immutable}"
```

NEVER use `${}`, `%s`, `format!()`, or any other interpolation syntax.
Cherri uses bare braces: `{varName}`.

### Type coercion in strings

```ruby
@number = 5
@text = @number.text
@numberText = "Number: {@number.text}"
```

### Key access (globals and dictionaries)

Access dictionary keys or global properties:

```ruby
@deviceOS = Device['OS']
@versionNumber = Device['System Version'].text
@osVersion = "{Device['OS']} {Device['System Version']}"

@dictVar = {"key1": "value"}
@value = @dictVar['key1']
```

### Raw text (no interpolation)

Single-quoted strings skip interpolation and compile faster:

```ruby
@raw = 'i\'m not allowed inline variables, new lines, etc. but i compile faster!'
```

A variable assigned a single-quoted string has type `rawtext`, not
`text`. A `rawtext` variable:

- Compiles fine when declared, and can be interpolated into a
  double-quoted string (`"{raw}"` or `"{@raw}"`).
- CANNOT be passed via `@` to a parameter typed `text` (most action
  parameters):
  ```ruby
  @plain = 'abc'
  alert(@plain, "Title")
  // Error: Invalid variable value abc (rawtext) for argument 'alert' (text).
  ```
- CANNOT be used directly in a conditional (`==`, `contains`, etc.);
  `rawtext` is not one of the types conditionals accept.

`.text` coercion fixes the conditional case, but NOT the
argument-passing case — `alert(@raw.text, "Title")` still fails with
the same `rawtext`/`text` mismatch, and so does wrapping with
`text(@raw)`. There is no verified coercion that turns a `rawtext`
variable into a `text` argument; declare it with a double-quoted string
instead if it needs to reach a `text` parameter:

```ruby
@raw = 'abc'
if @raw.text == "abc" {}      // coerced, compiles

@plain = "abc"                // double-quoted: type is text
alert(@plain, "Title")        // compiles
```

A single-quoted string literal passed directly as an argument (not
through a variable) is not affected by this restriction — the compiler
coerces the literal itself.

Raw text CANNOT be used inside dictionaries or arrays (must be valid JSON).

### Escape characters (double-quoted strings only)

- `\"` double quote
- `\n` newline
- `\t` tab
- `\\` backslash

Multiline strings are supported:

```ruby
@multi = "Multiline
string
var"
```

## Types

### Value types

| Type | Syntax | Default |
|------|--------|---------|
| Text | `"text"` or `'raw'` | `""` |
| Number | `42` | `0` |
| Float | `0.5` | — |
| Boolean | `true` / `false` | `false` |
| Dictionary | `{"key": "value"}` | `{}` |
| Array | `[1, "two", 3]` | `[]` |
| Expression | `5 + 3 * 2` (`+`, `-`, `*`, `/`, `%`) | — |
| Empty | `nil` | — |

### Type declarations

```ruby
@t: text
@num: number
@list: array
@obj: dictionary
@flag: bool
@ref: variable
@real: float
@raw: rawtext
@c: color
@d: date
```

The full set of declarable types, per the compiler's "Available types"
error (shown when an unknown type is used): `text`, `rawtext`,
`number`, `float`, `bool`, `array`, `dictionary`, `variable`, `color`,
`date`. A `color` variable holds a hex string (e.g. `@c = "#FF0000"`).
`rawtext` is the type of a single-quoted string (see Raw text above).
`date` is the type returned by `date()` (see below).

### Type coercion

```ruby
@var = 5
@textVar = @var.text
@numVar = @var.number
@inline = "{@var.number}"
```

### URLs, dates, and other action-result types

```ruby
#include 'actions/calendar'
#include 'actions/location'
#include 'actions/contacts'

@urlVar = url('https://apple.com', 'https://google.com')
@dateVar = date("October 5, 2022")
@locationVar = location(Ask)
@email = emailAddress("test@test.com")
@phone = phoneNumber("(555) 555-5555")
```

### Dictionaries in detail

Dictionaries use JSON syntax with string interpolation support in values:

```ruby
const test = "text"
@dictVar = {
    "key1": "value {test}",
    "key2": 5,
    "key3": true,
    "key4": [
        "item 1",
        5,
        ["item 3", 5, false],
        {"key": "value"}
    ],
    "key5": {
        "key": "value"
    }
}
```

### Arrays

```ruby
@intVar = 42
@arrayVar = ["item 1 {@intVar}", "item 2", "item 3", 5, {"key1": "value"}]
@arrayVar += "new item"
```

## Control flow

### If/else

The first operand MUST be a variable:

```ruby
@intVar = 56
@intVar2 = 5
@textVar = "string1"
@textVar2 = "string2"

if @intVar == 5 {}
if @intVar != 5 {}
if @intVar > @intVar2 {}
if @textVar == @textVar2 {}
if @textVar contains "string" {}
if @textVar !contains @textVar2 {}
if @textVar beginsWith "string" {}
if @textVar endsWith "2" {}
```

Conditional operators: `==`, `!=`, `contains`, `!contains`, `beginsWith`,
`endsWith`, `>`, `>=`, `<`, `<=`, `<>` (between).

Has value / does not have value:

```ruby
@textVar: text
if @textVar {
    // has any value
}
if !@textVar {
    // does not have any value
}
```

Between (checks if value is between two numbers):

```ruby
@intVar = 5
if @intVar <> 5 7 {}
```

Multiple conditions (only all-AND or all-OR, NOT mixed):

```ruby
// All conditions must match
if @intVar == 5 && @textVar == "string" && @textVar == @textVar2 {}

// Any condition must match
if @intVar || @textVar {}
if @intVar == 5 || @textVar == "string" {}
```

Constants can be used in conditions too:

```ruby
const boolVar = true
if boolVar == true {}
if boolVar == false {}
```

### Loops

```ruby
// Repeat N times
repeat i for 6 {
    @intVar2 = 5
    show("{i}")
}

// For each
@listVar = list("item 1", "item 2", "item 3")
for item in @listVar {
    alert("{RepeatIndex}", @item)
}
```

The `RepeatIndex` and `RepeatItem` globals are available inside loops.

### Control flow output

Assign control flow results to constants:

```ruby
#include 'actions/network'

@deviceModel = "{Device['Model']}"
const connectionName = if @deviceModel == "iPhone" {
    getCellularDetail("Carrier Name")
} else {
    getWifiDetail("Network Name")
}

show("{connectionName}")
```

Menu as output:

```ruby
#include 'actions/device'
#include 'actions/sharing'

const deviceDetail = menu "Get Device Detail" {
    item "Battery":
        getBatteryLevel()
    item "Clipboard":
        getClipboard()
}

show("{deviceDetail}")
```

Repeat as output (accumulates array):

```ruby
const repeated = repeat i for 6 {
    number(@i)
}

@items = ["Item 1", "Item 2", "Item 3"]
const map = for item in @items {
    number(@item)
}
```

## Functions

Functions are an abstraction using Run Shortcut internally. They add
overhead — only use when you need reusable logic with arguments.

```ruby
function fibonacci(number n) {
    if @n <= 1 {
        output("{@n}")
    } else {
        const minusOne = @n - 1
        const minusTwo = @n - 2
        const fib1 = fibonacci(minusOne)
        const fib2 = fibonacci(minusTwo)
        const added = fib1 + fib2
        output("{added}")
    }
}

const output = fibonacci(7)
show("{output}") // 13
```

Defining and calling functions needs no `#include` — the dictionary-
based dispatch machinery the compiler generates for Run Shortcut is
included automatically.

Note: function parameters become variables inside the function body and
follow the same `@`-prefix rule as other variables (see Referencing
variables above): use `@n`, except inside string interpolation where
the bare name also works.

### Arguments

The parameter list must stay on one line: a `function` signature whose
parentheses span multiple lines fails to parse (see the compiler-quirks
entry on multi-line function signatures). Comment each parameter's
modifier separately instead of relying on line breaks:

```ruby
// required, optional (?), literal-only (!), and default-value parameters
function myFunc(text required, text ?optional, text! literal, text withDefault = "hi") {
    show(@required)
}
```

`output()` returns a value from a function. Without it, the function
returns nothing.

## Globals

Case-sensitive built-in references:

```ruby
@input = ShortcutInput
@date = CurrentDate
@clipboard = Clipboard
@device = Device
```

Inline usage with key access:

```ruby
@deviceOS = Device['OS']
@osVersion = "{Device['OS']} {Device['System Version']}"
```

### Ask Each Time

Prompts the user at runtime:

```ruby
#include 'actions/location'

wait(Ask)
wait(Ask: 'How many seconds?')
@name = "My name is {Ask}"
@locationVar = location(Ask)
```

`Ask` can only be used as an action argument or inline in a string — NOT
as a variable value.
