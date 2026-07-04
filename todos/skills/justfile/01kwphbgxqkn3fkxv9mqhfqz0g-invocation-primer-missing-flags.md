# invocation-primer.md omits several authoring-relevant CLI flags

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/invocation-primer.md` — "Key Flags for Authoring Decisions" section

**Current state**: The section covers `--list`, `--dry-run`, `--choose`, `--dump`/`--fmt`, `--justfile`/`--working-directory`, quiet/verbose, and unstable. The env-var table (verified correct against `just --help` on 1.55.0) covers nine flags.

**Problem / opportunity**: Flags that change how users consume a justfile — and therefore how one should author it — are missing.

**Grounding** — all present in `just --help` output of installed just 1.55.0 (help text quoted); versions from changelog where recent:
- `--no-deps` — "Don't run recipe dependencies" (`JUST_NO_DEPS`). Authoring impact: recipes should not assume dependencies always ran.
- `-s, --show <PATH>...` — "Show recipe at <PATH>". Complements `--list` for inspecting a single recipe.
- `--explain` — "Print recipe doc comment before running it" (`JUST_EXPLAIN`). Another consumer of doc comments beyond `--list`.
- `--allow-missing` — "Ignore missing recipe and module errors" (1.38.0, changelog #2460).
- `--init` — "Initialize new justfile in project root".
- `--json` — "Print justfile as JSON", synonym for `--dump --dump-format json` (1.48.0, changelog #3143).
- `--group <GROUP>` — "Only list recipes in <GROUP>" (1.47.0, changelog #3117); also `--choose` can be filtered by `--group` (1.50.0, changelog #3298). Strengthens the case for `[group]` usage.
- `--time` — "Print recipe execution time" (1.49.0, changelog #3099); `--timestamp` — "Print recipe command timestamps".
- `--evaluate` / `--variables` — "Evaluate and print all variables" / "List names of variables"; useful for debugging variable-heavy justfiles (see also the separate SKILL.md validation todo).
- `-E`/`-F` short forms for `--dotenv-path`/`--dotenv-filename` (`-F` added 1.55.0, changelog #3498).

**Proposed change**: Add a compact subsection or extend the existing tables with the flags above (one line each, authoring impact where non-obvious). Keep the existing env-var table as is; it was verified accurate.
