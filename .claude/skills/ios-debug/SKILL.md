---
name: ios-debug
description: >
  Debug websites and web apps running in Safari on a connected iOS device
  using pymobiledevice3 and Safari's Web Inspector. Use when the user wants
  to inspect, debug, or interact with Safari tabs, a Web Inspector session,
  or web content in Safari on an iPhone or iPad.
allowed-tools: Bash(uvx 'pymobiledevice3==9.33.1' *), Bash(uvx --from 'pymobiledevice3==9.33.1' *), Read
---

# iOS Safari Debugging via pymobiledevice3

## Requested task

$ARGUMENTS

Debug websites running in Safari on a connected iOS device.

## Prerequisites

All commands in this skill run `pymobiledevice3` through `uvx`, pinned to
version `9.33.1`, rather than a global install:

- CLI calls: `uvx 'pymobiledevice3==9.33.1' <subcommand> ...`
- Python snippets: `uvx --from 'pymobiledevice3==9.33.1' python3 ...`

The pin exists because pymobiledevice3's Python API (the classes and
methods used in the automation snippet below) breaks between releases,
so an unpinned `uvx pymobiledevice3 ...` can silently pick up a newer,
incompatible release, or silently reuse an older copy left behind by a
prior `uv tool install pymobiledevice3` on the same machine. To bump the
pin, change the version string everywhere in this file after confirming
the workflow still works against the new release.

The user must have:
1. Connected the iPhone via USB and trusted the Mac.
2. Enabled Web Inspector: Settings → Apps → Safari → Advanced → Web Inspector → ON.
3. Enabled Remote Automation: Settings → Apps → Safari → Advanced → Remote Automation → ON.
4. Started a tunnel in a separate terminal (required for iOS 17+), run by
   the user directly since it requires `sudo`:
   - **iOS 18.2+**: `sudo uvx 'pymobiledevice3==9.33.1' remote start-tunnel -p tcp`
   - **iOS 17.4–18.1**: `sudo uvx 'pymobiledevice3==9.33.1' lockdown start-tunnel`
   - **iOS 17.0–17.3**: `sudo uvx 'pymobiledevice3==9.33.1' remote start-tunnel`
   - **iOS 16 and earlier**: no tunnel needed.

If commands fail with `InvalidServiceError`, the tunnel is not running.
Remind the user to start it.

## Debugging workflow

### 1. Discover open tabs

```bash
uvx 'pymobiledevice3==9.33.1' webinspector opened-tabs --timeout 5
```

This lists all open Safari tabs with their URLs. Identify the tab the
user wants to debug (match by URL or ask).

### 2. Execute JavaScript on the page

**IMPORTANT**: There are two approaches. The **automation session**
approach is the only one that works reliably for executing JS. The
`inspector_session` API and the CLI `js-shell` command both hang
indefinitely on `Target.targetCreated` for `WIRTypeWebPage` pages and
cannot be used headlessly.

#### Automation session approach (recommended)

Uses the WebDriver-like automation API. Requires "Remote Automation"
enabled on the device. This opens a **new tab** and navigates to the
target URL — it does NOT attach to an existing tab. The new tab will
not share session cookies with existing tabs.

```bash
uvx --from 'pymobiledevice3==9.33.1' python3 << 'PYEOF'
import asyncio, json
from pymobiledevice3.lockdown import create_using_usbmux
from pymobiledevice3.services.webinspector import WebinspectorService, SAFARI

TARGET_URL = "http://example.com/"

async def run():
    lockdown = create_using_usbmux()
    inspector = WebinspectorService(lockdown=lockdown)
    await inspector.connect(timeout=5.0)
    app = await inspector.open_app(SAFARI)
    session = await inspector.automation_session(app)

    # Must create and switch to a window first
    handle = await session.create_window(type_="tab")
    await session.switch_to_window(handle)

    # Navigate to the target URL
    await session.navigate_broswing_context(url=TARGET_URL)
    await session.wait_for_navigation_to_complete()

    # Execute JavaScript (args=[] is required)
    result = await session.execute_script(
        "return document.title", args=[]
    )
    print(result)

    await inspector.close()

asyncio.run(run())
PYEOF
```

**Key API details**:
- `create_window(type_="tab")` — creates a new Safari tab.
- `switch_to_window(handle)` — MUST be called after `create_window`
  before any navigation or script execution, otherwise you get
  `WindowNotFound` errors.
- `navigate_broswing_context(url=...)` — note the typo in the method
  name (`broswing` not `browsing`), it's in the library.
- `execute_script(js, args=[])` — the `args` parameter is required.
  Use `return` in JS to get a value back.
- `screenshot_as_base64()` — take a screenshot of the page.

**Limitation**: The automation session opens a fresh browsing context.
It does NOT connect to an existing tab, so it won't have the same
cookies, localStorage, or session state. To debug an authenticated
page, you may need to log in via the automation session or set cookies
programmatically.

#### Getting page dimensions and layout info

Bundle multiple measurements into a single `execute_script` call:

```python
result = await session.execute_script("""return JSON.stringify({
    url: window.location.href,
    scrollHeight: document.documentElement.scrollHeight,
    clientHeight: document.documentElement.clientHeight,
    innerHeight: window.innerHeight,
    scrollY: window.scrollY,
    theme: document.documentElement.getAttribute('data-theme')
})""", args=[])
val = json.loads(result)
```

Useful diagnostic expressions:
- **Page title**: `return document.title`
- **Current URL**: `return window.location.href`
- **DOM inspection**: `return document.querySelector('selector').outerHTML`
- **Computed styles**: `return JSON.stringify(window.getComputedStyle(document.querySelector('selector')))`
- **Viewport size**: `return JSON.stringify({w: window.innerWidth, h: window.innerHeight})`
- **Scroll state**: `return JSON.stringify({scrollY: window.scrollY, scrollHeight: document.documentElement.scrollHeight})`

### 3. Take device screenshots

```bash
uvx 'pymobiledevice3==9.33.1' developer screenshot /tmp/ios-screenshot.png
```

Then read `/tmp/ios-screenshot.png` to view it. This captures the full
device screen, not just the browser viewport.

Note: screenshots require DeveloperDiskImage. If it fails, try:
```bash
uvx 'pymobiledevice3==9.33.1' mounter auto-mount
```

### 4. RSD connection (if tunnel output gives address)

When the tunnel provides an RSD address, pass it explicitly:

```bash
uvx 'pymobiledevice3==9.33.1' webinspector opened-tabs --rsd <address> <port>
```

## Known issues

### `inspector_session` hangs for WIRTypeWebPage pages

The `inspector.inspector_session(app, page)` call and the CLI
`js-shell` command both hang indefinitely waiting for a
`Target.targetCreated` WebKit inspector event that never arrives for
`WIRTypeWebPage` type pages. This affects both usbmux and RSD (tunnel)
connections. **Do not use this API for headless scripting.** Use the
automation session approach instead.

### CDP bridge WebSocket connections hang

The `pymobiledevice3 webinspector cdp` bridge starts a server and
lists targets correctly via HTTP, but WebSocket connections to
individual pages time out. This is likely caused by the same underlying
`inspector_session` hang. **Do not rely on the CDP bridge.**

## Tips

- The `--timeout` flag on `opened-tabs` defaults to 3 seconds. Increase
  to 5–10 if the device is slow to respond.
- Web Inspector toggle moved to Settings → **Apps** → Safari → Advanced
  in iOS 18. Older guides show the wrong path.
- If the requested task above contains a URL, look for a matching tab in
  `opened-tabs` output and focus debugging there.
