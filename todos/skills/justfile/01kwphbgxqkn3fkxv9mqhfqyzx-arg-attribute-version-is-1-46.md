# `[arg]` named options are 1.46.0, not "1.45.0+" as the skill claims

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — heading "### `[arg]` attribute — named options (1.45.0+)"
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/attributes.md` — heading "### `[arg]` — Parameter Options (1.45.0+)"

**Current state**: Both headings tag the `[arg]` named-options feature as "1.45.0+".

**Problem**: The version tag is wrong for everything the sections actually show (`long`, `short`, `value`, `help`, `--usage`). Only `pattern` dates to 1.45.0. Someone on just 1.45.x following the skill would hit errors the tag says cannot happen.

**Grounding**:
- Changelog 1.45.0: "Allow requiring recipe arguments to match regular expression patterns" (#3000) — that release added only `pattern`.
- Changelog 1.46.0: "Allow recipes to take `--long` options" (#3026), "Allow passing arguments as short `-x` options" (#3028), "Add flags without values" (#3029), "Add --usage subcommand and argument help strings" (#3031), "Allow `long` to default to parameter name" (#3041).
- README attributes table: `[arg(ARG, long=…)]`, `[arg(ARG, short=…)]`, `[arg(ARG, value=…)]`, `[arg(ARG, help=…)]` all tagged 1.46.0; `[arg(ARG, pattern=…)]` tagged 1.45.0.

**Proposed change**: Change both headings to "1.46.0+" and, if per-keyword precision is wanted, tag `pattern` as 1.45.0 in the keyword table. Also tag `--usage` as 1.46.0 where invocation-primer.md shows it.
