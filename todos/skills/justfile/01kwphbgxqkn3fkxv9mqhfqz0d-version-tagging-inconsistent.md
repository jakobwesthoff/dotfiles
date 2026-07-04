# Version tagging is inconsistent: some features tagged, equally recent ones untagged

**Skill**: justfile
**Files**: all reference files; most affected: `references/basics.md`, `references/attributes.md`, `references/settings.md`, `references/functions.md`, `references/conditionals-and-flow.md`

**Current state**: The skill tags some features with introduction versions (x-strings 1.27.0, f-strings 1.44.0, `[arg]` "1.45.0+", settings expressions 1.46.0, duplicate imports 1.37.0, expression line continuation 1.15.0, HEX 1.27.0, ANSI constants 1.37.0, PATH_SEP 1.41.0) but presents other, equally recent or newer features with no version at all.

**Problem**: The untagged features silently require recent just versions. Distro-packaged just is often much older (e.g. Debian/Ubuntu ship 1.2x–1.3x era builds), so a justfile written from the skill can fail to parse there with no hint from the skill about which construct is the culprit. SKILL.md's validation flow catches this only when the target machine's just is the one running validation.

**Grounding** — verified introduction versions from the just changelog (all present in installed 1.55.0; existing tags in the skill were also re-verified and are correct):
- `[default]` attribute: 1.43.0 (#2878) — presented untagged in basics.md and attributes.md.
- `?` guard sigil + `set guards`: 1.47.0 (#2547) — untagged in basics.md, conditionals-and-flow.md, settings.md.
- `[env(NAME, VALUE)]`: 1.47.0 (#2957) — untagged in attributes.md.
- `[metadata]`: 1.42.0 (#2794) — untagged in attributes.md.
- `[parallel]`: 1.42.0 (#2803) — untagged in attributes.md and advanced-patterns.md.
- Cross-module dependencies (`bar: foo::build`): 1.42.0 (#2672) — untagged in basics.md.
- Aliases targeting submodule recipes (`alias baz := foo::bar`): 1.40.0 (#2632) — untagged in basics.md.
- `--usage`: 1.46.0 (#3031) — untagged in attributes.md and invocation-primer.md.
- `which()`/`require()`: 1.39.0 (#2440); `read()`: 1.39.0 (#2507 + rename #2518); `!~`: 1.39.0 (#2490); `[exit-message]`: 1.39.0 (#2568).
- `datetime()`/`datetime_utc()`: 1.30.0 (#2167); `is_dependency()`: 1.29.0 (#2139); `unexport`: 1.29.0 (#2098).
- `working-directory` setting and `set script-interpreter`/empty `[script]`: 1.33.0 (#2283, #2264); `[script(COMMAND)]`: 1.32.0; `[script]` stabilized 1.44.0 (#2988).
- `--ceiling`: 1.43.0 (#2870); `--allow-missing`: 1.38.0 (#2460).

**Proposed change**: Pick one policy and apply it consistently. Suggested: tag every feature introduced in or after 1.27.0 (the oldest version the skill already tags), using the version list above; leave pre-1.27 features untagged as baseline. Alternatively drop all tags and add a single SKILL.md note to check `just --version` against the manual — but the per-feature tags are more useful to an LLM choosing constructs for a target environment.
