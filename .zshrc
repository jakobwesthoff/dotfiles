source ~/.zgen/zgen.zsh

source ~/.colorizer/Library/colorizer.sh
source ~/.prettytable/prettytable.sh

# Source .zshrc.d
while read -rd $'\0' file; do
    source "${file}"
done < <(find -L "${HOME}/.zshrc.d" -mindepth 1 -maxdepth 1 -name '*.sh' -type f -print0 | LC_ALL=C sort -z)

if ! zgen saved; then
    zgen save
fi

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'

fastfetch

