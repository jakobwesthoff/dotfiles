# Decide mini.bracketed scope vs native 0.11+ bracket mappings (and untangle `]t`)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Situation

The config loads `mini.bracketed` with default opts
(`lua/mrjakob/plugins/mini.lua:6-9`). Since 0.11, Neovim ships native
unimpaired-style bracket mappings; on the running build they are defined
in `runtime/lua/vim/_core/defaults.lua`:

| Native maps | Target | Lines |
|---|---|---|
| `[d ]d [D ]D` | diagnostics | 263-277 |
| `[q ]q [Q ]Q [<C-Q> ]<C-Q>` | quickfix | 303-325 |
| `[l ]l [L ]L [<C-L> ]<C-L>` | location list | 328-350 |
| `[a ]a [A ]A` | argument list | 353-376 |
| `[t ]t [T ]T [<C-T> ]<C-T>` | **tags** | 379-411 |
| `[b ]b [B ]B` | buffers | 414-436 |
| `[<Space> ]<Space>` | add blank lines | 439-449 |

mini.bracketed's targets (installed `mini.bracketed/README.md:49-64`):
buffer **b**, comment **c**, conflict **x**, diagnostic **d**, file
**f**, indent **i**, jump **j**, location **l**, oldfile **o**,
quickfix **q**, **treesitter t**, undo **u**, window **w**, yank **y** —
each with `[x [X ]x ]X` variants.

### Overlap analysis

- **Same target, mini wins:** `b`, `d`, `l`, `q`. mini's maps are set in
  `setup()` via `vim.keymap.set` (plugin source `bracketed.lua:113-121`,
  H.map at :1978) after core init, so they override native. mini adds
  counts, wraparound, and Visual/Operator-pending modes over native.
- **Same key, different semantics:** `]t`/`[t` — native: tag stack
  navigation (`:tnext`/`:tprevious`); mini: treesitter node navigation.
- **mini-only:** `c x f i j o u w y`.
- **native-only:** arglist `a/A`, the `<C-Q>/<C-L>/<C-T>` file-wise
  variants, `[<Space>/]<Space>`.

### The `]t` three-way conflict

Load order: `setup.lua` runs `lazy.setup()` (loads mini.bracketed) and
*then* `require("mrjakob.keymaps")`. `keymaps.lua:180-185` maps
normal-mode `]t`/`[t` to todo-comments jump_next/jump_prev. Final
state: normal mode `]t` = todo-comments; visual/operator-pending `]t` =
mini.bracketed treesitter; native tag navigation = shadowed everywhere.
Three owners for one key across modes — works, but only by accident of
load order.

### Hidden side effect

mini.bracketed's `undo` target remaps `u` and `<C-R>` globally
(README.md:68) to route undo/redo through its tracked history. This is
active right now (default opts). Whether that behavior is wanted has
never been decided in this config.

## Evidence / basis

- Runtime `_core/defaults.lua` lines as tabulated (read 2026-06-11).
- Installed mini.bracketed source/README lines as cited.
- Config: `mini.lua:6-9`, `keymaps.lua:180-185`, `setup.lua:22-33`
  (load order).

## Decision to make + suggested shape

Pick which targets mini should own. A reasonable split that keeps
everything intentional:

```lua
{
  "echasnovski/mini.bracketed",
  opts = {
    -- covered natively since 0.11 (keep native: plain motions suffice)
    buffer     = { suffix = "" },
    diagnostic = { suffix = "" },
    location   = { suffix = "" },
    quickfix   = { suffix = "" },
    -- avoid the ]t pile-up: todo-comments owns n-mode ]t
    treesitter = { suffix = "" },
    -- deliberate choice needed: u/<C-R> remap on/off
    undo       = { suffix = "" },  -- or keep, consciously
  },
},
```

Then `]t` is cleanly todo-comments (normal mode) and native tags remain
available via `:tnext` or by moving todo-comments elsewhere. If instead
mini's richer count/wrap behavior on b/d/l/q is valued, keep those and
accept the native shadowing — but write that decision down in the spec
as a comment.

If after trimming only a couple of targets remain in use, evaluate
dropping mini.bracketed entirely.
