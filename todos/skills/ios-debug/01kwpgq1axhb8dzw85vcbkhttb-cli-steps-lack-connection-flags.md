# CLI examples omit connection flags on iOS 17+; step 4 frames `--rsd` as an optional afterthought

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, sections "1. Discover open tabs", "3. Take device screenshots", "4. RSD connection (if tunnel output gives address)"

**Current state**: Steps 1 and 3 show bare commands (`pymobiledevice3 webinspector opened-tabs --timeout 5`, `pymobiledevice3 developer screenshot ...`) with no connection option. Step 4 then says:

> When the tunnel provides an RSD address, pass it explicitly:
> ```bash
> pymobiledevice3 webinspector opened-tabs --rsd <address> <port>
> ```

**Problem**: The skill's prerequisites declare the tunnel "required for iOS 17+", yet the primary command examples never consume it — a bare invocation resolves the device over usbmux (`cli/cli_common.py:322-331` in the 9.33.0 sdist: with no `--rsd`/`--tunnel`/`--userspace`, `any_service_provider_dependency` falls through to `create_using_usbmux`). The tunnel's `start-tunnel` output *always* prints the RSD host/port (that is its purpose, per the upstream guide's "`--rsd <address> <port>` (manual connection details)"), so "if tunnel output gives address" is misleading hedging; on iOS 17+ the flag (or an equivalent) is how commands use the tunnel at all. Additionally, `webinspector` commands do not benefit from the automatic tunneld retry: in `__main__.py:357-377` the retry fires only for `RSDRequiredError` or when `"developer" in sys.argv`, so a failed `webinspector` command just errors.

**Grounding**: pymobiledevice3 9.33.0 sdist at the cited lines; upstream tunnel guide (https://doronz88.github.io/pymobiledevice3/guides/ios17-tunnels/) listing the three consumption mechanisms (`--tunnel`, `--userspace`, `--rsd <address> <port>`). This is the CLI-side counterpart of the Python-snippet inconsistency recorded in `01kwpgq1axhb8dzw85vcbkhtt1-python-snippet-ignores-required-tunnel.md`.

**Proposed change**: Make the connection option part of the primary examples rather than a trailing section: state once, up front, that on iOS 17+ every `pymobiledevice3` invocation needs `--rsd HOST PORT` (from the tunnel output), `--tunnel UDID` (tunneld), or `--userspace` (no root), and show step 1/3 commands with a `--rsd "$HOST" "$PORT"` placeholder. Retitle or remove section 4 accordingly. As with the Python todo: if testing shows webinspector works over plain usbmux on the target iOS version, document that instead and scope the tunnel requirement to the commands that need it.
