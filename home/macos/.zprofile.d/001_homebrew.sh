##
# Homebrew's PATH and the GNU tools it provides. Runs right after
# 000_path.sh, before anything that expects Homebrew's tools.
##

# Prefer homebrew curl over system curl
export PATH="/opt/homebrew/opt/curl/bin:${PATH}"

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
