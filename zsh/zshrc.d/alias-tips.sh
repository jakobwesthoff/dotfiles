if ! zgen saved; then
    zgen load djui/alias-tips 
fi

export ZSH_PLUGINS_ALIAS_TIPS_TEXT="$(colorize -n '<yellow>You know you have an alias for that, right?</yellow>') "

