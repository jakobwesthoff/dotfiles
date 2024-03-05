source ~/.zgen/zgen.zsh

source ~/.colorizer/Library/colorizer.sh
if [ -f "~/.prettytable/prettytable" ]; then
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

