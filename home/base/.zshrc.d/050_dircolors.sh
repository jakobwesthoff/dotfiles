# enable color support of ls and also add handy aliases
if (( $+commands[dircolors] )); then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Update completion colors
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
