# Include $HOME/{bin,sbin} in the execpath
export PATH="$PATH:$HOME/bin:$HOME/sbin"

# Include bin path of ruby gems to PATH
export PATH="$PATH:/var/lib/gems/1.8/bin"

# If mactex is installed include its bin path
if [ -d "/usr/texbin" ] && [ "${PATH%%/usr/texbin}" == "${PATH}" ]; then
    export PATH="${PATH}:/usr/texbin"
fi

# Include npm executables in the searchpath
export PATH="/usr/local/share/npm/bin:${PATH}"

# Make sure /usr/local/bin has priority over everything else
export PATH="/usr/local/sbin:/usr/local/bin:${PATH}"

# Make gnu coreutils have priority over the bsd ones
PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"
