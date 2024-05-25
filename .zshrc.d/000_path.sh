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
if [ -e "/usr/local/bin/brew" ]; then
    export HOMEBREW_SHELLENV_PREFIX=""
    eval "$(/usr/local/bin/brew shellenv)"
fi
# Maybe eval both versions (Apple Silicon and intel, but always eval Apple
# Silicon last, if both is installed))
if [ -e "/opt/homebrew/bin/brew" ]; then
    export HOMEBREW_SHELLENV_PREFIX=""
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Make gnu coreutils have priority over the bsd ones
if [ -d $HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin ]; then
    export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"
fi

# Prefer gnu find, locate and xargs over bsd tools
if [ -d $HOMEBREW_PREFIX/opt/findutils/libexec/gnubin ]; then
  export PATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin:$PATH"
fi

# Use snap bin folder if available
if [ -d "/snap/bin" ]; then
  export PATH="/snap/bin:$PATH"
fi

