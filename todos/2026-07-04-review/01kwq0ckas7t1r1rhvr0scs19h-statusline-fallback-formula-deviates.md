# statusline fallback mode omits cache_creation tokens, deviating from the documented used_percentage formula

**Area**: claude-config
**File**: /Users/jakob/dotfiles/.claude/statusline-command.sh lines 46-58

## Current state

The fallback path (taken when `context_window.used_percentage` is
absent) reconstructs context usage from the transcript's last assistant
message:

```bash
input_toks=$(echo "$last_usage" | jq -r '.input_tokens // 0')
cache_toks=$(echo "$last_usage" | jq -r '.cache_read_input_tokens // 0')
total_toks=$((input_toks + cache_toks))
```

The filter above it (line 50) uses the same two-field sum to skip
sub-1000-token entries.

## Problem

The statusline docs define the reference formula with three terms
(https://code.claude.com/docs/en/statusline, "Context window fields",
fetched 2026-07-04):

> "The `used_percentage` field is calculated from input tokens only:
> `input_tokens + cache_creation_input_tokens + cache_read_input_tokens`.
> It does not include `output_tokens`."
> "If you calculate context percentage manually from `current_usage`,
> use the same input-only formula to match `used_percentage`."

The fallback omits `cache_creation_input_tokens`, so it undercounts
whenever cache entries are being written (most visibly on the first
requests of a session, where the system prompt and files land in
`cache_creation_input_tokens`).

The path is not purely legacy: the script header frames it as a
version fallback (Claude Code 2.0.27-2.1.71), but the same docs page
also states `context_window.used_percentage` "may be `null` early in
the session", so the fallback branch still runs at the start of every
session on current versions.

Everything else checked in the logic audit is sound: `resets_at` is
Unix epoch seconds per the docs table, matching `format_remaining`'s
arithmetic; the `// empty` jq guards match the docs' recommended
pattern for absent `rate_limits`; `mapfile` requires bash 4+ and the
Brewfile installs `bash` (line 19) and `jq` (line 47); `shellcheck`
passes with no findings; BSD grep accepts the `\s` ERE used on line 48
(verified 2026-07-04).

## Grounding

- Script lines quoted above (2026-07-04).
- https://code.claude.com/docs/en/statusline — formula and null-field
  quotes inlined above; `rate_limits.*.resets_at` documented as "Unix
  epoch seconds".
- `shellcheck .claude/statusline-command.sh` → no output (2026-07-04).

## Proposed change

Add `cache_creation_input_tokens` to both the filter (line 50) and the
sum (lines 55-57):

```bash
cache_creation_toks=$(echo "$last_usage" | jq -r '.cache_creation_input_tokens // 0')
total_toks=$((input_toks + cache_creation_toks + cache_toks))
```

Optionally reword the header comment so the fallback is described as
covering both older versions and the early-session null case.
