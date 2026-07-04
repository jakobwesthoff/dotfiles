# `start-tunnel --script-mode` gives machine-parsable RSD coordinates; skill treats tunnel output as prose

**Skill**: ios-debug; **File**: `/Users/jakob/dotfiles/.claude/skills/ios-debug/SKILL.md`, sections "Prerequisites" item 4 and "4. RSD connection (if tunnel output gives address)".

**Current state**: The tunnel commands are given without `--script-mode`, and section 4 says "When the tunnel provides an RSD address, pass it explicitly" — leaving the agent to scrape host/port out of the human-oriented, colorized multi-line tunnel banner.

**Problem / opportunity**: Both tunnel commands accept `--script-mode`, which reduces the output to a single `ADDRESS PORT` line, exactly the two values `--rsd` needs. If the skill keeps any tunnel-based flow (see `01kwpv2rx8qqvkvz165vx90g65` for whether webinspector needs one at all), the handoff between "user starts tunnel" and "agent passes `--rsd HOST PORT`" becomes copy-paste-proof.

**Grounding** (pymobiledevice3 9.33.0 sdist):

- `cli/remote.py:165-166` (`tunnel_task`): `if script_mode: print(f"{tunnel_result.address} {tunnel_result.port}", flush=True)` — the entire script-mode output.
- `cli/lockdown.py:208-211`: `lockdown start-tunnel` option help: "Show only HOST and port number to allow easy parsing from external shell scripts". `cli/remote.py:268` defines the same option for `remote start-tunnel`.
- Upstream's own agent doc, `.codex/skills/pymobiledevice3-device-operator/references/transport-and-safety.md:39-41`: "For Codex-driven tunnel setup, invoke `lockdown start-tunnel` or `remote start-tunnel` with `--script-mode`. ... Read the RSD host and port from the command's stdout and reuse those exact values in later commands."

**Proposed change**: Wherever the skill shows a `start-tunnel` command, add `--script-mode` and state the output contract: the command stays in the foreground and prints one line, `ADDRESS PORT`; those two values are what `--rsd` takes. Update section 4's title/framing ("if tunnel output gives address" implies the address is optional output; it is always printed).
