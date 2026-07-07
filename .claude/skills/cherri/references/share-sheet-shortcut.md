---
name: share-sheet-shortcut
description: Complete pattern for building a share sheet bookmark shortcut that posts to an HTTP API with Cherri
metadata:
  tags: cherri, share-sheet, bookmark, api, shortcut
---

## Overview

This reference describes the complete pattern for building an iOS Shortcut
that accepts a URL from the share sheet and sends it to an HTTP API to
create a bookmark.

## Complete example

```ruby
// =========================================================
// Add Bookmark via Share Sheet
// =========================================================
//
// This Shortcut accepts a URL from the iOS share sheet and
// creates a bookmark via an HTTP API.

#include 'actions/web'
#include 'actions/text'

// ---------------------------------------------------------
// Shortcut Metadata
// ---------------------------------------------------------

#define name Add Bookmark
#define color blue
#define glyph bookmark
#define inputs url, text
#define from sharesheet
#define noinput askfor url

// ---------------------------------------------------------
// Import Questions (prompted on first install)
// ---------------------------------------------------------

#question apiUrl "Enter your bookmarking API URL" "https://api.example.com"
#question apiToken "Paste your API token" ""

// ---------------------------------------------------------
// Store import question values for reuse in strings
// ---------------------------------------------------------
// Import questions can only be used once as a direct action
// argument. To use them in string interpolation or multiple
// times, store them via the text() action first.

const storedApiUrl = text(apiUrl)
const storedToken = text(apiToken)

// ---------------------------------------------------------
// Extract URL from share sheet input
// ---------------------------------------------------------
// The share sheet may pass a URL directly, or text that
// contains a URL. We extract all URLs and take the first.

const urls = getURLs(ShortcutInput)
const pageUrl = getFirstItem(urls)

if !pageUrl {
    alert("No URL found in the shared content.", "Error")
    stop()
}

// ---------------------------------------------------------
// Send bookmark to the API
// ---------------------------------------------------------

const endpoint = "{storedApiUrl}/v1/bookmarks"

const response = jsonRequest(endpoint, "POST", {
    "url": "{pageUrl}"
}, {
    "Authorization": "Bearer {storedToken}",
    "Content-Type": "application/json"
})

// ---------------------------------------------------------
// Handle response
// ---------------------------------------------------------

const dict = getDictionary(response)
const errorField = getValue(dict, "error")

if errorField {
    alert("Failed to save bookmark:\n{errorField}", "Error")
} else {
    showNotification("Bookmark saved!", "Bookmarks")
}
```

## Key design decisions

### Import questions for credentials

Using `#question` means the user is prompted ONCE on first install. The
values persist across all future runs. This avoids needing per-user
shortcut generation.

Import question identifiers can only be used once as a direct action
argument. The `text()` action stores the value as a constant that can
be used in string interpolation and multiple times.

### URL extraction via `getURLs()`

The share sheet input varies by app — Safari passes a URL object, other
apps may pass text containing URLs. `getURLs()` handles both cases by
extracting all URLs from the input, then `getFirstItem()` picks the
primary one.

`getURLs()` requires `#include 'actions/web'`. `getFirstItem()` is a
built-in action and needs no include.

### Error handling

The shortcut parses the JSON response via `getDictionary()` and checks
for an `error` field using `getValue()`. On success, it shows a system
notification (non-blocking). On failure, it shows a modal alert.

### Notification vs alert for success

`showNotification()` is non-blocking — the user sees a banner and can
continue. `alert()` requires dismissal. Use notification for success,
alert for errors.

### String building

The endpoint URL uses `const` — it's assigned once and never mutated.
`jsonRequest`'s `body`/`headers` accept only inline dictionary
literals (see the jsonRequest call above), so they're written directly
in the call rather than stored in a `const` first. String
interpolation works fine in both cases.

## Adapting the pattern

### Adding page title

If the API accepts a title, extract it from the shared content and add
it to the inline dict passed to `jsonRequest` (a `const body` variable
does not work here; see the jsonRequest call in the complete example
above):

```ruby
#include 'actions/text'

// Some apps share text that includes the page title
const inputText = getText(ShortcutInput)
const lines = splitText(inputText, "\n")
const pageTitle = getFirstItem(lines)

const response = jsonRequest(endpoint, "POST", {
    "url": "{pageUrl}",
    "title": "{pageTitle}"
}, {
    "Authorization": "Bearer {storedToken}",
    "Content-Type": "application/json"
})
```

`splitText`'s second argument is redundant here (`"\n"` is already the
default separator) and only produces a harmless warning. Dropping it
entirely — `splitText(inputText)` — crashes the compiler on v2.3.0
(`panic: runtime error: index out of range [1] with length 1`), so the
explicit separator must stay.

### Adding tags or categories

```ruby
// Prompt user for optional tags before saving; @tags is "" when skipped
@tags = prompt("Tags (comma-separated, or leave empty):", "Text", "")

const response = jsonRequest(endpoint, "POST", {
    "url": "{pageUrl}",
    "tags": "{@tags}"
}, {
    "Authorization": "Bearer {storedToken}",
    "Content-Type": "application/json"
})
```

A single inline dict with `@tags` interpolated avoids two problems: a
`const body` declared in both branches of an if/else fails with
`Cannot redefine constant 'body'.` (constants are single-assignment,
with no branch-local scoping — see language-fundamentals.md), and a
`body` stored in a variable or constant cannot be passed to
`jsonRequest` at all (see the jsonRequest note above). When the user
skips the prompt, `tags` is sent as an empty string rather than
omitted.

### Clipboard fallback

The `#define noinput askfor url` directive handles the case where the
shortcut is run without share sheet input — it prompts for a URL.
Alternatively, use clipboard:

```ruby
#define noinput getclipboard
```

## Build and distribution

### Compile

```bash
cherri add-bookmark.cherri                    # macOS (auto-signs)
cherri add-bookmark.cherri --share=anyone      # macOS (signed for public)
cherri add-bookmark.cherri --hubsign           # Linux/CI (remote sign)
```

### Distribute

The compiled `.shortcut` file can be:
- Hosted as a static file download on a web page
- Shared via AirDrop, iCloud Drive, email, or messaging
- Uploaded to iCloud for a shareable link
