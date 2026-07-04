# `opened-tabs` lists all inspectable apps' pages, not only Safari tabs; `--timeout` is a fixed sleep

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "1. Discover open tabs" and the Tips bullet about `--timeout`

**Current state**:

> ```bash
> pymobiledevice3 webinspector opened-tabs --timeout 5
> ```
> This lists all open Safari tabs with their URLs.

> - The `--timeout` flag on `opened-tabs` defaults to 3 seconds. Increase to 5–10 if the device is slow to respond.

**Problem**:
1. "lists all open Safari tabs" is too narrow. The command enumerates the pages of *every* connected inspectable application — Safari tabs, other apps' WKWebViews, service workers, and JavaScriptCore contexts — each line showing app name, pid, page type, and URL. Matching "by URL" can therefore hit non-Safari entries; the page type in the output is the discriminator (Safari page tabs report `WIRTypeWebPage`, the type the skill's own Known Issues section references, so the reader needs to know where that value comes from).
2. The `--timeout` tip is correct about the default (3.0) but misses the semantics: the value is an unconditional sleep, not a response deadline. `opened-tabs --timeout 10` always takes ~10 s even on a fast device, so "increase to 5–10" trades latency for completeness on every call, and an agent should not raise it speculatively.

**Grounding** (pymobiledevice3 9.33.0 sdist):
- `cli/webinspector.py:198-217`: `opened_tabs` command, `--timeout/-t` default `3.0`, help "Seconds to wait for WebInspector to respond."; prints each `ApplicationPage`.
- `services/webinspector.py` `get_open_application_pages(timeout)` (around line 280): queries connected applications, then literally `await asyncio.sleep(timeout)` with the comment "Give some time for `webinspectord` to reply with all inspectable applications", then collects pages of **all** `connected_application` entries.
- `services/webinspector.py:120-121` (`ApplicationPage.__str__`): output format `<AppName(pid) TYPE:<WIRType...> URL:<url>>`.
- `services/webinspector.py:31-39` (`WirTypes`): page types include `WIRTypeWebPage`, `WIRTypeServiceWorker`, `WIRTypeJavaScript`, `WIRTypePage`, `WIRTypeAutomation`, `WIRTypeITML`, `WIRTypeWeb`.

**Proposed change**: Reword step 1: the command lists all inspectable applications and their pages (Safari tabs plus other apps' web views/workers); explain the output line format and that Safari page tabs are the `WIRTypeWebPage` entries under the Safari app. Amend the Tips bullet: `--timeout N` always waits the full N seconds (it is a listing-collection sleep), so keep it at the default unless entries are missing.
