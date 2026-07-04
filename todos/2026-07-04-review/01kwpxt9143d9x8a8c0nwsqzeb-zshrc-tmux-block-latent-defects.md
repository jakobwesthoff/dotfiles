# .zshrc tmux startup block: guard tests $MUX (never set) and the no-fzf path self-destructs

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.zshrc:2 and :23-26

Two latent control-flow defects in the tmux startup selector. Neither
fires today (fzf is installed, `MUX` is never set), but both sit on the
paths meant to make the block safe.

## 1. Recursion guard checks `$MUX` instead of `$TMUX`

```zsh
if [ -n "${ENABLE_TMUX_STARTUP}" ] && [ -z "${MUX}" ]; then
```

`MUX` appears nowhere else in the repo (repo-wide grep, 2026-07-04:
only this line) and is not set by ghostty
(`command = env ENABLE_TMUX_STARTUP=true $SHELL -l`), tmux, or any
`.zprofile.d`/`.zshrc.d` fragment. The condition is therefore always
true and the guard is inert. `git show 7ac032e:.zshrc` (the commit
introducing the block) has the same text, so it was never `TMUX`.
The obvious intent is `[ -z "${TMUX}" ]`: skip the picker when the
shell already runs inside tmux. Today that protection is provided only
indirectly by `unset ENABLE_TMUX_STARTUP` (line 26) — and only on the
fzf path, which leads to item 2.

## 2. The no-fzf fallback keeps `ENABLE_TMUX_STARTUP` exported and closes the terminal

```zsh
if [ -z "$fzf_bin" ]; then
  "${tmux_bin}" new-session
else
  unset ENABLE_TMUX_STARTUP
  ...
fi
...
exit
```

The `unset` sits only in the else-branch. With fzf missing, the outer
shell starts tmux with `ENABLE_TMUX_STARTUP=true` still in the
environment. The login shell tmux spawns inside the new session hits
the same block, also finds no fzf, runs `tmux new-session` *inside*
tmux (which refuses nested sessions), falls through to the trailing
`exit`, and terminates the pane — killing the just-created session,
after which the outer shell also reaches `exit`. Net effect on a
machine without fzf: the terminal window opens and immediately closes.
Additionally, if neither fzf **nor** tmux is found, line 24 executes
`"" new-session` and the shell likewise exits on startup.

## Proposed change

- Change the guard to `[ -z "${TMUX}" ]` (this alone also fixes the
  nested-session scenario in item 2).
- Move `unset ENABLE_TMUX_STARTUP` above the `if [ -z "$fzf_bin" ]`
  branch so no tmux server ever inherits it.
- Optionally: fall through to a normal shell instead of `exit` when
  `tmux_bin` is empty.
