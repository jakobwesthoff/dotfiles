---
name: ios-debug
description: >
  Debug web pages by loading them in an isolated Safari automation session
  on a connected iOS device, using pymobiledevice3. Use when the user wants
  to inspect, debug, or run JavaScript against web content in Safari on an
  iPhone or iPad. Does not attach to or read the user's existing open tabs.
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
2. Enabled Remote Automation: Settings → Apps → Safari → Advanced → Remote
   Automation → ON. Required for the automation session (the main
   workflow below); its absence surfaces as `RemoteAutomationNotEnabledError`.
3. Enabled Web Inspector: Settings → Apps → Safari → Advanced → Web
   Inspector → ON. Only required for listing open tabs (the optional
   URL-lookup step below); its absence surfaces as
   `WebInspectorNotEnabledError` from `connect()`.

### Connecting to the device

Every `pymobiledevice3` command reaches the device through one of four
mechanisms, selected by the flags/env var passed:

- No flag: usbmux (plain USB), the default when none of the below are given.
- `--rsd HOST PORT`: connect via an already-running tunnel's
  RemoteServiceDiscovery address.
- `--tunnel [UDID]` / `PYMOBILEDEVICE3_TUNNEL`: use a tunnel managed by
  a background `tunneld` daemon (see below).
- `--userspace` / `PYMOBILEDEVICE3_USERSPACE`: establish the iOS 17+
  tunnel in-process for this one invocation, no root required.

Upstream ties the iOS 17+ tunnel requirement to developer services
(DDI/DVT, e.g. `developer dvt screenshot`); whether `webinspector`
subcommands also need one is not confirmed — upstream's tunnel guide
and the `webinspector` command group help name no such requirement,
and the service connects over plain usbmux as well as RSD. Try
`webinspector` commands without a tunnel first. This has not yet been
verified on-device.

#### Diagnosing errors

| Error | Meaning | Fix |
| --- | --- | --- |
| `WebInspectorNotEnabledError` | Web Inspector toggle off | Settings → Apps → Safari → Advanced → Web Inspector |
| `RemoteAutomationNotEnabledError` | Remote Automation toggle off | same path, Remote Automation |
| `LaunchingApplicationError` | Safari did not connect within the timeout (often a locked device) | unlock the device |
| `InvalidServiceError` | service unreachable over the current transport | iOS 17+: start a tunnel and retry with `--rsd`, `--tunnel`, or `--userspace`; for developer-service commands also check Developer Mode (`amfi enable-developer-mode`) and `mounter auto-mount` |

#### Starting a tunnel

Needed for developer-service commands (e.g. `developer screenshot`) on
iOS 17+, and for `webinspector` commands only if the untested case
above turns out to require it. Run by the user directly in a separate
terminal since it requires `sudo`:

- Current method (iOS 17.4+, including current iOS releases):
  `sudo uvx 'pymobiledevice3==9.33.1' lockdown start-tunnel --script-mode`
- iOS 17.0–17.3.1 only:
  `sudo uvx 'pymobiledevice3==9.33.1' remote start-tunnel --script-mode`
  (add `-p tcp` when running under Python < 3.13; QUIC is otherwise the
  default there)
- iOS 16 and earlier: no tunnel needed.

With `--script-mode`, the command stays in the foreground and prints
one line, `ADDRESS PORT`. Pass those two values as `--rsd ADDRESS PORT`
to subsequent commands.

No-root alternatives to a separate `sudo` terminal:
- `--userspace` (or `PYMOBILEDEVICE3_USERSPACE=1`) on any device
  command establishes the tunnel in-process for that one invocation,
  no root/admin required. Host->device transfers are slower than with
  the kernel tunnel, and the established address is private to that
  process, so it cannot be reused by a separate command or Python
  snippet.
- `--tunnel [UDID]` (or `PYMOBILEDEVICE3_TUNNEL`) consumes a tunnel
  managed by a long-running daemon, started once with root:
  `sudo uvx 'pymobiledevice3==9.33.1' remote tunneld`

## Debugging workflow

This skill's working path loads a URL fresh in an isolated Safari
automation session on the device — it does NOT attach to, read, or
control any of the user's existing open tabs. If the task is "debug
the page open at this URL", that works directly. If the task is
"debug *my* logged-in tab" or some other state that only exists in an
existing tab, see "Genuinely tab-bound debugging" below before
starting.

### 1. Execute JavaScript on the page (main flow)

**IMPORTANT**: There are two approaches. The **automation session**
approach is the only one that works reliably for executing JS. The
`inspector_session` API and the CLI `js-shell` command both hang
indefinitely on `Target.targetCreated` for `WIRTypeWebPage` pages and
cannot be used headlessly.

#### Automation session approach (recommended)

Uses the WebDriver-like automation API. Requires "Remote Automation"
enabled on the device (see Prerequisites).

WebKit documents the isolation this session runs under (WebKit blog,
"WebDriver is Coming to Safari in iOS 13"): the automation session
runs in a separate set of windows, tabs, preferences, and persistent
storage from the device's normal Safari, starting from a clean slate
each time. Login state, cookies, or localStorage set up inside one
session exist only for that session; every new run starts logged out
again, and there is no way to persist state across runs. While the
session is active, the device's Safari visibly switches to a
distinctively colored (orange Smart Search field) automation window;
the user's existing tabs are hidden for the duration and restored when
the session ends, at which point all accumulated session state is
destroyed.

```bash
uvx --from 'pymobiledevice3==9.33.1' python3 << 'PYEOF'
import asyncio
from pymobiledevice3.lockdown import create_using_usbmux
from pymobiledevice3.services.webinspector import WebinspectorService, SAFARI
from pymobiledevice3.services.web_protocol.driver import WebDriver

TARGET_URL = "http://example.com/"
OVERALL_DEADLINE = 30  # seconds; enforced in-process, see note below

async def run():
    lockdown = create_using_usbmux()
    inspector = WebinspectorService(lockdown=lockdown)
    await inspector.connect()
    app = await inspector.open_app(SAFARI)
    session = await inspector.automation_session(app)
    driver = WebDriver(session)
    await driver.start_session()
    try:
        await driver.get(TARGET_URL)
        title = await driver.get_title()
        print(title)
    finally:
        await session.close_window()  # closes only this session's window
        await inspector.close()

asyncio.run(asyncio.wait_for(run(), OVERALL_DEADLINE))
PYEOF
```

If a tunnel is running (see "Connecting to the device" above), replace
the `create_using_usbmux()` line with the RSD equivalent:

```python
from pymobiledevice3.remote.remote_service_discovery import RemoteServiceDiscoveryService

rsd = RemoteServiceDiscoveryService((address, port))
await rsd.connect()
inspector = WebinspectorService(lockdown=rsd)
```

Whether `webinspector` actually needs the tunnel on the user's iOS
version, or works over plain usbmux regardless, has not been verified
on-device (same open question as in Prerequisites); try usbmux first
and fall back to RSD on `InvalidServiceError`.

The deadline is enforced with `asyncio.wait_for` inside the script
rather than an outer shell `timeout` wrapper: macOS ships no
`timeout` binary, so a shell-level wrapper would silently depend on
Homebrew coreutils being installed.

**Key API details**:
- `WebDriver(session)` — high-level, Selenium-style wrapper around the
  automation session; used by upstream's own CLI.
- `start_session()` — creates and switches to a browsing context in
  one call.
- `get(url)` — navigates and waits for the navigation to complete.
- `execute_script(script, *args)` — variadic, no `args=[]` boilerplate;
  `return` in the JS gets a value back.
- `get_title()`, `get_current_url()`, `get_page_source()`,
  `get_cookies()` / `add_cookie()` — additional convenience accessors.
- `get_screenshot_as_base64()` / `screenshot(filename)` — screenshot of
  the automated page (inherited from `SeleniumApi`).
- Cleanup: wrap the driven code in try/finally and call
  `session.close_window()`, which closes only the window this session
  created (`AutomationSession.close_window` closes `top_level_handle`).
  `session.stop_session()` closes every window handle the session
  sees instead; whether that could ever include the user's
  pre-existing tabs has not been verified on-device, so `close_window()`
  is the safer default here.

The `WebDriver` wrapper covers the common cases. The lower-level
`AutomationSession` it wraps (`create_window`, `switch_to_window`,
`navigate_broswing_context` — note the typo, it's in the library
itself — `execute_script(js, args)`) is still available via
`inspector.automation_session(app)` for anything the wrapper doesn't
expose.

#### Reading console output

The automation session has no console-event API: there is no
console-related code in the automation session or driver modules.
Console events (`Console.messageAdded`) exist only on the
`inspector_session` side, which is the API this skill's Known Issues
section documents as hanging indefinitely and unusable headlessly.

The workaround is installing an in-page console hook before acting,
then reading it back:

```python
await driver.execute_script("""
    window.__logs = [];
    ['log','warn','error'].forEach(level => {
        const orig = console[level].bind(console);
        console[level] = (...a) => { window.__logs.push([level, a.map(String).join(' ')]); orig(...a); };
    });
    window.addEventListener('error', e => window.__logs.push(['uncaught', e.message]));
    window.addEventListener('unhandledrejection', e => window.__logs.push(['rejection', String(e.reason)]));
""")
# ... trigger the behavior under test, e.g. driver.execute_script("document.querySelector('button').click()") ...
logs = await driver.execute_script("return JSON.stringify(window.__logs)")
```

This only captures messages logged *after* the hook is installed, and
any navigation or reload replaces the document (and the hook) along
with it. Load-time console output stays out of reach with this
pattern; what remains observable is anything triggered by subsequent
in-page actions dispatched through `execute_script`.

#### Getting page dimensions and layout info

Bundle multiple measurements into a single `execute_script` call
(assumes `driver` from the snippet above, plus `import json`):

```python
result = await driver.execute_script("""return JSON.stringify({
    url: window.location.href,
    scrollHeight: document.documentElement.scrollHeight,
    clientHeight: document.documentElement.clientHeight,
    innerHeight: window.innerHeight,
    scrollY: window.scrollY,
    theme: document.documentElement.getAttribute('data-theme')
})""")
val = json.loads(result)
```

Useful diagnostic expressions:
- **Page title**: `return document.title`
- **Current URL**: `return window.location.href`
- **DOM inspection**: `return document.querySelector('selector').outerHTML`
- **Computed styles**: `return JSON.stringify(window.getComputedStyle(document.querySelector('selector')))`
- **Viewport size**: `return JSON.stringify({w: window.innerWidth, h: window.innerHeight})`
- **Scroll state**: `return JSON.stringify({scrollY: window.scrollY, scrollHeight: document.documentElement.scrollHeight})`

### 2. Look up a tab's URL (optional)

Only needed when the user wants to debug a page they have open but
can't state the URL for. Requires "Web Inspector" enabled on the
device (see Prerequisites); this step does not feed anything into the
automation flow beyond the URL string.

```bash
uvx 'pymobiledevice3==9.33.1' webinspector opened-tabs --timeout 5
```

This lists every inspectable application's pages, not only Safari's:
other apps' WKWebViews, service workers, and JavaScriptCore contexts
show up too, each line formatted as `<AppName(pid) TYPE:<WIRType...>
URL:<url>>`. Safari's own tabs are the entries with app name Safari and
`TYPE:WIRTypeWebPage`. Take the matching URL and pass it to the
automation flow above; the automation session still loads it as a
fresh, logged-out page rather than attaching to this tab.

If this fails with `InvalidServiceError`, a tunnel is required; add
`--rsd "$ADDRESS" "$PORT"`, `--tunnel`, or `--userspace` (see
Prerequisites above).

### Genuinely tab-bound debugging

For questions that depend on state that exists only in the user's
already-open tab (an in-progress form, a broken authenticated session,
something reached after manual navigation), this skill's automation
flow cannot attach to it: per the isolation model above, it always
starts from a clean, logged-out slate. Honest fallbacks:
- Reproduce the relevant state inside the automation session itself
  (log in, set cookies via `add_cookie`, navigate through the same
  steps) and debug the reproduction instead of the original tab.
- Hand off to desktop Safari's Develop menu (Develop → *device name* →
  *tab name*), which does attach to the live tab on the device, but is
  a manual, human-driven inspector rather than something this skill
  can drive.

### 3. Take device screenshots

This is a developer-service command, so on iOS 17+ it needs a tunnel
(see Prerequisites above); add `--rsd "$ADDRESS" "$PORT"`, `--tunnel`,
or `--userspace`:

```bash
uvx 'pymobiledevice3==9.33.1' developer dvt screenshot --rsd "$ADDRESS" "$PORT" /tmp/ios-screenshot.png
```

(`developer screenshot`, the older `ScreenshotService`-based command,
is marked deprecated upstream; `developer dvt screenshot` is the
current one.)

Then read `/tmp/ios-screenshot.png` to view it. This captures the full
device screen, not just the browser viewport.

If it fails, check in order:
- Developer Mode enabled on the device: `uvx 'pymobiledevice3==9.33.1'
  amfi enable-developer-mode` (iOS >= 15).
- Developer disk image mounted: `uvx 'pymobiledevice3==9.33.1' mounter
  auto-mount`.
- On iOS 17+, a tunnel reachable via `--rsd`/`--tunnel`/`--userspace`
  (see Prerequisites above).

For a screenshot of just the automated page rather than the whole
device screen, use the automation session's own `get_screenshot_as_base64()`
/ `screenshot(filename)` instead (see Key API details above); it stays
inside the automation session and avoids the developer-services stack
entirely.

### 4. Connection flags recap

`--rsd ADDRESS PORT` (coordinates from a tunnel's `--script-mode`
output), `--tunnel [UDID]` (a running `tunneld` daemon), and
`--userspace` (in-process, no root) are the three ways a command
reaches the device through an iOS 17+ tunnel; omitting all three falls
back to plain usbmux. Any `pymobiledevice3` subcommand that takes a
device accepts these flags, for example:

```bash
uvx 'pymobiledevice3==9.33.1' webinspector opened-tabs --rsd "$ADDRESS" "$PORT"
```

## Known issues

### `inspector_session` hangs for WIRTypeWebPage pages

Observed with pymobiledevice3 9.4.x on iOS 18.x, 2026-03: the
`inspector.inspector_session(app, page)` call and the CLI `js-shell`
command's default inspector mode both hang indefinitely waiting for a
`Target.targetCreated` WebKit inspector event that never arrives for
`WIRTypeWebPage` type pages. This affects both usbmux and RSD (tunnel)
connections. `js-shell --automation` sidesteps the hang because it
drives the automation-session path instead, but both `js-shell` modes
are interactive `prompt_toolkit` shells and so are unsuited to headless
scripting regardless. **Do not use `inspector_session` or `js-shell`
for headless scripting.** Use the automation session approach instead.

### CDP bridge WebSocket connections hang

Observed with pymobiledevice3 9.4.x on iOS 18.x, 2026-03: the
`pymobiledevice3 webinspector cdp` bridge starts a server and lists
targets correctly via HTTP, but WebSocket connections to individual
pages time out. `InspectorSession.create` and `CdpTarget.create` run
the identical wait-for-target loop (`services/web_protocol/inspector_session.py`,
`services/web_protocol/cdp_target.py` in the 9.33.1 sdist), so this is
the same underlying hang as above, not just a similar one. **Do not
rely on the CDP bridge.**

For evaluate-only use where a window context is not needed,
`InspectorSession.create(protocol, wait_target=False)` skips the wait
entirely (`CdpTarget.create` has no equivalent parameter); its
docstring warns "all operations won't have a window context to operate
in".

To re-test when a device is available: run `webinspector js-shell -v`
with Safari foregrounded and the target tab visible, and again
backgrounded, and record whether `_rpc_applicationSentData:` events
arrive in each case; if they do, record the `targetInfo` (`targetId`,
`type`) of each; and record the pymobiledevice3 and iOS version
alongside the outcome.

### iOS 26.2+ may emit frame-type targets

Not verified on-device. WebKit (commit `06f8ad1a5a66f9ffaa33696a5b9fba4f4c65070b`)
introduced a `frame` target type that coexists with `page` targets and
announces itself through the same `Target.targetCreated` event; frame
targets have no protocol domains. Through the 9.33.1 sdist,
`InspectorSession.create` and `CdpTarget.create` bind to the first
event carrying `targetInfo` regardless of its `type`, so on iOS 26.2+
a session can bind to a frame target instead of the page target,
producing "'Runtime' domain was not found"-style errors rather than a
hang. This is a pymobiledevice3 gap: Appium's remote-debugger
(appium-remote-debugger 15.2.1) fixed the equivalent bug in its own
client by filtering to `type == 'page'`; pymobiledevice3 has no such
filter.

## Tips

- The `--timeout` flag on `opened-tabs` defaults to 3 seconds and is
  an unconditional sleep before collecting results, not a response
  deadline: `opened-tabs --timeout 10` always takes about 10 seconds,
  even on a fast device. Leave it at the default unless entries are
  missing from the output.
- Web Inspector toggle moved to Settings → **Apps** → Safari → Advanced
  in iOS 18. Older guides show the wrong path.
- If the requested task above contains a URL, skip the tab-lookup step
  entirely and pass the URL straight to the automation flow.
