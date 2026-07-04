# nvim: the config's own todos carry stale references (deleted review doc, already-fixed comment, WezTerm)

**Area**: nvim
**File**: /Users/jakob/dotfiles/.config/nvim/todos/ (all three files)

## Current state

The config maintains three todos of its own:

- `experiments/01ktw3wfn36mvynnh95nzbn4z9-vim-pack-migration-evaluation.md`
- `native-replacements/01ktw3wfn36mvynnh95nzbn4z3-osc52-native-clipboard.md`
- `plugin-updates/01ktw3wfn36mvynnh95nzbn4zd-dressing-snacks-input-reevaluation.md`

All three open with "Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`)".

## Problem / drift found (verified 2026-07-04)

1. **The referenced review doc no longer exists.** Commit 40d5c2e
   (2026-06-14, "Removed fully handled neovim code review document") deleted
   `.config/nvim/docs/code-review-2026-06-11.md` and
   `.config/nvim/docs/used-plugins.md`. The provenance pointer in all three
   todos is dangling; each todo is otherwise self-contained.
2. **The osc52 todo lists an already-fixed item.** Its "Also:" bullet claims
   "the explanatory comment block is duplicated nearly verbatim
   (autocmds.lua:11-14 and :16-20)". Commit e5575c6 (2026-06-14, "Sweep
   typos, dead code, and small inconsistencies") de-duplicated that comment;
   the current `lua/mrjakob/autocmds.lua:11-15` has a single comment block.
   The todo's core content (manual OSC 52 autocmd vs. native provider) is
   still accurate: autocmds.lua:16-29 still hardcodes channel 2, flattens
   `regcontents` with `table.concat(..., "\n")`, and only fires for `+`/`*`.
3. **The osc52 todo's test-environment list names WezTerm.** "Test option 1
   (plain deletion) first in the real environments this matters in — local
   iTerm/WezTerm+tmux and an SSH session". The WezTerm config was removed in
   commit 2274eea ("Removed wezterm config as I by now only use ghostty");
   the relevant local terminal is now ghostty.

## What was re-verified and is NOT drifted

- **dressing/snacks todo**: still fully valid. Installed snacks.nvim is now
  882c996 (2026-05-25), newer than the ad9ede6 the todo cites, but
  `git -C ~/.local/share/nvim/lazy/snacks.nvim log ad9ede6..882c996 -- lua/snacks/input.lua`
  is empty — the todo's re-check trigger has not fired. The default-text
  path still sets the buffer without cursor placement
  (installed `snacks/input.lua:234-236`; the cursor-placing `set()` helper
  at :162-166 remains unused for defaults).
- **vim-pack todo**: its claims about this config's lazy.nvim usage all
  still match the current specs (conform.lua:3-5, autopairs.lua:3,
  ts-autotag.lua:3, crates.lua:7, which-key.lua:3, template-string.lua:4,
  todo.lua:5, highlight-colors.lua:3, gruvbox-material.lua:6 priority,
  blink-cmp.lua:4 and plugins/lsp.lua:51 version pins). Its vim.pack facts
  were verified on dev-2756; the machine now runs dev-3603 — dated but
  labeled as such in the todo.
- No config todo contradicts anything filed in todos/2026-07-04-review/.

## Grounding

- `git -C /Users/jakob/dotfiles show 40d5c2e --stat` (doc deletion).
- `git -C /Users/jakob/dotfiles show e5575c6 -- .config/nvim/lua/mrjakob/autocmds.lua`
  (comment de-duplication diff).
- Commit 2274eea (wezterm removal).
- Installed snacks.nvim git log and `lua/snacks/input.lua` as cited above.

## Proposed change

Edit the three config todos in `.config/nvim/todos/`:

- Drop or reword the `docs/code-review-2026-06-11.md` pointer (e.g.
  "from the 2026-06-11 full-config code review, since resolved and removed").
- Remove the duplicated-comment bullet from the osc52 todo.
- Replace "iTerm/WezTerm+tmux" with the actual current environment
  (ghostty+tmux) in the osc52 todo's suggested resolution.

No change to the todos' substantive recommendations is needed.
