# Configure homebrew cask to install to main application directory
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Skip upgrading casks that already self-update
export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1

# Set HOMEBREW github token
[ -f "${HOME}/.HOMEBREW_GITHUB_API_TOKEN" ] && source "${HOME}/.HOMEBREW_GITHUB_API_TOKEN"
export HOMEBREW_GITHUB_API_TOKEN
