---
name: common-patterns
description: Reusable Cherri code patterns for HTTP requests, menus, dictionaries, dates, share sheet input, and more
metadata:
  tags: cherri, patterns, http, menu, dictionary, dates, share-sheet
---

## HTTP API call with response handling

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

## Extract URL from share sheet input

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

## Dictionary manipulation

```ruby
#include 'actions/scripting'

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

There is no `getTimeBetweenDates` action. Use Unix epoch seconds via
custom date formatting to calculate differences:

```ruby
#include 'actions/calendar'

const eventDate = date("2025-12-25")
@now = CurrentDate

// Format as Unix epoch seconds (custom format "U")
const eventSec = formatDate(eventDate, "Custom", "U")
const nowSec = formatDate(@now, "Custom", "U")

// Convert to numbers and compute difference in days
@eventNum: number
@eventNum = number(eventSec)
@nowNum: number
@nowNum = number(nowSec)

@days = @eventNum / 86400 - @nowNum / 86400
alert("{@days} days until event", "Countdown")
```

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
#include 'actions/scripting'

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
