# Dotenv files ARE loaded in submodules since 1.49.0; skill claims root-only in four places

**Skill**: justfile
**Files**:
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/settings.md` — intro ("Exception: dotenv loading only happens at the root"), "Dotenv Settings" section ("Dotenv loading occurs ONLY for the root justfile", "Dotenv settings in submodules are **ignored**"), Anti-Patterns ("NEVER expect dotenv settings in submodules to load env files")
- `/Users/jakob/dotfiles/.claude/skills/justfile/references/modules-and-imports.md` — "Scoping Rules" ("Dotenv loading happens ONLY at the root...") and Anti-Patterns ("NEVER put dotenv settings in submodules — they are ignored")

**Current state**: Four separate statements assert that only the root justfile's dotenv settings are honored and submodule dotenv settings are ignored.

**Problem**: Factually wrong on current just. A submodule with `set dotenv-load` and its own `.env` loads that file. The skill's hard "NEVER" rules would steer authors away from a working, supported pattern.

**Grounding**:
- Local test (just 1.55.0): root justfile `mod denv`; `denv/mod.just` contains `set dotenv-load` and a recipe echoing `${SUBVAR:-unset}`; `denv/.env` contains `SUBVAR=loaded-from-submodule-env`. `just denv show` printed `SUBVAR=loaded-from-submodule-env`.
- Changelog 1.49.0: "Load environment files in submodules" (#3243).
- README "Dotenv Settings": "Variables in environment files loaded in parent modules are inherited by submodules. Environment files are loaded in submodules (1.49.0) and may override variables defined in parent module environment files."

**Proposed change**: Replace the root-only claims with the current semantics:
1. Submodules can load their own environment files via their own dotenv settings (1.49.0+).
2. Env vars from parent-module environment files are inherited by submodules; submodule env files may override parent values.
3. Delete both anti-pattern bullets, or rewrite them for pre-1.49 compatibility as an explicitly version-conditional note.
Keep the still-correct fact that loaded variables are shell environment variables (`$NAME`), not just variables.
