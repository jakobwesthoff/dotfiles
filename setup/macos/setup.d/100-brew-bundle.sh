# shellcheck shell=bash
# description: Install the Brewfile: packages, casks, fonts and Mac App Store apps

# On a fresh Mac, Homebrew is not on the PATH setup.sh started with.
eval "$(/opt/homebrew/bin/brew shellenv)"

# The Mac App Store apps go through mas, which needs an App Store
# sign-in. mas cannot sign in on current macOS (`mas signin` is
# unsupported since 10.13), so the sign-in happens in the App Store app.
open -a "App Store"
ask "Sign in to the App Store in the window that opened, then press ENTER"
read -r

info "Running brew bundle install (this may take a while)..."
brew bundle install --file=Brewfile
ok "Brewfile packages and Mac App Store apps installed"
