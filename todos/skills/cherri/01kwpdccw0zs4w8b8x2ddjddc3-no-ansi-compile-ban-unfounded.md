# The "never use --no-ansi when compiling" rule is contradicted by actual compiler behavior

**Skill**: cherri
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/cherri/SKILL.md`, section "Invoking the compiler": "Use `--no-ansi` ONLY with `--action`, `--docs`, and `--glyph` lookups, NOT when compiling."
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/actions-and-includes.md`, section "Discovering actions via CLI": "Do NOT use `--no-ansi` when compiling `.cherri` files."
- `/Users/jakob/dotfiles/.claude/skills/cherri/references/patterns-and-practices.md`, section "CLI hygiene": "Use `--no-ansi` ONLY with `--action`, `--docs`, and `--glyph` lookups. Do NOT use `--no-ansi` when compiling `.cherri` files."

**Current state**: Three files state, as a hard rule, that `--no-ansi` must
not be used when compiling. No reason is given anywhere.

**Problem**: The rule is backwards for an LLM agent. Without `--no-ansi`,
compile warnings/errors arrive wrapped in ANSI escape sequences
(`[31m[1m...`), which pollute tool output. With `--no-ansi`, compilation
works identically and messages are plain text with a `(line:col)` suffix.
There is no observed downside to `--no-ansi` during compilation.

**Grounding** (local verification, Cherri Compiler v2.1.0, 2026-07-04):

- `cherri t02-barename.cherri --skip-sign` (no `--no-ansi`) prints the
  deprecation warning wrapped in escape codes: `[93m[1m\nWarning:[0m ...`.
- `cherri t02-barename.cherri --skip-sign --no-ansi` compiles the same
  file successfully (exit 0, `.shortcut` written) and prints the clean
  line `Warning: Deprecated: Prefix variable reference 'myVar' with @ for
  compilation speed and readability. (1:12)`.
- A failing compile with `--no-ansi` prints a clean single-line error
  (`Error: Invalid value 0.2 (float) for argument 'seconds' (number). ...`),
  also easier to parse than the ANSI-decorated multi-line frame.
- `cherri --help` documents the flag globally: `--no-ansi  Don't output
  ANSI escape sequences that format the output.` It is not scoped to
  lookup modes.

**Proposed change**: Invert the rule in all three files: ALWAYS pass
`--no-ansi` (lookups AND compiles) so output is clean plain text. If the
original rule stemmed from a real failure in an older compiler version,
that failure mode should be re-verified and documented explicitly instead
of the current unexplained prohibition.
