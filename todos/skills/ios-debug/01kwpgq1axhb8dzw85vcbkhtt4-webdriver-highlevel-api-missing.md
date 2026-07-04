# High-level `WebDriver` API not mentioned; it simplifies the snippet and is what upstream itself uses

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, sections "Automation session approach (recommended)" and "Key API details"

**Current state**: The skill drives the raw `AutomationSession` (`create_window` + `switch_to_window` + `navigate_broswing_context` + `execute_script(js, args=[])`) and documents its quirks (the `broswing` typo, the mandatory `args=[]`, the mandatory `switch_to_window`).

**Problem / opportunity**: pymobiledevice3 ships a Selenium-style wrapper, `pymobiledevice3.services.web_protocol.driver.WebDriver`, which hides every one of those quirks. Upstream's own `webinspector launch` command uses it instead of the raw session. Using it would shrink the snippet and remove the need to document the typo'd method and window-switch pitfalls (which then only need a brief "low-level API" note).

**Grounding** (pymobiledevice3 9.33.0 sdist, `services/web_protocol/driver.py` unless noted):
- `WebDriver(session)` constructor (line 30); used by upstream CLI at `cli/webinspector.py:221-233` (`launch_task`: `driver = WebDriver(session); await driver.start_session(); await driver.get(url)`).
- `start_session()` (line 181) → `AutomationSession.start_session()` (`automation_session.py:171-173`) creates a browsing context *and* switches to it — replaces the skill's `create_window` + `switch_to_window` pair and the `WindowNotFound` warning.
- `get(url)` (line 107) — wraps `wait_for_navigation_to_complete` + the typo'd `navigate_broswing_context`, so the typo disappears from user code.
- `execute_script(self, script: str, *args)` (line 79) — variadic; no `args=[]` boilerplate.
- Additional useful calls verified present: `get_page_source()` (line 159), `get_title()` (~line 186), `get_cookies()` (line 119), `add_cookie()` (line 38, relevant to the skill's "set cookies programmatically" remark), `refresh()`, `get_current_url()`, and screenshots via the inherited `SeleniumApi.screenshot(filename)` / `screenshot_as_png()` (`selenium_api.py:68,77`).

**Proposed change**: Rewrite the recommended snippet around `WebDriver`:

```python
from pymobiledevice3.services.web_protocol.driver import WebDriver
session = await inspector.automation_session(app)
driver = WebDriver(session)
await driver.start_session()
try:
    await driver.get(TARGET_URL)
    title = await driver.execute_script("return document.title")
finally:
    await session.stop_session()
    await inspector.close()
```

Keep a short "low-level session API" note (create_window/switch_to_window/navigate_broswing_context/execute_script(js, args=[])) for cases the wrapper doesn't cover, e.g. `screenshot_as_base64(clip=...)` options. Verify the rewritten snippet once against the real device before committing (same caveat as the connect()/RSD todos).
