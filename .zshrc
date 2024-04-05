# Startup with tmux if selected and allow for session selection
if [ -n "${ENABLE_TMUX_STARTUP}" ] && [ -z "${MUX}" ]; then
  unset ENABLE_TMUX_STARTUP
  if ! tmux list-sessions; then
    # No active sessions, start a new one
    tmux new-session
  else
    # Active sessions available allow selection
    sessions="$(tmux list-sessions)"
    selected_session="$(printf "NEW SESSION\n%s" "${sessions}" | /opt/homebrew/bin/fzf)"
    if [ "${selected_session}" = "NEW SESSION" ]; then
      tmux new-session
    else
      session_id="$(echo "$selected_session" | sed -e 's@^\([^:]\):.*$@\1@g')"
      tmux attach-session -t "${session_id}"
    fi
  fi
  exit
fi

source ~/.zgen/zgen.zsh

source ~/.colorizer/Library/colorizer.sh
if [ -e ~/.prettytable/prettytable ]; then
  # New version
  source ~/.prettytable/prettytable
else
  # Old version
  source ~/.prettytable/prettytable.sh
fi


# Enabled interactive comments
# https://apple.stackexchange.com/questions/405246/zsh-comment-character
setopt interactive_comments

# Source .zshrc.d
while read -rd $'\0' file; do
    source "${file}"
done < <(find -L "${HOME}/.zshrc.d" -mindepth 1 -maxdepth 1 -name '*.sh' -type f -print0 | LC_ALL=C sort -z)

if ! zgen saved; then
    zgen save
fi

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'

fastfetch
