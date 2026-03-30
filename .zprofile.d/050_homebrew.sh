# Configure homebrew cask to install to main application directory
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Set HOMEBREW github token
[ -f "${HOME}/.HOMEBREW_GITHUB_API_TOKEN" ] && source "${HOME}/.HOMEBREW_GITHUB_API_TOKEN"
export HOMEBREW_GITHUB_API_TOKEN
