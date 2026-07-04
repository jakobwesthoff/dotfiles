# No way to read console output/JS errors; the automation path has no console events at all

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "2. Execute JavaScript on the page" (diagnostic expressions list) and "Known issues".

**Current state**: The skill's diagnostic toolbox is execute-script expressions (title, URL, DOM, styles, viewport, scroll) and screenshots. Console messages and uncaught JS errors — a first-line signal when debugging a broken page — appear nowhere.

**Problem / opportunity**: The omission is structural, not just missing prose, and the skill should say so:

- Console events exist only on the inspector side of pymobiledevice3: `InspectorSession` handles `Console.messageAdded` and exposes `console_enable()` (9.33.0 sdist, `services/web_protocol/inspector_session.py:70` and the `console_enable` method), used by the CLI's `InspectorJsShell` (`cli/webinspector.py:593`). That is exactly the path the skill's Known Issues section bans for hanging.
- The automation side has none: no console-related code exists in `services/web_protocol/automation_session.py` or `driver.py` (grep over the 9.33.0 sdist, 2026-07-04), and the CLI enforces the split — `js-shell` help reads "Enable console events for Inspector mode. Cannot be combined with --automation." with a hard `BadParameter` guard (`cli/webinspector.py:353-357,378-379`).

So with the skill's recommended approach, past console output is unreachable. What *is* reachable from the automation session is anything capturable inside the page after navigation, via `execute_script`.

**Grounding**: sdist references above; the workaround below relies only on `execute_script`, which the skill already documents and uses.

**Proposed change**: Add a "Reading console output and errors" subsection:

1. State the limitation: the automation session cannot deliver console events; console capture belongs to the inspector session, which is currently unusable headlessly (Known Issues).
2. Document the in-page capture pattern for the automation flow — install hooks first, act, then read back:

   ```python
   await session.execute_script("""
       window.__logs = [];
       ['log','warn','error'].forEach(level => {
           const orig = console[level].bind(console);
           console[level] = (...a) => { window.__logs.push([level, a.map(String).join(' ')]); orig(...a); };
       });
       window.addEventListener('error', e => window.__logs.push(['uncaught', e.message]));
       window.addEventListener('unhandledrejection', e => window.__logs.push(['rejection', String(e.reason)]));
   """, args=[])
   # ... trigger the behavior under test ...
   logs = await session.execute_script("return JSON.stringify(window.__logs)", args=[])
   ```

   with the caveat stated explicitly: hooks capture only what runs *after* they are installed, and any navigation or reload replaces the document along with the hooks. Load-time console output is therefore out of reach with this pattern; what remains observable is everything triggered by subsequent in-page actions (clicks dispatched via JS, function calls, fetches).
3. Keep the snippet aligned with whichever API style the skill lands on (raw session vs `WebDriver`, see `01kwpgq1axhb8dzw85vcbkhtt4`).
