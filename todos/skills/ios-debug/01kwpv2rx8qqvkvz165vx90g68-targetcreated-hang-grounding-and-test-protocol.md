# CDP bridge and inspector_session block in the same wait loop (now source-grounded); device-test protocol for the hang

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Known issues" (both subsections).

**Current state**:

> The `pymobiledevice3 webinspector cdp` bridge starts a server and lists targets correctly via HTTP, but WebSocket connections to individual pages time out. This is likely caused by the same underlying `inspector_session` hang.

**Problem / opportunity**: Second-pass source reading upgrades "likely" to fact, adds an escape hatch the skill doesn't know about, and — since no upstream issue tracks the hang (GitHub issues, discussions, and code searched 2026-07-04; the only js-shell issue, doronz88/pymobiledevice3#824, is a user scripting error, and its thread even shows interactive js-shell navigating successfully on that user's device in 2024) — defines what the eventual on-device re-test must record for the observation to stay useful.

**Grounding** (pymobiledevice3 9.33.0 sdist):

1. Same wait, verbatim: `InspectorSession.create` (`services/web_protocol/inspector_session.py:86-93`) and `CdpTarget.create` (`services/web_protocol/cdp_target.py:182-189`) both run the identical loop — busy-wait `while not protocol.inspector.wir_events: await asyncio.sleep(0)`, then pop events until one carries `params["targetInfo"]`. Whatever prevents the target event from arriving hangs both entry points at the same line-for-line spot. The `wir_events` list is fed by `_rpc_applicationSentData:` messages from the device (`services/webinspector.py:396-402`; payloads without an `"id"` are events).
2. Escape hatch: `InspectorSession.create(protocol, wait_target=False)` skips the wait entirely; docstring: "Wait for target. If not, all operations won't have a window context to operate in" (`inspector_session.py:79-82`). Upstream itself uses `wait_target=False` semantics for `WIRTypeJavaScript` pages (`services/webinspector.py:262-265`: `wait_target=page.type_ != WirTypes.JAVASCRIPT`).
3. The event *should* arrive on modern iOS: the target-based handshake is the only protocol current WebKit speaks — appium-remote-debugger 15.0.0 removed the non-target fallback as obsolete ("Drop the obsolete non-target based communication protocol support", appium/appium-remote-debugger#440, CHANGELOG). So "never arrives for WIRTypeWebPage" is an anomaly worth root-causing, not a protocol constant.

**Proposed change**:

- Reword the CDP paragraph: both commands block waiting for the same `Target.targetCreated` WIR event; not "likely", same code path (state it plainly, without file:line, per the section's style).
- Mention `wait_target=False` as the low-level workaround for evaluate-only use, with its "no window context" caveat.
- Add the re-test protocol (for the next session with the device attached), so the result is diagnostic rather than another binary observation:
  1. Run `pymobiledevice3 webinspector js-shell -v` (verbose) with Safari **foregrounded and the target tab visible**, and again with Safari backgrounded — record whether `_rpc_applicationSentData:` events arrive at all in each case.
  2. If events arrive, record their `targetInfo` contents (`targetId`, `type`) — see the companion todo `01kwpv2rx8qqvkvz165vx90g69` on iOS 26.2+ `frame`-type targets for why `type` matters.
  3. Record iOS version and pymobiledevice3 version alongside the outcome (the version-tagging fix from `01kwpgq1axhb8dzw85vcbkhtt6`).
  4. If reproducible on current pymobiledevice3, file it upstream — nothing exists to link to today.
