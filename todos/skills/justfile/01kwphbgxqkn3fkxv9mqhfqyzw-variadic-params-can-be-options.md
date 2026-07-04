# Variadic parameters CAN be `[arg]` options since 1.55.0; skill says they cannot (twice)

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — "`[arg]` attribute" section: "Variadic `+`/`*` parameters CANNOT be made into options."
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/attributes.md` — "`[arg]` — Parameter Options" section: same sentence.

**Current state**: Both files state variadic parameters cannot be turned into named options.

**Problem**: Outdated as of 1.55.0. Variadic parameters can be options, and the option becomes repeatable.

**Grounding**:
- Local test (just 1.55.0):
  ```just
  [arg('files', long='file')]
  pack *files:
    @echo "files={{files}}"
  ```
  `just pack --file a.txt --file b.txt` printed `files=a.txt b.txt` (exit 0).
- Changelog 1.55.0: "Allow variadic parameters to be options" (#3488).
- README attributes table: "`[arg(ARG, long=\"LONG\")]` ... If the parameter is variadic, the option is repeatable."

**Proposed change**: Replace the "CANNOT" sentence in both files with: variadic parameters may be options since 1.55.0, and the resulting `--long`/`-s` option is repeatable (each occurrence appends one value). For older just versions this is an error.

Related 1.55.0 `[arg]` additions worth adding in the same sections (all changelog 1.55.0):
- `[arg(multiple)]` — allow a non-variadic parameter to accept multiple values (#3493).
- `short` defaults to the first character of the parameter name when given bare (#3486).
- Combined short options are accepted on the CLI (#3490).
- `help`, `pattern`, and `value` may be const expressions; `pattern` may be a list (#3482–#3484, #3429).
