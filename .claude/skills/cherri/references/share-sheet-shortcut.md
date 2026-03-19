---
name: share-sheet-shortcut
description: Complete pattern for building a Squirly share sheet bookmark shortcut with Cherri
metadata:
  tags: cherri, share-sheet, bookmark, squirly, api, shortcut
---

## Overview

This reference describes the complete pattern for building an iOS Shortcut
that accepts a URL from the share sheet and sends it to the Squirly API
to create a bookmark.

## Complete example

```ruby
// =========================================================
// Squirly — Add Bookmark via Share Sheet
// =========================================================
//
// This Shortcut accepts a URL from the iOS share sheet and
// creates a bookmark in Squirly via the API.

#include 'actions/web'
#include 'actions/scripting'
#include 'actions/text'

// ---------------------------------------------------------
// Shortcut Metadata
// ---------------------------------------------------------

#define name Add to Squirly
#define color blue
#define glyph bookmark
#define inputs url, text
#define from sharesheet
#define noinput askfor url

// ---------------------------------------------------------
// Import Questions (prompted on first install)
// ---------------------------------------------------------

#question apiUrl "Enter your Squirly API URL" "https://squirly.example.com"
#question apiToken "Paste your Squirly API token" ""

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
// Send bookmark to Squirly API
// ---------------------------------------------------------

const endpoint = "{storedApiUrl}/api/v1/bookmarks"
const headers = {
    "Authorization": "Bearer {storedToken}",
    "Content-Type": "application/json"
}
const body = {
    "url": "{pageUrl}"
}

const response = jsonRequest(endpoint, "POST", body, headers)

// ---------------------------------------------------------
// Handle response
// ---------------------------------------------------------

const dict = getDictionary(response)
const errorField = getValue(dict, "error")

if errorField {
    alert("Failed to save bookmark:\n{errorField}", "Error")
} else {
    showNotification("Bookmark saved!", "Squirly")
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

Both `getURLs()` and `getFirstItem()` require their includes
(`actions/web` and `actions/scripting` respectively).

### Error handling

The shortcut parses the JSON response via `getDictionary()` and checks
for an `error` field using `getValue()`. On success, it shows a system
notification (non-blocking). On failure, it shows a modal alert.

### Notification vs alert for success

`showNotification()` is non-blocking — the user sees a banner and can
continue. `alert()` requires dismissal. Use notification for success,
alert for errors.

### String building

The endpoint URL, headers, and body all use `const` — they're assigned
once and never mutated. String interpolation works fine with constants.

## Adapting the pattern

### Adding page title

If the Squirly API accepts a title, extract it from the shared content:

```ruby
// Some apps share text that includes the page title
const inputText = getText(ShortcutInput)
const lines = splitText(inputText, "\n")
const pageTitle = getFirstItem(lines)

const body = {
    "url": "{pageUrl}",
    "title": "{pageTitle}"
}
```

### Adding tags or categories

```ruby
// Prompt user for optional tags before saving
@tags = prompt("Tags (comma-separated, or leave empty):", "Text", "")

if @tags {
    const body = {
        "url": "{pageUrl}",
        "tags": "{@tags}"
    }
} else {
    const body = {
        "url": "{pageUrl}"
    }
}
```

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
cherri add-to-squirly.cherri                    # macOS (auto-signs)
cherri add-to-squirly.cherri --share=anyone      # macOS (signed for public)
cherri add-to-squirly.cherri --hubsign           # Linux/CI (remote sign)
```

### Distribute

The compiled `.shortcut` file can be:
- Hosted as a static file download on the Squirly web UI
- Shared via AirDrop, iCloud Drive, email, or messaging
- Uploaded to iCloud for a shareable link

The Squirly settings page should:
1. Generate a scoped API token for the user
2. Display the token value
3. Provide a download link for the pre-built shortcut
4. Instruct the user to enter their API URL and token when prompted
