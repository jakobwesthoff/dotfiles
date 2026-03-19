---
name: actions-scripting
description: Dictionary, list, number, and scripting utility actions
metadata:
  tags: cherri, actions, scripting, dictionary, list
---

Requires: `#include 'actions/scripting'`

---

## Actions

Extract a dictionary from input.
`getDictionary(variable input): dictionary`

Get only the keys from a dictionary.
`getKeys(dictionary dictionary): array`

Get only the values from a dictionary.
`getValues(dictionary dictionary): array`

Get a value by key from a dictionary; for constants only, otherwise use `dictionary['key']` syntax.
`getValue(dictionary dictionary, text key)`

Set the value of a key in a dictionary.
`setValue(variable dictionary, text key, text value): dictionary`

Get the name of an item.
`getName(variable item)`

Set the name of an item.
`setName(variable item, text name, bool ?includeFileExtension = false)`

Prompt the user to choose one or more items from a list.
`chooseFromList(variable list, text ?prompt, bool ?selectMultiple = false, bool ?selectAll = false)`

Get the first item in a list.
`getFirstItem(variable list)`

Get the last item in a list.
`getLastItem(variable list)`

Get a random item from a list.
`getRandomItem(variable list)`

Get the item at an index in a list; note that Shortcuts indexes start at 1.
`getListItem(variable list, number index)`

Get a slice of items between two indexes in a list; note that Shortcuts indexes start at 1.
`getListItems(variable list, number start, number end): array`

Format a number to a given number of decimal places.
`formatNumber(number number, number ?decimalPlaces = 2): number`

Extract numbers from input.
`getNumbers(variable input): number`

Return a random number between min and max.
`randomNumber(number min, number max): number`

Search for passwords in the Passwords app.
`searchPasswords(text query)`

Dismiss Siri.
`dismissSiri()`
