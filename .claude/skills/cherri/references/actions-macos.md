---
name: actions-macos
description: macOS-only actions (shell scripts, AppleScript, windows, disk images) and Shortcuts management
metadata:
  tags: cherri, actions, mac, macos, shell, applescript, shortcuts
---

## Mac (`#include 'actions/mac'`)

All actions in this section are macOS-only.

**storageUnit**: `bytes`, `KB`, `MB`, `GB`, `TB`, `PB`, `EB`, `ZB`, `Y`

**screenshotSelection**: `Window`, `Custom`

**windowPosition**: `Top Left`, `Top Center`, `Top Right`, `Middle Left`, `Center`, `Middle Right`, `Bottom Left`, `Bottom Center`, `Bottom Right`, `Coordinates`

**windowSize**: `Fit Screen`, `Top Half`, `Bottom Half`, `Left Half`, `Right Half`, `Top Left Quarter`, `Top Right Quarter`, `Bottom Left Quarter`, `Bottom Right Quarter`, `Dimensions`

Get the list of installed applications. Requires macOS 18+.
`getApps(): array`

Create a new disk image from files. Requires macOS 15+.
`makeDiskImage(text name, variable contents, bool ?encrypt = false)`

Create a new disk image of a specific size. Requires macOS 15+.
`makeSizedDiskImage(text name, variable contents, #storageUnit diskSize = qty(1, "GB"), bool ?encrypt = false)`

Start the screen saver.
`startScreensaver()`

Put the Mac to sleep. Requires macOS 17+.
`sleep()`

Put the Mac display to sleep while keeping the device awake. Requires macOS 17+.
`displaySleep()`

Take an interactive screenshot by window or custom region selection.
`takeInteractiveScreenshot(screenshotSelection ?selection = "Window")`

Move a window to a defined screen position.
`moveWindow(variable window, windowPosition position, bool ?bringToFront = true)`

Resize a window to a defined configuration.
`resizeWindow(variable window, windowSize configuration)`

Run a shell script, passing optional input via stdin.
`runShellScript(text script, variable input, text ?shell = "/bin/zsh", text ?inputMode = "to stdin")`

Run an AppleScript, passing optional input.
`runAppleScript(variable input, text script)`

Run a JavaScript for Automation script, passing optional input.
`runJSAutomation(variable input, text script)`

---

## Shortcuts (`#include 'actions/shortcuts'`)

**shortcutDetail**: `Folder`, `Icon`, `Action Count`, `File Size`, `File Extension Creation Date`, `File Path`, `Last Modified Date`, `Name`

Get all Shortcuts on the device.
`getShortcuts(): array`

Get a specific detail about a Shortcut.
`getShortcutDetail(variable shortcut, shortcutDetail detail)`

Search the user's Shortcuts by query. Requires iOS 16.4+.
`searchShortcuts(text query)`

Create a new Shortcut, optionally opening it after creation. Requires iOS 16.4+.
`makeShortcut(text name, bool ?open = true)`

Run a Shortcut by name, passing it optional input.
`run(text shortcutName, variable input)`
