# `developer screenshot` is deprecated upstream; missing DVT alternative, developer-mode and tunnel context

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "3. Take device screenshots"

**Current state**:

> ```bash
> pymobiledevice3 developer screenshot /tmp/ios-screenshot.png
> ```
> ...
> Note: screenshots require DeveloperDiskImage. If it fails, try:
> ```bash
> pymobiledevice3 mounter auto-mount
> ```

**Problem**:
1. Upstream marks this command deprecated: in the 9.33.0 sdist, `pymobiledevice3/cli/developer/__init__.py:125-127` defines `screenshot` with docstring "Capture a PNG screenshot (Depcrecated API)." (sic), implemented via `ScreenshotService` (`com.apple.mobile.screenshotr`).
2. The current-generation command is `pymobiledevice3 developer dvt screenshot OUT` (`cli/developer/dvt/__init__.py:401-406`, docstring "Take device screenshot").
3. The failure guidance is incomplete. Upstream's own `InvalidServiceError` help text (9.33.0 `pymobiledevice3/__main__.py:83-91`) lists two causes for developer services: Developer Mode not enabled ("`pymobiledevice3 amfi enable-developer-mode`", iOS >= 15) and image not mounted ("`pymobiledevice3 mounter auto-mount`"). The skill only mentions the mount.
4. On iOS 17+, `developer` subcommands run over the tunnel: the 9.33.0 README (line 16) describes "DDI/DVT developer tooling (iOS 17+ over a tunnel)", and `__main__.py:357-377` auto-retries a failed developer command "over tunneld" once (warning: "Trying again over tunneld since it is a developer command on an iOS 17+ device (pass --userspace for a no-root tunnel)"). The skill presents the screenshot command with no connection context, while its webinspector sections stress the tunnel.

**Grounding**: all references above are from the pymobiledevice3 9.33.0 sdist (downloaded from PyPI, current release 2026-07-02) at the cited file:line positions, plus the README line quoted verbatim. `ScreenshotService` docstring (`services/screenshot.py`): "requires a developer image (developer mode) to be mounted on the device."

**Proposed change**:
- Switch the primary command to `pymobiledevice3 developer dvt screenshot /tmp/ios-screenshot.png`; optionally keep the old command in an "old patterns" note.
- Extend the failure checklist: Developer Mode enabled (`amfi enable-developer-mode`), image mounted (`mounter auto-mount`), and on iOS 17+ either rely on the automatic tunneld retry or pass `--userspace`/`--tunnel`/`--rsd`.
- Mention that for page-level captures the automation session's `screenshot_as_base64()` (already listed in the skill) avoids the developer-services stack entirely.
