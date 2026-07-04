# settings.json stale entries: legacy `voiceEnabled` key and unused `claude-code-plugins` marketplace

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/settings.json lines 30-37 and 46

## Current state

```json
"extraKnownMarketplaces": {
  "claude-code-plugins": {
    "source": { "source": "github", "repo": "anthropics/claude-code" }
  }
},
...
"voiceEnabled": true
```

## Problems

1. **`voiceEnabled` is a legacy alias.** Settings reference
   (https://code.claude.com/docs/en/settings): "`voiceEnabled` — Legacy
   alias for `voice.enabled`. Prefer the `voice` object." The modern
   form is `"voice": { "enabled": true }` and carries the additional
   `mode`/`autoSubmit` options.

2. **The extra marketplace is registered but unused.** The
   `claude-code-plugins` marketplace resolves (it is a valid
   marketplace: `anthropics/claude-code` contains
   `.claude-plugin/marketplace.json` offering agent-sdk-dev,
   code-review, commit-commands, explanatory-output-style, and a
   claude-opus-4-5-migration plugin; the local mirror at
   `~/.claude/plugins/marketplaces/claude-code-plugins` last refreshed
   2026-07-04). But nothing is installed or enabled from it:
   `~/.claude/plugins/installed_plugins.json` lists only
   `@claude-plugins-official` plugins, and `enabledPlugins` contains
   only `frontend-design@claude-plugins-official`. The entry costs a
   marketplace refresh and provides nothing.

## Grounding

- `settings.json` content (quoted above), read 2026-07-04.
- https://code.claude.com/docs/en/settings — `voiceEnabled` row quoted
  above; `extraKnownMarketplaces` documented as "Defines additional
  marketplaces that should be made available".
- `cat ~/.claude/plugins/known_marketplaces.json`,
  `installed_plugins.json`, and the marketplace's `marketplace.json`
  (2026-07-04).

## Proposed change

- Replace `"voiceEnabled": true` with `"voice": { "enabled": true }`.
- Remove the `extraKnownMarketplaces` block (and optionally
  `claude plugin marketplace remove claude-code-plugins`), unless a
  plugin from that marketplace is actually wanted, in which case enable
  it so the registration earns its keep.
