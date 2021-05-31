##
# It always needs to be made sure path.sh is loaded first, as other scripts
# depend on it.
##

# Include $HOME/{bin,sbin} in the execpath
export PATH="$PATH:$HOME/bin:$HOME/sbin:$HOME/.local/bin"

# Include bin path of ruby gems to PATH
export PATH="$PATH:/var/lib/gems/1.8/bin"

# If mactex is installed include its bin path
if [ -d "/usr/texbin" ] && [ "${PATH%%/usr/texbin}" == "${PATH}" ]; then
    export PATH="${PATH}:/usr/texbin"
fi

# Include npm executables in the searchpath
export PATH="/usr/local/share/npm/bin:${PATH}"

##
# Homebrew configuration
##
eval "$(/opt/homebrew/bin/brew shellenv)"

# Make gnu coreutils have priority over the bsd ones
PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
MANPATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"

# Prefer gnu find, locate and xargs over bsd tools
PATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin:$PATH"

