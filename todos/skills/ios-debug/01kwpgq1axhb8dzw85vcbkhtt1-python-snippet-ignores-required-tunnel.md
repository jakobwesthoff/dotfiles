# Python snippet uses usbmux only, contradicting the skill's own iOS 17+ tunnel prerequisite

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, sections "Prerequisites" (item 4) and "Automation session approach (recommended)"

**Current state**: Prerequisites state a tunnel is "required for iOS 17+" and that `InvalidServiceError` means "the tunnel is not running". But the recommended Python snippet connects exclusively via usbmux:

```python
from pymobiledevice3.lockdown import create_using_usbmux
...
lockdown = create_using_usbmux()
inspector = WebinspectorService(lockdown=lockdown)
```

**Problem**: The tunnel started in a separate terminal exposes an RSD endpoint (`--rsd HOST PORT` per the tunnel's output); a `create_using_usbmux()` lockdown connection does not use it. So on an iOS 17+ device, either (a) the webinspector lockdown service still starts over plain usbmux and the tunnel prerequisite is unnecessary for this snippet, or (b) it fails with `InvalidServiceError` and the snippet cannot work no matter what runs in the other terminal. Either way the skill is internally inconsistent, and it gives no Python-level way to consume the tunnel it demands. (Which of (a)/(b) applies per iOS version could not be verified without a device; the inconsistency itself is verifiable from the text.)

**Grounding**:
- Skill text: prerequisite 4 ("required for iOS 17+") vs. the snippet's `create_using_usbmux()` (no `--rsd`/RSD anywhere in the Python path).
- 9.33.0 sdist, `pymobiledevice3/services/webinspector.py:136-141`: `WebinspectorService` uses `SERVICE_NAME = "com.apple.webinspector"` for a `LockdownClient` and `RSD_SERVICE_NAME = "com.apple.webinspector.shim.remote"` otherwise — the service explicitly supports both transports and picks by provider type.
- Upstream Python RSD usage example, 9.33.0 sdist `misc/understanding_idevice_protocol_layers.md:459-467`:

  ```python
  rsd = RemoteServiceDiscoveryService((host, port))
  await rsd.connect()
  # Both LockdownClient and RemoteServiceDiscoveryService implement
  # LockdownServiceProvider, meaning you can simply use this instance
  # as any other LockdownClient instance
  ```

  Class lives at `pymobiledevice3/remote/remote_service_discovery.py:35` (`class RemoteServiceDiscoveryService(LockdownServiceProvider)`).

**Proposed change**: Make the snippet's connection strategy explicit and consistent:
1. Add an RSD variant to the snippet for iOS 17+ (take HOST/PORT from the tunnel output):

   ```python
   from pymobiledevice3.remote.remote_service_discovery import RemoteServiceDiscoveryService
   rsd = RemoteServiceDiscoveryService((host, port))
   await rsd.connect()
   inspector = WebinspectorService(lockdown=rsd)
   ```

2. State when `create_using_usbmux()` suffices (per the skill's own matrix: iOS 16 and earlier; if the author has verified usbmux also works for webinspector on newer iOS, state that instead and drop the tunnel prerequisite for the automation flow).
3. Test on the actual device which of the two holds for its iOS version, and record the result in the skill instead of the current ambiguous combination.
