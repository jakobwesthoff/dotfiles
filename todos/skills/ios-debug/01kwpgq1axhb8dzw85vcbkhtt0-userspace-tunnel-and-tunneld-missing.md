# No-root connection options missing: `--userspace`, `--tunnel`/tunneld, `PYMOBILEDEVICE3_TUNNEL`

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, sections "Prerequisites" (item 4) and "4. RSD connection"

**Current state**: The skill only knows two connection modes: a manually started sudo tunnel in a separate terminal, and passing `--rsd <address> <port>` explicitly. The prerequisite framing is "The user must have ... started a tunnel in a separate terminal (required for iOS 17+)".

**Problem / opportunity**: Current pymobiledevice3 offers ways to avoid both the separate terminal and sudo entirely, which materially simplifies the workflow for an agent (no user hand-holding, no root):

1. `--userspace` flag (also `PYMOBILEDEVICE3_USERSPACE` env var): establishes the iOS 17+ tunnel *in-process* with a pure-Python userspace network stack, "so NO root/admin is required". Available on every command that takes a device (including all `webinspector` subcommands, which use `ServiceProviderDep`). Caveat from the same help text: host->device transfers are slower; and per the upstream guide, the tunnel address "lives only inside the pymobiledevice3 process, so it is not reachable from any other process" (i.e. it is per-invocation; it cannot serve the skill's separate Python heredoc).
2. `--tunnel <UDID>` (env var `PYMOBILEDEVICE3_TUNNEL`): consumes a tunnel managed by a long-running `pymobiledevice3 remote tunneld` daemon (started once with root), so individual commands need neither sudo nor `--rsd` coordinates.

**Grounding**:
- 9.33.0 sdist, `pymobiledevice3/cli/cli_common.py:201-276` (`make_rsd_dependency`): defines `--rsd` (metavar `HOST PORT`), `--tunnel` (envvar `TUNNEL_ENV_VAR = "PYMOBILEDEVICE3_TUNNEL"`, "Use a device discovered via tunneld"), and `--userspace` (envvar `PYMOBILEDEVICE3_USERSPACE`) with help text: "Establish the iOS 17+ tunnel in-process with a pure-Python userspace network stack, so NO root/admin is required. ... Use when you cannot run a privileged tunnel." The three are mutually exclusive.
- `cli/cli_common.py:369` — `ServiceProviderDep` builds on this dependency, and `cli/webinspector.py` commands (`opened_tabs`, `launch`, `js_shell`, `cdp`) all take `ServiceProviderDep`, so all accept `--userspace`/`--tunnel`/`--rsd`.
- Upstream tunnel guide (https://doronz88.github.io/pymobiledevice3/guides/ios17-tunnels/): tunneld is "a daemon process that runs continuously with root access, automatically managing tunnel connections"; userspace tunnel "requires no root/admin access", limitation: "the device's tunnel address lives only inside the pymobiledevice3 process, so it is not reachable from any other process."
- Upstream `misc/understanding_idevice_protocol_layers.md` (9.33.0 sdist, around line 470): "All the tunnels above need root/admin, since they create a kernel TUN/TAP interface. There's one more option that needs **no root at all**: add `--userspace` to any developer command to establish the iOS 17+ tunnel [in-process]".

**Proposed change**: Extend the connection guidance:
- For CLI commands (`opened-tabs`, `launch`, screenshots): document `--userspace` as the zero-setup path on iOS 17+ (no sudo, no separate terminal), with the caveat that it is slower for host->device transfers and per-invocation.
- Document `--tunnel <UDID>` / `PYMOBILEDEVICE3_TUNNEL` for setups where `remote tunneld` runs as a background daemon.
- Reframe the sudo-tunnel prerequisite as one option among three rather than an absolute requirement.
- Note that the Python heredoc cannot piggyback on `--userspace` from another process; it needs `--rsd`-style coordinates from a real tunnel (see the separate todo on the usbmux/RSD inconsistency) or its own in-process establishment via `pymobiledevice3.remote.userspace_tunnel.establish_userspace_rsd` (used by the CLI at `cli/cli_common.py:268`; API stability unverified — validate before documenting the Python-level call).
