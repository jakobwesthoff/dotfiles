# Set the editor to vim
if [ -z "$EDITOR" ]; then
    command -v nvim >/dev/null && export EDITOR=nvim
fi
