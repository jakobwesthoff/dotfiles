# Known-issues section records experiential bugs without version context; js-shell has since changed

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Known issues"

**Current state**: Two absolute, unversioned claims:

> The `inspector.inspector_session(app, page)` call and the CLI `js-shell` command both hang indefinitely waiting for a `Target.targetCreated` WebKit inspector event that never arrives for `WIRTypeWebPage` type pages. ... **Do not use this API for headless scripting.**

> The `pymobiledevice3 webinspector cdp` bridge starts a server and lists targets correctly via HTTP, but WebSocket connections to individual pages time out. ... **Do not rely on the CDP bridge.**

**Problem**:
1. These are observations from a specific pymobiledevice3/iOS combination (skill authored 2026-03-20, pymobiledevice3 9.4.x era per PyPI release dates), stated as timeless facts. This codebase demonstrably churns fast — the skill's own `connect(timeout=)` call broke within four months (see the connect-timeout todo). No public upstream issue matching the `Target.targetCreated`/`WIRTypeWebPage` hang was found via web search (GitHub issues/discussions searched 2026-07-04), so there is nothing to track for "is this fixed yet"; the only anchor a future reader can use is the version the behavior was observed on.
2. The `js-shell` description is already stale: in 9.33.0 `js-shell` gained an `--automation` mode (`cli/webinspector.py:328-390`: `--automation` flag, "Use remote automation (requires Remote Automation toggle)", `AutomationJsShell` vs `InspectorJsShell`, and a `--console-enable/--no-console-enable` option; default `--timeout` now 10.0). The automation mode uses the same automation-session path the skill itself recommends, so "js-shell ... hang[s] indefinitely" no longer describes the whole command. (Both modes remain interactive prompt-toolkit shells — `JsShell.start()` loops on `prompt_async` — so js-shell stays unsuited to headless scripting regardless.)
3. Anthropic's skill best practices ("Avoid time-sensitive information", https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) call for exactly this fix: state the current method, and put dated/versioned observations in a clearly bounded block.

**Grounding**: file:line references from the pymobiledevice3 9.33.0 sdist as cited; skill authoring date from `git log`; release dates from https://pypi.org/pypi/pymobiledevice3/json.

**Proposed change**:
- Tag each known issue with the pymobiledevice3 version and iOS version it was observed on (e.g. "observed with pymobiledevice3 9.4.x on iOS 18.x, 2026-03") so future sessions know when to re-test instead of treating the workaround as permanent.
- Update the js-shell paragraph: the inspector-mode hang observation stands (versioned), but note js-shell is an interactive shell in both modes and therefore out of scope for headless use — that is the durable reason to avoid it, independent of the hang.
- Re-test the CDP bridge claim against the current release when a device is next available, and either version-tag or remove it.

## Correction (second pass)

Problem point 2 above misdates the `--automation` flag. It did **not** appear in 9.33.0; it exists in every version checked, including the era the skill was written against:

- 4.20.18 sdist, `cli/webinspector.py:203`: `@click.option('--automation', is_flag=True, help='Use remote automation')`.
- 9.4.5 sdist (current when the skill was authored 2026-03-20), `cli/webinspector.py:336-338`: same option, same help text as 9.33.0.

What 9.33.0 actually changed in `js-shell` relative to 9.4.5: `--timeout` default 3.0 → 10.0, new `--bundle-id`, and the new `--console-enable/--no-console-enable` option with its `--automation` incompatibility guard (9.33.0 `cli/webinspector.py:330-379`). So "the js-shell description is already stale" is the wrong diagnosis; the right one is stronger: **the skill's blanket js-shell hang claim was over-broad on the day it was written.** `js-shell --automation` was available then and drives `AutomationJsShell` → `inspector.automation_session` + `WebDriver` (9.4.5 `cli/webinspector.py:513-519`) — the same automation path the skill itself recommends, which never waits on `Target.targetCreated`. Only the default inspector mode (`InspectorJsShell`) hits the hang path.

The proposed change stands with one amendment: when rewriting the js-shell paragraph, scope the hang claim to inspector mode (the default) rather than framing automation mode as a later addition. The durable headless-unsuitability point is unaffected (both modes loop on `prompt_async`, 9.33.0 `cli/webinspector.py:503`).
