#!/bin/bash
set -ueo pipefail

# Disclaimer
echo "---------------------------------------------------------------------"
echo "This is a QUITE SPECIFIC and OPINIONATED base setup for macOS by "
echo "Jakob Westhoff. It most likely will NOT WORK for you right out of "
ecoh "the box!"
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
ssh-add -K

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

cd "$HOME"

# Create folders
mkdir -p "$HOME/Development/github/jakobwesthoff"

# Install base prerequisites
brew install gnu-sed
brew install coreutils
brew install git
brew install python
brew install zsh
brew install wget
brew install fasd
brew install stow
brew install fastfetch
brew install alacritty
brew install neovim

brew tap homebrew/cask-fonts
brew info font-fira-code-nerd-font
brew info font-fira-code
brew install font-jetbrains-mono

brew tap FelixKratz/formulae
brew install borders
brew tap koekeishiya/formulae
brew install skhd
brew install yabai

# Checkout and install dotfiles
git clone git@github.com:jakobwesthoff/dotfiles.git dotfiles
pushd "$HOME/dotfiles"
./checkout_dependencies.sh
stow .
popd

# Set sensible keyboard repeat values
# normal minimum is 15 (225 ms)
defaults write -g InitialKeyRepeat -int 12
# normal minimum is 2 (30 ms)
defaults write -g KeyRepeat -int 2
# Needs relogin to take effect.

brew install 1password
brew install bartender
brew install alfred
brew install appcleaner
brew install arc

brew install mas

while ! mas account &>/dev/null; do
    echo "Please login to the appstore and press ENTER when ready"
    read -r
done

# yoink
mas install 457622435

brew install karabiner-elements
echo "Configure karabiner-elements to your likings"
echo
echo "You will most likely want to map Ctrl -> Capslock"
echo "and install the following 'complex modifications':"
echo "- PC-Style Home/End"
echo
echo "PRESS ENTER TO WHEN DONE"
read -r

brew install visual-studio-code
echo "Run Visual Studio and enable Settings Sync"
echo
echo "PRESS ENTER WHEN DONE"
read -r

brew install rocket
echo "Launch and configure Rocket"
echo
echo "PRESS ENTER WHEN DONE"
read -r

brew install mtr
brew install ripgrep

# brew install hammerspoon
# TODO Checkout and install hammerspoon configuration

# CopyQueue
mas install 711074010

# WebCam Settings
mas install 533696630

# Affinity Photo/Designer
mas install 824183456
mas install 824171161

# Bear
mas install 1091189122

# Gif Brewery 3
# mas install 1081413713

# Shush
mas install 496437906

# droplr
mas install 498672703

# Airmail 5
mas install 918858936

# Amphetamine
mas install 937984704

# Fantastical
mas install 975937182

# Kaleidoscope
mas install 587512244
brew install ksdiff

# The Unarchiver
mas install 425424353

# Daisy Disk
mas install 411643860


# Unlock with Apple Watch
echo "Enable Unlock with Apple Watch:"
echo "Settings -> Security & Privacy -> General"
echo "-> Use your Apple Watch to unlock apps and your Mac"
echo
echo "PRESS ENTER TO WHEN DONE"
read -r

echo "Change require password after sleep or unlock to 5 seconds:"
echo "Settings -> Security & Privacy -> General"
echo "-> Require Password COMBOBOX after..."
echo
echo "PRESS ENTER TO WHEN DONE"
read -r

# echo "Disable Sound on Startup:"
# echo "Settings -> Sound ->  Play sound on startup"
# echo
# echo "PRESS ENTER TO WHEN DONE"
# read -r

echo "Starting yabai"
skhd --install-service
skhd --start-service
yabai --install-service
yabai --start-service


## Further setup borrowed from ~/.macos — https://mths.be/macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

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

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

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

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

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

# Disable Spotlight indexing for any volume that gets mounted and has not yet
# been indexed before.
# Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups
hash tmutil &> /dev/null && sudo tmutil disablelocal

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Dock" \
	"Finder" \
	"Google Chrome Canary" \
	"Google Chrome" \
	"Mail" \
	"Messages" \
	"Opera" \
	"Photos" \
	"Safari" \
	"SizeUp" \
	"Spectacle" \
	"SystemUIServer" \
	"Terminal" \
	"Transmission" \
	"Tweetbot" \
	"Twitter" \
	"iCal"; do
	killall "${app}" &> /dev/null
done


echo "Everything is setup. Please restart to ensure every config is applied."
