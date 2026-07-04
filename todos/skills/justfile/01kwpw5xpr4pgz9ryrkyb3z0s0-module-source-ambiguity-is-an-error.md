# Module "file resolution order" is not a priority order: multiple candidates are an error

**Skill**: justfile
**File**: `/Users/jakob/dotfiles/.claude/skills/justfile/references/modules-and-imports.md` — "File resolution order" section

**Current state**:
> When declaring `mod foo`, `just` searches for:
>
> 1. `foo.just`
> 2. `foo/mod.just`
> 3. `foo/justfile` (any capitalization)
> 4. `foo/.justfile` (any capitalization)

**Problem**: The numbered list reads as a priority order where the first
match wins. On just 1.55.0 there is no priority: if more than one candidate
exists, `just` refuses to load the module. An author following the skill
could keep `foo.just` and `foo/mod.just` side by side expecting `foo.just`
to win; instead every invocation fails.

**Grounding**:
- Local test (just 1.55.0): root justfile `mod amb` with both `amb.just`
  and `amb/mod.just` present → exit 1,
  `` error: found multiple source files for module `amb`: `amb/mod.just` and `amb.just` ``.
- README (casey/just master, "Modules" section): "If a module is named
  `foo`, `just` will search for the module file in `foo.just`,
  `foo/mod.just`, `foo/justfile`, and `foo/.justfile`. In the latter two
  cases, the module file may have any capitalization." — "search", not a
  ranked order.

**Proposed change**: Present the four locations as a candidate set:
`just` looks in these four places and exactly one must exist; multiple
candidates fail with `found multiple source files for module …`. Renumber
the list to bullets to remove the priority implication.
