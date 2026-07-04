# Upstream ties tunnels to developer services only; no source backs "tunnel required for iOS 17+" for webinspector

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Prerequisites", item 4 ("Started a tunnel in a separate terminal (required for iOS 17+)") and the `InvalidServiceError` paragraph.

**Current state**:

> 4. Started a tunnel in a separate terminal (required for iOS 17+): ...
>
> If commands fail with `InvalidServiceError`, the tunnel is not running.

**Problem / opportunity**: Two existing todos (`01kwpgq1axhb8dzw85vcbkhtt1`, `01kwpgq1axhb8dzw85vcbkhttb`) record that the skill demands a tunnel yet none of its commands consume one, and left open which side is wrong. Every upstream source found in this pass points the same way: tunnels are a **developer-services** (DDI/DVT) requirement, and webinspector is a plain lockdown service that runs over USB without one. If that holds on the target device, the skill's heaviest prerequisite (sudo tunnel in a separate terminal) can be dropped from the primary workflow entirely and scoped to the screenshot step.

**Grounding** (pymobiledevice3 9.33.0 sdist unless noted):

- `README.md:14-16` lists features as "... WebInspector automation, and DDI/DVT developer tooling (iOS 17+ over a tunnel)." The tunnel qualifier is attached to DDI/DVT only; WebInspector automation is listed without it.
- Upstream tunnel guide (https://doronz88.github.io/pymobiledevice3/guides/ios17-tunnels/, fetched 2026-07-04): "Starting with iOS 17.0, Apple moved developer service access to CoreDevice/RemoteXPC flows. To use many `developer dvt` commands, establish a trusted tunnel first." The guide names only developer commands (`developer dvt`, `developer debugserver`, `fetch-symbols`); webinspector appears nowhere in it.
- Upstream's own agent skill, `.codex/skills/pymobiledevice3-device-operator/references/transport-and-safety.md`: "USB lockdown is the default path for most commands." Its tunnel checklist is titled "iOS 17+ Developer Service Checklist" and opens with "Many `developer dvt` and related developer commands need all of the following: ...".
- `services/webinspector.py:136-140`: the service connects as `com.apple.webinspector` whenever the provider is a `LockdownClient` (usbmux), and only uses the RSD shim service (`com.apple.webinspector.shim.remote`) for RSD providers. Both transports are first-class.
- `__main__.py:361-368`: the automatic retry-over-tunneld fires only for `RSDRequiredError` or when `"developer" in sys.argv` — upstream's error handling does not treat webinspector as a command that might need a tunnel.
- `cli/webinspector.py:135-142` (command group help): "Requires Web Inspector and Remote Automation enabled on the device." — the only prerequisites upstream states for the group; no tunnel mention.

**Limit of this grounding**: all of the above is upstream source/docs, not a device observation. Whether `webinspector opened-tabs` and the automation session actually work over plain usbmux on the device's iOS version still needs one on-device check.

**Proposed change**:

1. Device test (single command, no tunnel running): `pymobiledevice3 webinspector opened-tabs` on the target iOS 17+/26 device. If it lists pages, also run the skill's automation snippet once.
2. On success: delete prerequisite 4 from the main flow, state that webinspector runs over USB on all iOS versions, and move tunnel instructions next to the developer screenshot step (the only step whose stack needs one on iOS 17+, per the `developer screenshot` todo `01kwpgq1axhb8dzw85vcbkhtt2`). Rewrite the `InvalidServiceError` paragraph accordingly (see also the error-mapping todo `01kwpgq1axhb8dzw85vcbkhtt5`).
3. On failure: record the exact error and iOS version in the skill, and adopt the connection-flag fixes from `01kwpgq1axhb8dzw85vcbkhttb` instead.
