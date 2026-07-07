if [ -e "${HOME}/.local/bin/ekkocli" ]; then
    EKKOCLI_COMPLETION_CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/ekkocli/completions"
    mkdir -p "$EKKOCLI_COMPLETION_CACHEDIR" >/dev/null 2>&1

    # Generate and source if not existant or source and regenerate in the
    # background
    if [[ ! -f "$EKKOCLI_COMPLETION_CACHEDIR/_ekkocli" ]]; then
        ~/.local/bin/ekkocli --zsh-completion >| "$EKKOCLI_COMPLETION_CACHEDIR/_ekkocli"
        source "$EKKOCLI_COMPLETION_CACHEDIR/_ekkocli"
    else
        source "$EKKOCLI_COMPLETION_CACHEDIR/_ekkocli"
        ~/.local/bin/ekkocli --zsh-completion >| "$EKKOCLI_COMPLETION_CACHEDIR/_ekkocli" &|
    fi
fi

