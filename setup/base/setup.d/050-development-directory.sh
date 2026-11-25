# shellcheck shell=bash
# description: Create ~/Development/github/jakobwesthoff

# gitclone() in .zshrc.d/050_functions.sh clones into
# ~/Development/<github|gitlab>/<owner>/<repo>.
if [ -d "$HOME/Development/github/jakobwesthoff" ]; then
	skip "Development directory exists"
else
	mkdir -p "$HOME/Development/github/jakobwesthoff"
	ok "Development directory created"
fi
