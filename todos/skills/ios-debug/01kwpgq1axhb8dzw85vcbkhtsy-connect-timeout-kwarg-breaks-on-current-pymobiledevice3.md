# Python snippet fails on current pymobiledevice3: `connect()` no longer accepts `timeout`

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Automation session approach (recommended)" (the `uv run --with pymobiledevice3 python3` heredoc, line 72 of the snippet: `await inspector.connect(timeout=5.0)`)

**Current state**: The recommended snippet calls:

```python
await inspector.connect(timeout=5.0)
```

and runs via `uv run --with pymobiledevice3 python3`, which resolves the *latest* pymobiledevice3 from PyPI on every run.

**Problem**: In pymobiledevice3 9.33.0 (current release, 2026-07-02) the signature is `async def connect(self) -> None` with no parameters (`pymobiledevice3/services/webinspector.py:159` in the 9.33.0 sdist). Calling `connect(timeout=5.0)` raises `TypeError: connect() got an unexpected keyword argument 'timeout'`, so the skill's core recommended workflow fails outright with a current install. The snippet was valid when the skill was written (2026-03-20, per `git log`; pymobiledevice3 9.4.5 had `async def connect(self, timeout: Optional[Union[float, int]] = None)` at `services/webinspector.py:149` of the 9.4.5 sdist), but the API changed between 9.4.x and 9.33.0.

**Grounding**:
- 9.33.0 sdist (https://pypi.org/pypi/pymobiledevice3/json, latest 9.33.0): `services/webinspector.py:159` reads `async def connect(self) -> None:`; its docstring documents "Safe to call repeatedly" and `:raises WebInspectorNotEnabledError: Web Inspector is disabled on the device.` The timeout-based disabled-detection was replaced by a notification-proxy watcher (`_connect_or_raise_disabled`).
- 9.4.5 sdist: `services/webinspector.py:149` reads `async def connect(self, timeout: Optional[Union[float, int]] = None):`.
- Skill authoring date: `git -C /Users/jakob/dotfiles log --follow -- .claude/skills/ios-debug/SKILL.md` → single commit 8dad62a, 2026-03-20.
- PyPI release timeline: 9.4.5 released 2026-03-15; 9.33.0 released 2026-07-02 (release list from https://pypi.org/pypi/pymobiledevice3/json).

**Proposed change**: Two independent fixes; both are worth doing:
1. Update the snippet to `await inspector.connect()` and drop the "connect timeout" from the prose. If a connect deadline is still wanted, wrap with `await asyncio.wait_for(inspector.connect(), 5.0)`.
2. Decide on a version-pinning policy for the snippet: `uv run --with 'pymobiledevice3==9.33.0'` makes the snippet stable against upstream API churn (this exact breakage happened within 4 months) at the cost of not receiving fixes. If pinning is not wanted, add a maintenance note that the snippet tracks the latest release and the pymobiledevice3 web_protocol API is not stable.

Also update related prose while touching this section: in 9.33.0, a disabled Web Inspector surfaces as `WebInspectorNotEnabledError` from `connect()` rather than a hang/timeout.
