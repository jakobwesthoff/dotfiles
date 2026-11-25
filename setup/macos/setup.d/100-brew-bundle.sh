# shellcheck shell=bash
# description: Install the Brewfile: packages, casks, fonts and Mac App Store apps

# On a fresh Mac, Homebrew is not on the PATH setup.sh started with.
eval "$(/opt/homebrew/bin/brew shellenv)"

# The Mac App Store apps go through mas, which needs an App Store sign-in.
info "Running brew bundle install (this may take a while)..."
brew bundle install --file=Brewfile
ok "Brewfile packages and Mac App Store apps installed"
