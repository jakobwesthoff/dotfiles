# Resolve the fidget winblend workaround block (its own TODO is now actionable)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Situation

`lua/mrjakob/plugins/lsp.lua:11-43` carries a long comment documenting a
workaround for Neovim issue #18576 (winblend over transparent
backgrounds rendering black), stating it was "Fixed upstream in PR
#34302 (merged June 2025, milestone 0.12). Not backported to 0.11.x.
Until we upgrade to 0.12, we use normal_hl/winblend overrides" — with
two embedded TODOs:

- "Remove this workaround after upgrading to Neovim 0.12+ and revert to
  fidget defaults (winblend=100, normal_hl='Comment')."
- "Upstream the fidget winborder reposition fix."

State found during review:

- The running Neovim is **0.13.0-dev** — past the 0.12 milestone the
  comment names as the removal condition.
- The workaround opts themselves are **already commented out**
  (lsp.lua:37-41: `normal_hl`/`winblend` lines disabled); the active
  config is just `override_vim_notify = true`. So the override half of
  the workaround is already reverted in practice; the comment block no
  longer matches the code below it.
- The separate winborder-leak issue mentions a fix on
  `jakobwesthoff/fidget.nvim` branch `fix/preserve-border-on-reposition`
  "not yet upstreamed". The **installed** fidget is plain
  `j-hui/fidget.nvim` (git remote checked: j-hui URL, v1.6.1-41,
  commit 2026-01-13) — the fork branch is not in use.

## Actions

1. **Verify the blend fix on the running build:** with the transparent
   gruvbox-material background, set fidget back to its defaults
   (delete the commented normal_hl/winblend lines, i.e. just don't
   configure `notification.window`) and trigger notifications — the
   float must not render black. The comment's own claim (fixed for
   0.12) predicts success; this is the local confirmation.
2. **Check the winborder reposition issue against current fidget:**
   the installed fidget is 10+ months newer than the workaround note;
   reproduce the leak (a `vim.o.winborder = "rounded"` border appearing
   on fidget's window after it repositions). If it no longer
   reproduces, the second TODO dies too. If it still reproduces,
   upstream the fix from the `fix/preserve-border-on-reposition` branch
   per the existing TODO.
3. **Shrink the comment block** to whatever remains true (likely:
   nothing but `override_vim_notify = true` and one line saying why).

## Basis

Config read (lsp.lua:11-43); `git -C ~/.local/share/nvim/lazy/fidget.nvim
remote -v` and `git describe` (2026-06-11); running version from
`nvim --version`. The PR/issue numbers and fix claims are quoted from
the existing comment itself, not independently re-verified — step 1
is the verification.
