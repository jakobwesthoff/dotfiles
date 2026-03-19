---
name: language-fundamentals
description: Cherri language basics — variables, constants, types, control flow, functions, string interpolation
metadata:
  tags: cherri, variables, constants, types, control-flow, functions, strings
---

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

Both the bare name and `@`-prefixed form work when referencing variables.
However, the compiler emits deprecation warnings for bare names
("Prefix variable reference with @ for compilation speed"), so prefer
the `@` form to avoid noisy output:

```ruby
@textVar = "test"
@intVar = 42

// Both forms work:
alert(textVar, "Title")       // bare name
alert(@textVar, "Title")      // @prefix

show("{textVar}")             // interpolation without @
show("{@textVar}")            // interpolation with @

if intVar > 5 {}              // condition without @
if @intVar > 5 {}             // condition with @

@listVar = list("item 1", "item 2", "item 3")
for item in listVar {}        // loop without @
for item in @listVar {}       // loop with @
```

### Variable assignment from other variables

```ruby
@original = "test"
@copy = original              // bare name
@copy = @original             // @prefix — also valid
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
```

### Type coercion

```ruby
@var = 5
@textVar = @var.text
@numVar = @var.number
@inline = "{@var.number}"
```

### URLs, dates, and other action-result types

```ruby
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
for item in listVar {
    alert("{RepeatIndex}", item)
}
```

The `RepeatIndex` and `RepeatItem` globals are available inside loops.

### Control flow output

Assign control flow results to constants:

```ruby
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

Note: function parameters become variables inside the function body.
Both bare name and `@` prefix work (e.g., `n` or `@n` for parameter `n`).
The test suite tends to use `@` form inside function bodies.

### Arguments

```ruby
function myFunc(
    text required,           // required
    text ?optional,          // optional (?)
    text! literal,           // must be literal value (!)
    text withDefault = "hi"  // default value
) {
    // ...
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
wait(Ask)
wait(Ask: 'How many seconds?')
@name = "My name is {Ask}"
@locationVar = location(Ask)
```

`Ask` can only be used as an action argument or inline in a string — NOT
as a variable value.
