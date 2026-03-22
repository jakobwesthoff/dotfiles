#!/bin/bash
set -euo pipefail

# Disclaimer
echo "---------------------------------------------------------------------"
echo "This is a QUITE SPECIFIC and OPINIONATED base setup for macOS by "
echo "Jakob Westhoff. It most likely will NOT WORK for you right out of "
echo "the box!"
echo "---------------------------------------------------------------------"
echo
echo "PRESS ENTER TO CONTINUE"
read -r

# Mac update
echo "Ensure you have installed the latest macOS Version:"
echo "Apple Menu -> About This Mac -> Software Update"
echo
echo "PRESS ENTER TO CONTINUE"
read -r

# SSH Key
echo "Please ensure you have provided ssh private keys within the .ssh directory,"
echo "which allow the access to github and other stuff ;)"
echo
echo "PRESS ENTER TO CONTINUE"
read -r
ssh-add --apple-use-keychain

# Ensure SSH config has keychain integration
if ! grep -q "UseKeychain yes" ~/.ssh/config 2>/dev/null; then
	echo "WARNING: ~/.ssh/config is missing UseKeychain/AddKeysToAgent settings."
	echo "Ensure your Host * block includes:"
	echo "  UseKeychain yes"
	echo "  AddKeysToAgent yes"
	echo
	echo "PRESS ENTER WHEN DONE"
	read -r
fi

# FileVault
if ! fdesetup status | grep -q "FileVault is On"; then
	echo "FileVault is NOT enabled. Please enable it:"
	echo "Settings -> Privacy & Security -> FileVault -> Turn On"
	echo
	echo "PRESS ENTER WHEN DONE"
	read -r
fi

# Xcode Command Line Tools (required by Homebrew)
if ! xcode-select -p &>/dev/null; then
	xcode-select --install
	echo "Waiting for Xcode Command Line Tools installation to complete..."
	until xcode-select -p &>/dev/null; do
		sleep 5
	done
fi

# Install homebrew
if ! command -v brew &>/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

cd "$HOME"

# Create folders
if [ ! -d "$HOME/Development/github/jakobwesthoff" ]; then
	mkdir -p "$HOME/Development/github/jakobwesthoff"
fi

# Install base prerequisites
brew install git stow

# Checkout and install dotfiles
if [ ! -d "$HOME/dotfiles" ]; then
	git clone git@github.com:jakobwesthoff/dotfiles.git dotfiles
	pushd "$HOME/dotfiles"
	./checkout_dependencies.sh
	stow .
	popd
fi

cd "$HOME/dotfiles"

brew bundle install

# Start asimeow as a brew service to automatically exclude build artifacts
# (node_modules, target/, .venv, etc.) from Time Machine backups.
# Config is managed via stow at ~/.config/asimeow/config.yaml.
brew services start mdnmdn/asimeow/asimeow

# Start window management services
skhd --install-service
skhd --start-service
yabai --install-service
yabai --start-service

# Enable Touch ID for sudo (survives macOS updates since Sonoma)
if [ ! -f /etc/pam.d/sudo_local ]; then
	sudo tee /etc/pam.d/sudo_local > /dev/null <<'PAM'
auth       sufficient     pam_tid.so
PAM
fi

# Set sensible keyboard repeat values
# normal minimum is 15 (225 ms)
defaults write -g InitialKeyRepeat -int 12
# normal minimum is 2 (30 ms)
defaults write -g KeyRepeat -int 2
# Needs relogin to take effect.

# Manual settings that cannot be automated — skip on repeat runs
read -rp "Configure manual settings (Apple Watch unlock, lock screen)? [y/N] " manual_setup
if [[ "${manual_setup}" =~ ^[Yy]$ ]]; then
	echo "Enable Unlock with Apple Watch:"
	echo "Settings -> Touch ID & Password"
	echo "-> Use your Apple Watch to unlock apps and your Mac"
	echo
	echo "PRESS ENTER WHEN DONE"
	read -r

	echo "Change require password after sleep or unlock to 5 seconds:"
	echo "Settings -> Lock Screen"
	echo "-> Require password after screen saver begins or display is turned off"
	echo
	echo "PRESS ENTER WHEN DONE"
	read -r
fi

## Further setup borrowed from ~/.macos — https://mths.be/macos

# Close any open System Settings panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Settings" to quit'

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Prompt for sudo password and keep the timestamp alive for the rest of the script
sudo -v
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

# Show the /Volumes folder
sudo chflags nohidden /Volumes

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Remove all default Dock items and set preferred apps
defaults write com.apple.dock persistent-apps -array \
	"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Ghostty.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
	"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Messages.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
	"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Zen.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Hot corners: top-left = Put Display to Sleep, all others disabled
# Values: 1=disabled, 10=put display to sleep
defaults write com.apple.dock wvous-tl-corner -int 10
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 0

# Show battery percentage in menu bar
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
	"cfprefsd" \
	"Dock" \
	"Finder" \
	"SystemUIServer"; do
	pkill "${app}" &>/dev/null || true
done

echo "Everything is setup. Please restart to ensure every config is applied."
