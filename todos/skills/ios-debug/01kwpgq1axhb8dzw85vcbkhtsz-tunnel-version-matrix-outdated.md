# Tunnel version matrix diverges from upstream guidance and omits iOS 26

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, section "Prerequisites", item 4 (tunnel commands per iOS version)

**Current state**:

> 4. Started a tunnel in a separate terminal (required for iOS 17+):
>    - **iOS 18.2+**: `sudo pymobiledevice3 remote start-tunnel -p tcp`
>    - **iOS 17.4–18.1**: `sudo pymobiledevice3 lockdown start-tunnel`
>    - **iOS 17.0–17.3**: `sudo pymobiledevice3 remote start-tunnel`
>    - **iOS 16 and earlier**: no tunnel needed.

**Problem**: The matrix is stale and more complicated than upstream's own guidance:

1. The upstream guide recommends `sudo pymobiledevice3 lockdown start-tunnel` for **all** iOS 17.4+, with no 18.1 upper bound. The skill's 18.2+ row switches back to `remote start-tunnel -p tcp` unnecessarily.
2. The 18.2+ row encodes the iOS 18.2 QUIC removal, but `lockdown start-tunnel` is unaffected by it: in pymobiledevice3 9.33.0 it hardcodes TCP (`pymobiledevice3/cli/lockdown.py:199`: `protocol=TunnelProtocol.TCP`).
3. `-p tcp` is now the default for `remote start-tunnel` on Python >= 3.13: `pymobiledevice3/remote/common.py:10-15` defines `TunnelProtocol.DEFAULT = TCP if sys.version_info >= (3, 13) else QUIC`, and the option help in `cli/remote.py` reads "Transport protocol for the tunnel (default: TCP on Python >=3.13, otherwise QUIC)".
4. iOS 26 (current major, given macOS 26 host) is not covered; upstream's open-ended "17.4+" covers it, the skill's closed "17.4–18.1" bucket does not.
5. Version-bucketed instructions are exactly the "time-sensitive information" anti-pattern from Anthropic's skill best practices, which recommends a "current method" section plus a collapsed "old patterns" section.

**Grounding**:
- Upstream tunnel guide (https://doronz88.github.io/pymobiledevice3/guides/ios17-tunnels/): "iOS 17.4+: Use the faster lockdown tunnel: `sudo python3 -m pymobiledevice3 lockdown start-tunnel`"; "iOS 17.0–17.3.1: fall back to `sudo python3 -m pymobiledevice3 remote start-tunnel`". Both need sudo because they "create a TUN/TAP interface".
- iOS 18.2 QUIC removal: pymobiledevice3-based tools raise `QuicProtocolNotSupportedError` ("iOS 18.2+ removed QUIC protocol support. Use TCP instead") — e.g. https://github.com/nexron171/SimVirtualLocation/issues/20 and https://github.com/altstoreio/AltStore/issues/1591.
- 9.33.0 sdist: `cli/lockdown.py:194-214` (`lockdown start-tunnel`, `@sudo_required`, forces `TunnelProtocol.TCP`); `cli/remote.py:247-297` (`remote start-tunnel`, `@sudo_required`, `--protocol/-p` defaulting to `TunnelProtocol.DEFAULT`); `remote/common.py:10-15` (DEFAULT = TCP on Python >= 3.13).
- Anthropic skill best practices (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), "Avoid time-sensitive information": bad example is exactly a date/version-conditional instruction; recommended shape is a "Current method" section plus an "Old patterns" collapsed block.

**Proposed change**: Collapse the matrix to:
- Current method (iOS 17.4+, including 18.x and 26): `sudo pymobiledevice3 lockdown start-tunnel`.
- Old patterns: iOS 17.0–17.3.1 only: `sudo pymobiledevice3 remote start-tunnel` (add `-p tcp` when running under Python < 3.13, since QUIC is otherwise the default there and iOS 18.2+ devices reject QUIC — though those versions are all >= 17.4 anyway); iOS 16 and earlier: no tunnel.

See the separate todo on `--userspace`/tunneld for no-sudo alternatives that may replace this prerequisite entirely.
