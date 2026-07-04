# `--fmt` is stable since 1.50.0; skill still calls it unstable and appends `--unstable`

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/SKILL.md` — "Validating justfiles" command list (`just --justfile /path/to/justfile --fmt --check --unstable`)
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/advanced-patterns.md` — "Formatting" section
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/invocation-primer.md` — "`--dump` / `--fmt`" section

**Current state**:
- advanced-patterns.md: "`--fmt` is currently unstable." with examples `just --fmt --unstable` and `just --fmt --check --unstable`.
- SKILL.md and invocation-primer.md show `--fmt` commands with `--unstable` appended.

**Problem**: Outdated. Passing `--unstable` is harmless but the prose claim "currently unstable" is false on current just, and the extra flag teaches a stale invocation.

**Grounding**:
- Changelog 1.50.0: "Stabilize `--fmt` subcommand" (#3301).
- Local test (just 1.55.0): `just -f <file> --fmt --check` without `--unstable` ran, exited 1 for an unformatted file, and printed a unified diff plus `error: formatted justfile differs from original`.
- `just --help` (1.55.0) lists `--fmt` and `--check` with no unstable annotation; `--check` help text: "Run `--fmt` in 'check' mode. Exits with 0 if justfile is formatted correctly. Exits with 1 and prints a diff if formatting is required."

**Proposed change**:
1. Drop `--unstable` from all `--fmt` invocations in SKILL.md, advanced-patterns.md, and invocation-primer.md; delete the "currently unstable" sentence.
2. Optionally note that `--fmt --check` prints a diff on failure (verified above), and that recipe body indentation used by the formatter is configurable via `--indentation` (present in `just --help` 1.55.0, default four spaces).
