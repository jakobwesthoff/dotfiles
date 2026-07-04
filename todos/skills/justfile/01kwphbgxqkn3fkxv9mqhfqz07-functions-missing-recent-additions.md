# functions.md is missing six stable functions and the user-defined-functions feature

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/functions.md`

**Current state**: The file claims to be a "Complete reference for all ~70 built-in functions" but lacks several functions present on just 1.55.0. It also has no mention of user-defined functions.

**Problem**: Gaps in a reference that advertises completeness; `recipe_name()` and `module_path()` in particular fill real needs (self-referential recipes, module-aware paths) that the skill currently cannot answer.

**Grounding** (versions from changelog; behavior verified on local just 1.55.0 where noted):
- `recipe_name()` (1.53.0, #3366) — returns the current recipe's name. Verified locally: recipe echoing `{{ recipe_name() }}` printed its own name.
- `module_path()` (1.50.0, #3270) — README: "Returns the `::`-separated path to the current module."
- `just_version()` (1.55.0, #3497) — verified locally: evaluates to `1.55.0`.
- `runtime_directory()` (1.49.0, #3226) — README: user-specific runtime directory; verified locally that it exists (on macOS it fails with `error: call to function 'runtime_directory' failed: runtime directory not found`, since the platform defines no runtime dir — worth a caveat).
- `config_local_directory()` / `data_local_directory()` — in the README "User Directories" list; missing from the skill's User Directories table (which lists only home/cache/config/data/executable).
- User-defined functions (1.49.0, #3247; currently unstable — verified locally: `double(x) := x + x` without unstable → `error: user-defined functions are currently unstable …`). README example:
  ```just
  set unstable

  hello(name) := f"Hello, {{ name }}!"
  ```
  Functions may reference assignments in the same module.

**Proposed change**:
1. Add `recipe_name()`, `module_path()`, `just_version()` to the "Invocation & File Info" table with version tags.
2. Add `runtime_directory()`, `config_local_directory()`, `data_local_directory()` to the User Directories table; note `runtime_directory()` aborts on platforms without a runtime dir (macOS).
3. Add a short "User-defined functions" subsection marked unstable (1.49.0+) with the `name(params) := expression` syntax, consistent with the skill's set-unstable policy (mention, don't recommend).
