# Troubleshooting covers only `InvalidServiceError`; dedicated webinspector errors are missing

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Prerequisites" (the `InvalidServiceError` paragraph)

**Current state**:

> If commands fail with `InvalidServiceError`, the tunnel is not running. Remind the user to start it.

That is the skill's entire error-diagnosis guidance.

**Problem**: pymobiledevice3 raises distinct, more specific exceptions for the failure modes this skill's prerequisites describe (Web Inspector toggle off, Remote Automation toggle off, locked device). An agent that only knows "error ⇒ tunnel" will misdiagnose those. Also, `InvalidServiceError` has other causes than a missing tunnel (upstream's own help text for it lists Developer Mode and image mounting).

**Grounding** (pymobiledevice3 9.33.0 sdist):
- `cli/webinspector.py:145-150` (`catch_errors`) maps: `LaunchingApplicationError` → "Unable to launch application (try to unlock device)"; `WebInspectorNotEnabledError` → "Web inspector is not enabled"; `RemoteAutomationNotEnabledError` → "Remote automation is not enabled".
- `services/webinspector.py:159` `connect()` docstring: ":raises WebInspectorNotEnabledError: Web Inspector is disabled on the device."
- `services/webinspector.py:231` `automation_session()` docstring: ":raises RemoteAutomationNotEnabledError: Remote automation is not available on the device." (raised when the reported state is `WIRAutomationAvailabilityNotAvailable`).
- `services/webinspector.py:302` `open_app()` docstring: ":raises LaunchingApplicationError: The application did not connect within the timeout."
- `__main__.py:83-91` (`INVALID_SERVICE_MESSAGE`): lists Developer Mode (`amfi enable-developer-mode`) and DDI mounting (`mounter auto-mount`) as `InvalidServiceError` causes for developer services.

**Proposed change**: Replace the single sentence with a short error table:

| Error | Meaning | Fix |
| --- | --- | --- |
| `WebInspectorNotEnabledError` | Web Inspector toggle off | Settings → Apps → Safari → Advanced → Web Inspector |
| `RemoteAutomationNotEnabledError` | Remote Automation toggle off | same path, Remote Automation |
| `LaunchingApplicationError` | Safari did not connect (often locked device) | unlock the device |
| `InvalidServiceError` | service unavailable over this transport | iOS 17+: tunnel missing; developer commands: Developer Mode / `mounter auto-mount` |

This mapping also feeds the CLI: `catch_errors` prints the quoted one-line messages, so the agent should recognize those strings in command output, not only Python tracebacks.
