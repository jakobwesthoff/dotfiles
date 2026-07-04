# Automation isolation claim now WebKit-grounded; skill misses session-end state destruction and on-device automation UI

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Automation session approach (recommended)", the "opens a **new tab** ... will not share session cookies" paragraph and the "Limitation" paragraph.

**Current state**:

> This opens a **new tab** and navigates to the target URL — it does NOT attach to an existing tab. The new tab will not share session cookies with existing tabs.
> ...
> **Limitation**: The automation session opens a fresh browsing context. It does NOT connect to an existing tab, so it won't have the same cookies, localStorage, or session state. To debug an authenticated page, you may need to log in via the automation session or set cookies programmatically.

**Problem / opportunity**: The isolation claim was experiential; WebKit documents it authoritatively, and the authoritative version adds three facts the skill lacks — two of which change what the agent should tell the user:

1. Isolation is total and by design, not just "no shared cookies": automation runs against a separate set of windows, tabs, preferences, and persistent storage, starting from a clean slate.
2. **Everything is destroyed when the session ends.** Logging in or setting cookies inside the session (the skill's own advice) lasts only for that session; every new run starts logged out. There is no way to persist automation state across runs.
3. **The device UI is taken over while the session runs**: the user's existing tabs are hidden and an automation window (orange address field) is shown; the tabs come back when the session ends. An agent driving this on someone's personal phone should warn them their Safari will visibly switch away mid-session.

Fact 3 also bears on the cleanup todo `01kwpgq1axhb8dzw85vcbkhtt3`, which asked whether `stop_session()` (closes all window handles the session sees) could touch the user's pre-existing tabs: WebKit describes the automation windows as a separate set from normal browsing, and pre-existing tabs as hidden and restored on session end.

**Grounding**: WebKit blog, "WebDriver is Coming to Safari in iOS 13" (https://webkit.org/blog/9395/webdriver-is-coming-to-safari-in-ios-13/, fetched 2026-07-04), which covers the same Remote Automation device toggle this skill's prerequisite 3 enables:

- "Safari on iOS isolates WebDriver tests by using a separate set of windows, tabs, preferences, and persistent storage."
- "WebDriver tests that run in an Automation window always start from a clean slate and cannot access Safari's normal browsing history, AutoFill data, or other sensitive information." and "tests are not affected by a previous test session's persistent state such as local storage or cookies."
- "When a WebDriver session is active, existing tabs are hidden and a distinctively-colored WebDriver window is shown instead. Automation windows are easy to recognize by their orange Smart Search field."
- "When the WebDriver session terminates, the orange window goes away, preexisting tabs are restored, and any state accumulated during the WebDriver session is destroyed."

The link from pymobiledevice3's `automation_session` to this machinery: it requires the same Remote Automation toggle (`RemoteAutomationNotEnabledError`, 9.33.0 sdist `services/webinspector.py:231` docstring) that the blog names as the WebDriver opt-in on iOS.

**Proposed change**: Rewrite the Limitation paragraph around the four quoted behaviors, in the skill's own words: fully isolated ephemeral profile (not merely cookie-less); login/cookie setup must be repeated every run and cannot be persisted; the user's Safari visibly switches to an orange automation window for the duration and their tabs return afterwards. Drop "opens a **new tab**" phrasing in favor of "opens an isolated automation window" (it is not a tab among the user's tabs).
