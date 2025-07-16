# Just some shortcuts
alias tailf="tail -f"
if which gsed &>/dev/null; then
  alias sed="gsed"
fi
alias tree="tree -AC"
alias mtail=multitail

# Add a more silent ant command
alias sant="ant -logger org.apache.tools.ant.NoBannerLogger"

# Open a webserver serving the current directory and execute a browser to point
# at it
alias server='open http://localhost:8000 && python -m SimpleHTTPServer'

# XDebug traces with php
alias ptrace="php -d 'xdebug.auto_trace=1' -d 'xdebug.collect_params=1' -d 'xdebug.trace_output_dir=./'"
alias pprofile="php -d 'xdebug.profiler_enable=1' -d 'xdebug.profiler_output_dir=./'"

# Code highlight cat
alias syn="pygmentize"
alias syncolor="pygmentize -f console256"

# vim instead of vi
alias vi="nvim"
alias vim="nvim"

alias wssh="wait_for_ssh"

# Learn to use rg instead of ack or ag
alias ack="colorize '<red>Try <yellow>rg</yellow> (ripgrep) instead of ack. It is faster and more modern!</red>'; echo; ack"
alias ag="colorize '<red>Try <yellow>rg</yellow> (ripgrep) instead of ag. It is faster and more modern!</red>'; echo; ag"

# VS Code
alias vscode="code"
alias vsc="code"

# Git shortcuts
alias gp="git pull"
alias gcm="git checkout master"
alias gco="git checkout"
alias gpo="git push -u origin \$(git branch --show-current)"
alias gci="git commit"
alias gst="git status"
alias gap="git add -p"
alias gdi="git diff"
alias gs="git stash"
alias gsp="git stash pop"

# Theme changing shortcuts
alias light="theme.rs light"
alias dark="theme.rs dark"
alias toggle="theme.rs toggle"

# Remove first line
alias no-title="tail -n+2"

# Watson timetracking related
alias wa=watson
alias wad=watson-dashboard
