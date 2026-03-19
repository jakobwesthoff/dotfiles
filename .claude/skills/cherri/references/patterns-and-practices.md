---
name: patterns-and-practices
description: Cherri best practices, efficiency tips, compilation, CLI hygiene, signing, and anti-patterns
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

## Anti-patterns

### FORBIDDEN: Wrong string interpolation syntax

```ruby
// FORBIDDEN — this is NOT JavaScript or shell
@msg = "Hello, ${name}!"

// CORRECT — use {@varName}
@msg = "Hello, {@name}!"
```

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
@chosen = chooseFromList(@items, "Pick one")
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
