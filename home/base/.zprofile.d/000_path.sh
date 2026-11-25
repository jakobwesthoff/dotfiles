##
# It always needs to be made sure path.sh is loaded first, as other scripts
# depend on it.
##

# Include $HOME/{bin,sbin} in the execpath
export PATH="$PATH:$HOME/bin:$HOME/sbin:$HOME/.local/bin"

# Use snap bin folder if available
if [ -d "/snap/bin" ]; then
    export PATH="/snap/bin:$PATH"
fi
