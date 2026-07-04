# iOS 26.2+ emits frame-type inspector targets; pymobiledevice3 binds to the first `targetInfo` event without checking type

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Known issues".

**Current state**: The Known Issues section attributes the `inspector_session`/`js-shell`/CDP failures to a `Target.targetCreated` event "that never arrives", with no iOS-version dimension.

**Problem / opportunity**: Since iOS 26.2, the opposite failure shape also exists: *extra* `Target.targetCreated` events of type `frame` that must be ignored. pymobiledevice3 (through 9.33.0) takes the first event containing `targetInfo` regardless of its `type`, so on iOS 26.2+ it can bind an inspector or CDP session to a frame target, which has no protocol domains — commands like `Runtime.evaluate` then fail even though the connection "worked". Any on-device re-test of the skill's Known Issues on iOS 26.2+ must account for this, or a fixed hang would just be replaced by a confusing domain error.

**Grounding**:

- WebKit commit 06f8ad1a5a66f9ffaa33696a5b9fba4f4c65070b, "Web Inspector: Introduce the Frame target type to prep for site isolation": frame targets coexist with page targets, their lifecycle is announced via `Target.targetCreated` events with type `frame`, and frame targets "currently lack their own domains".
- appium/appium#21705: on real devices running iOS 26.2 beta (not 26.0), web element calls started failing with "'Runtime' domain was not found" — the symptom of talking to a domainless frame target.
- appium-remote-debugger 15.2.1 (released 2025-11-11) fixed it by filtering: "Skip all Target.targetCreated events where type is not 'page'" (appium/appium-remote-debugger#450). Current source (`lib/rpc/rpc-client.ts`, master, fetched 2026-07-04) rejects any `targetInfo.type !== 'page'` and cites the WebKit commit and issue above.
- pymobiledevice3 9.33.0 sdist has no such filter: `services/web_protocol/inspector_session.py:89-92` and `services/web_protocol/cdp_target.py:185-188` both pop events until the first one with `"targetInfo"` in `params` and use its `targetId` unconditionally. A `grep -rn targetInfo` over the package (2026-07-04) shows these two wait loops plus CDP bookkeeping are the only consumers; none reads `targetInfo["type"]`.

**Proposed change**:

1. In the skill's Known Issues section (as part of the version-tagging rework in `01kwpgq1axhb8dzw85vcbkhtt6`): note that on iOS 26.2+ the inspector handshake can also mis-bind to a `frame` target, observable as "'Runtime' domain was not found"-style errors rather than a hang, and that this is a pymobiledevice3 gap, not a device-setup problem.
2. When the device re-test from `01kwpv2rx8qqvkvz165vx90g68` runs, log every received `targetInfo` (`targetId`, `type`) to tell the two failure shapes apart.
3. Candidate upstream contribution: port Appium's `type == 'page'` filter to `InspectorSession.create`/`CdpTarget.create` and file/PR it against doronz88/pymobiledevice3 (no existing issue covers it; searched 2026-07-04).
