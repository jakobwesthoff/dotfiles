if ! zgen saved; then
    zgen load romkatv/powerlevel10k powerlevel10k
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
