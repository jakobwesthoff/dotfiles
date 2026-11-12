# fzf-tab replaces zsh's completion menu with fzf: TAB lists the matches
# zsh found and lets you narrow them by typing.
#
# It has to wrap the TAB widget before zsh-syntax-highlighting (050) and
# zsh-autosuggestions (980) wrap theirs; zgenom sources plugins in the
# order they were loaded, hence the 040 prefix. It is sourced before
# 000_compinit.sh runs compinit, which fzf-tab handles by defining its own
# copy of the completion widget.
if (( ZGENOM_SAVED != 0 )); then
    zgenom load Aloxaf/fzf-tab
fi

# Without zsh's own menu, the first TAB inserts the part all matches share
# and fzf-tab only opens fzf when there is still a choice to make.
zstyle ':completion:*' menu no

# Colours come from the terminal's 16-colour palette, so they follow the
# Ghostty theme, but colour 8 (bright black) is avoided: the theme maps it
# to a light cream, which fzf's own 16-colour scheme would paint behind
# the current line and as a bar on every row. The current line is a
# yellow bar with dark text and a red marker, the pairing of the tmux
# current-window tab (.tmux/my-theme.conf). The gutter of the other rows
# stays blank.
zstyle ':fzf-tab:*' fzf-flags \
  --color=16,bg+:3,fg+:0:bold,hl+:0:bold:underline,pointer:1:bold,gutter:-1,hl:2,info:4,prompt:3,marker:6,spinner:4 \
  '--gutter= '

# Picking a folder for `cd` with Enter runs the `cd` at once. Elsewhere
# Enter only inserts the pick, so a half-typed command never runs.
zstyle ':fzf-tab:complete:cd:*' accept-line enter
