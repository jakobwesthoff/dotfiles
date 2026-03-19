---
name: actions-text
description: Text editing, rich text, dictation, regex, and case-transformation actions
metadata:
  tags: cherri, actions, text, regex, rich-text
---

Requires: `#include 'actions/text'`

---

## Enums

**stopListeningTrigger**: `'After Pause'`, `'After Short Pause'`, `'On Tap'`

---

## Actions

Convert Rich Text to HTML, optionally as a full HTML document.
`makeHTML(text input, bool ?makeFullDocument = false): text`

Convert HTML to Rich Text.
`getRichTextFromHTML(text html): text`

Convert Rich Text to Markdown.
`makeMarkdown(text richText): text`

Convert Markdown to Rich Text.
`getRichTextFromMarkdown(text markdown): text`

Transcribe user-recorded audio to text via dictation, optionally in another language.
`listen(stopListeningTrigger ?stopListening = "After Pause", language ?language): text`

Extract text from an image using OCR.
`getTextFromImage(variable image): text`

Detect an emoji in text and return its name.
`getEmojiName(text emoji): text`

Get text from input.
`getText(variable input): text`

Create spoken audio from text with optional rate and pitch controls.
`makeSpokenAudio(text text, number ?rate, number ?pitch)`

Look up the definition of a word.
`define(text word): text`

Speak text aloud, optionally in a specified language.
`speak(text prompt, bool ?waitUntilFinished = true, text ?language)`

Transcribe audio to text; requires iOS 17+.
`transcribeText(variable audio): text`

Transform text to all uppercase.
`uppercase(text text): text`

Transform text to all lowercase.
`lowercase(text text): text`

Capitalize text with sentence case.
`capitalize(text text): text`

Capitalize every word in text.
`capitalizeAll(text text): text`

Capitalize text with Title Case.
`titleCase(text text): text`

Capitalize text with alternating case.
`alternatingCase(text text): text`

Correct spelling in text.
`correctSpelling(text text): text`

Replace occurrences of a string in text, with optional regex and case-sensitivity controls.
`replaceText(text find, text replacement, text subject, bool ?caseSensitive = true, bool ?regExp = false): text`

Trim whitespace from the start and end of text.
`trimWhitespace(text text): text`

Match text using a regular expression.
`matchText(text regexPattern, text text, bool ?caseSensitive = true)`

Get the match group at a given index from regex matches.
`getMatchGroup(variable matches, number index)`

Get all match groups from regex matches.
`getMatchGroups(variable matches)`
