# settings.md is missing six settings added in 1.51.0–1.55.0

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/settings.md` — Quick Reference table (and, for `default-list`, the "default recipe listing" idioms in `references/basics.md` and `references/advanced-patterns.md`)

**Current state**: The Quick Reference table stops at settings that existed around 1.47; it lacks `default-list`, `default-script`, `dotenv-command`, `no-cd`, `minimum-version`, and `lists`.

**Problem**: The table presents itself as "All `set` directives"; on just 1.55.0 it is incomplete, and two of the missing settings (`default-list`, `dotenv-command`) directly improve patterns the skill teaches with workarounds.

**Grounding** (all verified on local just 1.55.0 unless noted):
- `set default-list` (1.52.0, changelog #3337): justfile with two recipes and `set default-list`; bare `just` printed "Available recipes:" listing instead of running the first recipe. Also available as `--default-list` / `JUST_DEFAULT_LIST` (in `just --help`). This natively replaces the skill's canonical idiom `default:` + `@just --list` shown in basics.md ("A common pattern — list available recipes") and advanced-patterns.md ("Default recipe listing").
- `set default-script` (1.52.0, changelog #3354; README: "recipes default to script recipes instead of shell recipes, unless overridden with the `[shell]` attribute"). Parsed locally.
- `set dotenv-command := '…'` (1.54.0, changelog #3441; README: "just runs it with the configured shell and loads its standard output as an environment file", example `set dotenv-command := 'sops -d .enc.env'`). Parsed locally.
- `set no-cd` (1.51.0, changelog #2981; README: "Don't change directory when executing recipes"). Parsed locally.
- `set minimum-version := '1.55.0'` (1.55.0, changelog #3477; README: "Error if just is older than minimum-version", string form MAJOR.MINOR.PATCH, should be placed at the top of the justfile). Ran locally, exit 0.
- `set lists` (1.53.0, unstable) — covered in detail by the separate todo `01kwphbgxqkn3fkxv9mqhfqyzr-logical-ops-and-which-now-require-set-lists.md`; add the table row here.

**Proposed change**:
1. Add the six rows to the Quick Reference table with the versions above; mark `lists` unstable.
2. Add a short "Dotenv" note for `dotenv-command` (secret-manager use case) next to the existing dotenv settings.
3. Update the "default recipe listing" idiom in basics.md and advanced-patterns.md to mention `set default-list` as the native alternative (version-gated 1.52.0+), keeping the `default: @just --list` recipe for older versions.
4. Mention `set minimum-version` as the mechanism for justfiles that rely on recent features.
