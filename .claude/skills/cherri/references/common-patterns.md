---
name: common-patterns
description: Reusable Cherri code patterns for HTTP requests, menus, dictionaries, dates, share sheet input, and more
metadata:
  tags: cherri, patterns, http, menu, dictionary, dates, share-sheet
---

## HTTP API call with response handling

```ruby
#include 'actions/web'

@apiEndpoint = "https://api.example.com"
@pageUrl = "https://example.com/page"
@token = "my-token"

const response = jsonRequest(@apiEndpoint, "POST",
    {"url": "{@pageUrl}"},
    {"Authorization": "Bearer {@token}", "Content-Type": "application/json"})
const dict = getDictionary(response)
const errorField = getValue(dict, "error")

if errorField {
    alert("Failed: {errorField}", "Error")
} else {
    showNotification("Saved!", "Success")
}
```

`jsonRequest`'s `body`/`headers` params only accept inline dictionary
literals — a `const` or `@var` dict fails with `Shortcuts does not
allow variable values for this argument`. Dynamic values reach the
dict through string interpolation inside the literal, as above.

## Extract URL from share sheet input

```ruby
#include 'actions/web'

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

Note: `getFirstItem()` is in `basic` and needs no include.

## Dictionary manipulation

```ruby
@dictVar = {
    "key1": "value",
    "key2": 5,
    "key3": true
}

// Read — bracket syntax (literal string key only, @var dicts only)
@value = @dictVar['key1']

// Read — getValue (works with const and @var dicts, supports variable keys)
@value = getValue(@dictVar, "key1")

// Write
setValue(@dictVar, "key4", "new value")

// Inspect
@keys = getKeys(@dictVar)
@values = getValues(@dictVar)
```

## Menu-based user interaction

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

Menu items must contain statements (action calls or variable
assignments) — bare string literals are not allowed.

### Menu with output assignment

```ruby
@result: text
menu "Pick a color" {
    item "Red":
        @result = "red"
    item "Blue":
        @result = "blue"
}
alert("You chose: {@result}", "Color")
```

## VCard menus (rich menus with images)

```ruby
#include 'stdlib'
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

## System setting toggles

```ruby
#include 'actions/settings'

setBrightness(0.75)
setVolume(0.5)
DNDOn()
DNDOff()
lightMode()
darkMode()
```

## Date difference (days between two dates)

There is no built-in `getTimeBetweenDates`/`between`/`dateDifference`
action (`cherri --action=<name> --no-ansi` finds none of these, and
none appear in the compiler source checkout's `actions/*.cherri`
files). The underlying Shortcuts action exists but isn't wired up in
Cherri, so bind it directly with a custom action definition
(`is.workflow.actions.gettimebetweendates`):

```ruby
#include 'actions/calendar'

enum timeUnit {
    'Total Time',
    'Seconds',
    'Minutes',
    'Hours',
    'Days',
    'Weeks',
    'Months',
    'Years'
}

action 'is.workflow.actions.gettimebetweendates' getTimeBetweenDates(
    date date: 'WFInput',
    timeUnit ?unit: 'WFTimeUntilUnit' = "Minutes",
    text ?referenceDate: 'WFTimeUntilReferenceDate' = "Right Now",
    date ?customDate: 'WFTimeUntilCustomDate'
): number

const eventDate = date("2025-12-25")
const daysUntil = getTimeBetweenDates(eventDate, "Days")
alert("{daysUntil} days until event", "Countdown")
```

`referenceDate` defaults to `"Right Now"`, so the call above measures
the difference between `eventDate` and the current moment; pass
`customDate` and set `referenceDate` to `"Other"` to compare two
explicit dates instead. This has only been verified at compile time
(`--skip-sign --no-ansi`, exit 0) — the parameter keys and enum values
come from third-party Shortcuts action documentation, not from running
the compiled shortcut on a device, so the runtime output (whether
`"Days"` yields a signed integer day count as expected) is unverified.

## Prompt for user input

The `prompt()` action (basic, no include needed) is the primary way to
ask the user for input:

```ruby
@name = prompt("What's your name?")
@count = prompt("How many?", "Number")
@website = prompt("Enter URL:", "URL")
```

Input types: `Text` (default), `Number`, `URL`, `Date`, `Time`,
`Date and Time`.

## Working with lists

```ruby
// Create a list and let user pick
@options = list("Option A", "Option B", "Option C")
@chosen = chooseFromList(@options, "Pick one")

// Access by index (1-based!)
const first = getFirstItem(@options)
const second = getListItem(@options, 2)
```

## Morse/flash pattern with copy/paste macros

Use `copy`/`paste` for repetitive action sequences without function
overhead:

```ruby
#include 'actions/settings'

copy flashDot {
    setBrightness(1.0)
    wait(1)
    setBrightness(0.0)
    wait(1)
}

paste flashDot
paste flashDot
paste flashDot
```

A `paste` must be declared after its `copy` — pasting first is a
compile error. Avoid chaining pastables that paste other pastables.
