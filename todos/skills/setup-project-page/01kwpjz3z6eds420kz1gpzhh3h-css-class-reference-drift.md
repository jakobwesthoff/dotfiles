# CSS Class Quick Reference drifts from the actual stylesheets

**Skill**: setup-project-page
**File**: `/Users/jakob/dotfiles/.claude/skills/setup-project-page/references/sections.md` — "CSS Class Quick Reference" section

**Current state / problems** (three distinct drifts in the same table set):

1. **`.bg-alt` does not exist.** The Layout table lists
   `.bg-alt | Alternate background color`. No stylesheet defines a
   `.bg-alt` class; only the CSS variable `--color-bg-alt` exists.
   An agent applying `class="bg-alt"` gets no effect.
2. **Spacing utility sizes are wrong.** The table claims
   `.mt-{size}` / `.mb-{size}` / `.py-{size}` / `.px-{size}` all come in
   `xs, sm, md, lg, xl, 2xl`. Actual classes: no `xs` variant exists for
   any pattern; `mt`/`mb` come in `0, sm, md, lg, xl` (the `0` variant is
   undocumented); `py` comes in `sm, md, lg, xl, 2xl`; `px` comes only in
   `sm, md, lg`.
3. **Several real classes are undocumented**: `.demo-video` (frameless
   demo video), `.card`, `.docs-table` + `.table` (the wrapper/table pair
   the markdown renderer emits for README tables), `.hero-logo-full`,
   `.text-xl`, `.text-bright`, `.text-primary`, `.text-left`,
   `.text-right`, `.flex`, `.flex-center`, `.flex-between`,
   `.gap-sm/md/lg`, `.hidden`, `.visually-hidden`, `.block`,
   `.inline-block`.

**Grounding**: Extracted all class selectors from
`templates/styles/{layout,components,utilities,base}.css` in
`jakobwesthoff/project-page-starter` (local clone at origin HEAD,
commit e9be969) via
`grep -oE '^\.[a-zA-Z][a-zA-Z0-9_-]*' ... | sort -u`. Full result
confirms: no `.bg-alt` anywhere (a separate `grep -rn 'bg-alt'` over
`templates/` finds only the `--color-bg-alt` variable and its usages);
spacing utilities exactly as listed in point 2 (matches the repo
`GUIDE.md` "Spacing" list: `.mt-0, .mt-sm, .mt-md, .mt-lg, .mt-xl`,
same for `mb`, `.py-sm ... .py-2xl`, `.px-sm, .px-md, .px-lg`); every
class in point 3 present in the stylesheets. All other classes in the
skill's tables verified to exist.

**Proposed change**:

1. Delete the `.bg-alt` row (or replace with a note that alternate
   backgrounds come from the section classes `.demo`/`.docs`, which set
   `background-color: var(--color-bg-alt)` per layout.css).
2. Rewrite the spacing table with the real per-pattern size lists,
   including the `0` variants.
3. Add the missing classes that are useful in section authoring (at
   minimum `.demo-video`, `.card`, `.docs-table`/`.table`,
   `.hero-logo-full`, flex/gap utilities).
