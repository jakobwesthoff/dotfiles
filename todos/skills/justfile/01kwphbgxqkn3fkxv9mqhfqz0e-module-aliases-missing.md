# Module aliases (`alias m := some_module`, 1.55.0) are missing

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/basics.md` — "Aliases" section
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/modules-and-imports.md` — no alias coverage

**Current state**: The aliases section covers recipe targets and submodule *recipe* targets (`alias baz := foo::bar`). Aliasing a whole module is not mentioned.

**Problem**: Feature gap for multi-module justfiles: short names for frequently used modules.

**Grounding**:
- Local test (just 1.55.0): root justfile with `mod sub` and `alias s := sub`; `just s build` ran the submodule recipe (printed `SUB-BUILD`, exit 0).
- Changelog 1.55.0: "Add module aliases" (#3472).

**Proposed change**: Add one line to the basics.md Aliases section (and/or modules-and-imports.md): aliases may target modules since 1.55.0 (`alias s := sub`), after which `just s <recipe>` works like `just sub <recipe>`.
