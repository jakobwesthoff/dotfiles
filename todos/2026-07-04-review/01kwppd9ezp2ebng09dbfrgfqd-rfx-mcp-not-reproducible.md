# CLAUDE.md depends on the rfx MCP server, but neither its registration nor the binary is reproducible from the dotfiles

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/CLAUDE.md line 263; /Users/jakob/dotfiles/Brewfile; /Users/jakob/dotfiles/initial_macos_setup.sh

## Current state

CLAUDE.md line 263 instructs every session:

> Prefer the reflex/rfx mcp server over grepping and searching through
> code files directly if possible.

The server is registered only in `~/.claude.json` (user-scope MCP
config, mutable Claude Code state, not tracked in dotfiles):

```json
"rfx": { "type": "stdio", "command": "rfx", "args": ["mcp"], "env": {} }
```

`rfx`/`reflex` appears nowhere in `Brewfile`, `initial_macos_setup.sh`,
or `checkout_dependencies.sh` (grep on 2026-07-04 returned no matches).

## Problem

On a fresh machine bootstrapped from these dotfiles (stow + Brewfile +
setup scripts), the global instruction would reference an MCP server
that is neither installed nor registered. Every Claude Code session
would carry a directive it cannot follow. This is the one piece of
`~/.claude`-adjacent state that the repo's symlink deployment does not
capture, because user-scope MCP servers live in `~/.claude.json` rather
than `~/.claude/settings.json`.

## Grounding

- `jq '.mcpServers' ~/.claude.json` output quoted above (2026-07-04).
- `grep -in 'rfx\|reflex' Brewfile initial_macos_setup.sh checkout_dependencies.sh`
  returned nothing (2026-07-04).
- Settings docs list `~/.claude.json` as "Other config: OAuth, MCP
  servers, caches", separate from the settings files
  (https://code.claude.com/docs/en/settings).

## Proposed change

Two parts, both needed for reproducibility:

1. Install source for the `rfx` binary: add it to `Brewfile` or the
   setup scripts (determine first how it was installed on this machine,
   e.g. `which rfx` and the owning package manager).
2. Registration: add `claude mcp add --scope user rfx -- rfx mcp` to
   `initial_macos_setup.sh` (or a dedicated bootstrap step), so the
   user-scope MCP entry is recreated on new machines.

Alternatively, if rfx is only relevant on this machine, soften the
CLAUDE.md wording to "if the rfx MCP server is available" so the
instruction degrades gracefully.

## Correction (second pass)

The open question in proposed-change item 1 is resolved: the binary is
cargo-installed. `which rfx` → `/Users/jakob/.cargo/bin/rfx`;
`cargo install --list` shows the owning crate as `reflex-search v1.1.0`
(binary `rfx`, `rfx --version` → `rfx 1.1.0`); verified 2026-07-04.
The install step for item 1 is therefore
`cargo install reflex-search`, not a Brewfile entry.
