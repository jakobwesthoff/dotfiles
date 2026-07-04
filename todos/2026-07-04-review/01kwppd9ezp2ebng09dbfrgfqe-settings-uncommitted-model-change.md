# Uncommitted settings.json drift: model pin `claude-fable-5[1m]`, effort `xhigh`, `switchModelsOnFlag` — commit or revert; consider `fable` alias

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/settings.json lines 22, 39, 42

## Current state

`git diff .claude/settings.json` (2026-07-04):

```diff
-  "model": "opus",
+  "model": "claude-fable-5[1m]",
   ...
-  "effortLevel": "medium",
+  "effortLevel": "xhigh",
   ...
+  "switchModelsOnFlag": false,
```

Because `~/.claude/settings.json` is a symlink into the repo, every
`/model` or `/config` change made in any Claude Code session lands as
uncommitted drift in the dotfiles working tree.

## Assessment (all values valid and current)

- The change pattern matches Claude Code writing user settings itself:
  model-config docs state "Choosing it with `/model` saves it as the
  selected model in your user settings, so later sessions start on
  Fable 5 until you change models"
  (https://code.claude.com/docs/en/model-config).
- `[1m]` suffix on a full model name is documented syntax ("Or append
  `[1m]` to a full model name — `/model claude-opus-4-8[1m]`", same
  page). Note it is a no-op on the Anthropic API for this model: "On
  the Anthropic API, Fable 5, Sonnet 5, Opus 4.8, and Opus 4.7 always
  run with the 1M window."
- `effortLevel: "xhigh"` is a documented value (settings reference:
  accepts `"low"`, `"medium"`, `"high"`, or `"xhigh"`).
- `switchModelsOnFlag` is not in the settings reference table, but
  corresponds to the documented `/config` toggle: "run `/config` and
  turn off 'switch models when a message is flagged'" (model-config
  docs, automatic model fallback section). Claude Code wrote it.

## Problem / opportunity

1. The drift needs a decision: commit (if Fable 5 + xhigh is the
   intended default) or revert.
2. If committing, the full-name pin `claude-fable-5` freezes the model
   version. Docs: "Aliases point to the recommended version for your
   provider and update over time. To pin to a specific version, use the
   full model name." A `fable` alias exists ("`fable` — Uses Claude
   Fable 5 for your hardest and longest-running tasks"), as does
   `best` ("Uses Fable 5 where your organization has access to it,
   otherwise the latest Opus model"). `"model": "fable"` would track
   future Fable versions and drops the redundant `[1m]`.

## Grounding

- Diff output above (2026-07-04).
- https://code.claude.com/docs/en/model-config (alias table, extended
  context section, flagged-request toggle; quotes inlined above).
- https://code.claude.com/docs/en/settings (effortLevel row).

## Proposed change

Decide and commit: either keep the picker-written value as is, or
normalize to `"model": "fable"` (or `"best"`) before committing.
`switchModelsOnFlag: false` is a deliberate-looking toggle (flagged
requests pause instead of silently switching to Opus); keep it if that
behavior is wanted.
