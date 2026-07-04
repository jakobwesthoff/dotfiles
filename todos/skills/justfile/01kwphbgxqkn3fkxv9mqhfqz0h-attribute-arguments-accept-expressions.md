# `[confirm]`, `[env]`, and `[working-directory]` accept expressions since 1.49.0/1.51.0; skill shows literals only

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/attributes.md` — rows for `[confirm]`, `[env]`, `[working-directory]`

**Current state**: All attribute examples and table rows show string-literal arguments (`[confirm("prompt")]`, `[env("VAR", "VALUE")]`, `[working-directory("path")]`) with no mention that expressions are accepted.

**Problem**: Minor capability gap. Expression arguments enable patterns like `[working-directory(justfile_directory() / 'build')]` or `[env('CACHE', cache_directory())]` that the skill currently gives no basis for.

**Grounding** (changelog):
- 1.49.0: "Allow expressions in confirm attribute" (#3238).
- 1.51.0: "Allow `[env]` attribute to take expressions" (#3329); "Allow using expressions with `[working-directory]`" (#3326).
- README attributes table: "`[env(NAME, VALUE)]` … `NAME` and `VALUE` may be expressions (1.51.0)"; "`[working-directory(PATH)]` … `PATH` may be an expression (1.51.0)".
- Also 1.45.0: "Allow shell-expanded strings in attributes" (#3007) — `x'…'` strings work as attribute arguments.

**Proposed change**: Add a one-line note under the attributes Syntax Forms section: attribute arguments may be expressions for `[confirm]` (1.49.0+), `[env]` and `[working-directory]` (1.51.0+), and shell-expanded `x'…'` strings are allowed in attributes (1.45.0+).
