---
name: actions-basic
description: Core built-in actions always available in Cherri — no include required
metadata:
  tags: cherri, actions, basic
---

These actions are always available. No `#include` statement is needed.

---

## Enums

**abcSortOrder**: `'A to Z'`, `'Z to A'`

**language**: `'ar_AE'`, `'zh_CN'`, `'zh_TW'`, `'nl_NL'`, `'en_GB'`, `'en_US'`, `'fr_FR'`, `'de_DE'`, `'id_ID'`, `'it_IT'`, `'jp_JP'`, `'ko_KR'`, `'pl_PL'`, `'pt_BR'`, `'ru_RU'`, `'es_ES'`, `'th_TH'`, `'tr_TR'`, `'vn_VN'`

**countType**: `'Items'`, `'Characters'`, `'Words'`, `'Sentences'`, `'Lines'`

---

## Actions

Stop the shortcut.
`stop()`

Clear the current output.
`nothing()`

Add an explicit comment.
`comment(text text)`

Get the type of input.
`typeOf(variable input): text`

Get the object of a given class from a variable.
`getObjectOfClass(text class, variable from)`

Show a result.
`show(text input)`

Preview input in Quick Look.
`quicklook(variable input)`

Stop and output a value; do nothing if there is nowhere to output.
`output(text output)`

Stop and output a value; copy to clipboard if there is nowhere to output.
`outputOrClipboard(text output)`

Stop and output a value; respond with a fallback if there is nowhere to output.
`mustOutput(text output, text response)`

Display input as a content graph.
`contentGraph(variable input)`

Return a count of items in input, by a chosen count type.
`count(variable input, countType ?type = "Items"): number`

Show an alert with text and optional title and an OK button to proceed.
`alert(text alert, text ?title)`

Show an alert with OK and Cancel buttons; Cancel stops the shortcut.
`confirm(text alert, text ?title)`

Show a custom notification message.
`showNotification(text body, text ?title, bool ?playSound = true, variable ?attachment)`

Create a number value.
`number(variable number): number`

Create a text value.
`text(text text): text`

Wait a specified number of seconds.
`wait(number seconds)`

Wait for the user to return to Shortcuts.
`waitToReturn()`

Search using Spotlight (macOS) or system search (iOS/iPadOS).
`search(text query, number ?limit = 5, array ?resultType = [...]): array`
