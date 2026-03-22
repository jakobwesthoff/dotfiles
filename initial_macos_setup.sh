#!/bin/bash
set -euo pipefail

# =========================================================
# Output helpers
# =========================================================

bold='\033[1m'
dim='\033[2m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
red='\033[31m'
reset='\033[0m'

section() { printf "\n${bold}${blue}==> %s${reset}\n" "$1"; }
info()    { printf "  ${dim}%s${reset}\n" "$1"; }
ok()      { printf "  ${green}ok${reset} %s\n" "$1"; }
skip()    { printf "  ${dim}skip${reset} %s\n" "$1"; }
warn()    { printf "  ${yellow}!!${reset} %s\n" "$1"; }
fail()    { printf "  ${red}FAIL${reset} %s\n" "$1"; }
ask()     { printf "\n  ${yellow}>>>${reset} %s\n" "$1"; }

# Helper: set a PlistBuddy value, falling back to Add if the key doesn't exist
plist_set() {
	local key="$1" type="$2" value="$3" file="$4"
	/usr/libexec/PlistBuddy -c "Set ${key} ${value}" "${file}" 2>/dev/null ||
		/usr/libexec/PlistBuddy -c "Add ${key} ${type} ${value}" "${file}"
}

# =========================================================
# Disclaimer
# =========================================================

if [[ "${1:-}" != "--yes" ]]; then
	printf '\n%b' "${bold}"
	echo "  -------------------------------------------------------------"
	echo "  macOS Setup — Jakob Westhoff"
	echo "  Quite specific and opinionated. Will not work for everyone."
	echo "  -------------------------------------------------------------"
	printf '%b\n' "${reset}"
	ask "Press ENTER to continue"
	read -r
fi

# =========================================================
# Prerequisites
# =========================================================

section "Checking prerequisites"

# macOS updates
info "Checking for macOS updates..."
update_output="$(softwareupdate -l 2>&1)"
if echo "${update_output}" | grep -q "No new software available"; then
	ok "macOS is up to date"
else
	warn "Available updates:"
	echo "${update_output}" | grep '^\* Label:' | sed 's/^\* Label: /    /' | while read -r line; do
		info "${line}"
	done
	ask "Install updates via: Apple Menu -> About This Mac -> Software Update"
	echo "     Press ENTER to continue (or install later)"
	read -r
fi

# SSH keys
if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
	ok "SSH keys found"
	ssh-add --apple-use-keychain 2>/dev/null
else
	warn "No SSH keys found in ~/.ssh (expected id_rsa or id_ed25519)"
	ask "Add your SSH private keys, then press ENTER"
	read -r
	ssh-add --apple-use-keychain
fi

# SSH config keychain integration
if grep -q "UseKeychain yes" ~/.ssh/config 2>/dev/null; then
	ok "SSH config has UseKeychain"
else
	warn "$HOME/.ssh/config is missing UseKeychain/AddKeysToAgent"
	info "Ensure your Host * block includes:"
	info "  UseKeychain yes"
	info "  AddKeysToAgent yes"
	ask "Press ENTER when done"
	read -r
fi

# FileVault
if fdesetup status | grep -q "FileVault is On"; then
	ok "FileVault is enabled"
else
	warn "FileVault is NOT enabled"
	ask "Enable it: Settings -> Privacy & Security -> FileVault -> Turn On"
	echo "     Press ENTER when done"
	read -r
fi

# Xcode Command Line Tools
if xcode-select -p &>/dev/null; then
	ok "Xcode Command Line Tools installed"
else
	info "Installing Xcode Command Line Tools..."
	xcode-select --install
	until xcode-select -p &>/dev/null; do
		sleep 5
	done
	ok "Xcode Command Line Tools installed"
fi

# =========================================================
# Homebrew
# =========================================================

section "Homebrew"

if command -v brew &>/dev/null; then
	ok "Homebrew already installed"
else
	info "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
	ok "Homebrew installed"
fi

info "Installing base prerequisites (git, stow)..."
brew install git stow 2>/dev/null
ok "git and stow ready"

# =========================================================
# Dotfiles
# =========================================================

section "Dotfiles"

cd "$HOME"

if [ ! -d "$HOME/Development/github/jakobwesthoff" ]; then
	info "Creating ~/Development/github/jakobwesthoff..."
	mkdir -p "$HOME/Development/github/jakobwesthoff"
fi

if [ -d "$HOME/dotfiles" ]; then
	ok "Dotfiles already cloned"
else
	info "Cloning dotfiles..."
	git clone git@github.com:jakobwesthoff/dotfiles.git dotfiles
	pushd "$HOME/dotfiles"
	./checkout_dependencies.sh
	stow .
	popd
	ok "Dotfiles cloned and stowed"
fi

cd "$HOME/dotfiles"

info "Running brew bundle install (this may take a while)..."
brew bundle install
ok "Brewfile packages installed"

# =========================================================
# Mac App Store
# =========================================================

section "Mac App Store"

mas_apps=(
	"937984704  Amphetamine"
	"1091189122 Bear"
	"711074010  CopyQueue"
	"1524172135 Creator's Best Friend"
	"425264550  Disk Speed Test"
	"498672703  Droplr"
	"975937182  Fantastical"
	"682658836  GarageBand"
	"409183694  Keynote"
	"409203825  Numbers"
	"409201541  Pages"
	"425424353  The Unarchiver"
	"533696630  Webcam Settings"
	"1295203466 Windows App"
	"497799835  Xcode"
	"457622435  Yoink"
)

mas_failed=0
for entry in "${mas_apps[@]}"; do
	app_id="${entry%% *}"
	app_name="${entry#* }"
	# Trim leading whitespace from name
	app_name="${app_name#"${app_name%%[![:space:]]*}"}"
	if mas list | grep -q "^${app_id} "; then
		skip "${app_name} already installed"
	else
		info "Installing ${app_name}..."
		if mas install "${app_id}" &>/dev/null; then
			ok "${app_name}"
		else
			fail "${app_name} (id: ${app_id})"
			mas_failed=$((mas_failed + 1))
		fi
	fi
done

if [ "${mas_failed}" -gt 0 ]; then
	warn "${mas_failed} app(s) failed to install — retry later with: mas install <id>"
else
	ok "All Mac App Store apps installed"
fi

# =========================================================
# Services
# =========================================================

section "Services"

# asimeow — Time Machine exclusions for build artifacts
if brew services list | grep -q "asimeow.*scheduled"; then
	skip "asimeow already running"
else
	info "Starting asimeow (Time Machine exclusions)..."
	brew services start mdnmdn/asimeow/asimeow
	ok "asimeow started"
fi

# skhd
info "Configuring skhd..."
skhd --install-service 2>/dev/null || true
skhd --start-service 2>/dev/null || true
ok "skhd"

# yabai
info "Configuring yabai..."
yabai --install-service 2>/dev/null || true
yabai --start-service 2>/dev/null || true
ok "yabai"

# =========================================================
# Security
# =========================================================

section "Security"

# Touch ID for sudo
if [ -f /etc/pam.d/sudo_local ]; then
	skip "Touch ID for sudo already configured"
else
	info "Enabling Touch ID for sudo..."
	sudo tee /etc/pam.d/sudo_local > /dev/null <<'PAM'
auth       sufficient     pam_tid.so
PAM
	ok "Touch ID for sudo enabled"
fi

# =========================================================
# Keyboard
# =========================================================

section "Keyboard"

# normal minimum is 15 (225 ms)
defaults write -g InitialKeyRepeat -int 12
# normal minimum is 2 (30 ms)
defaults write -g KeyRepeat -int 2
ok "Key repeat: InitialKeyRepeat=12, KeyRepeat=2 (relogin to apply)"

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
ok "Press-and-hold disabled (key repeat preferred)"

# =========================================================
# Manual settings (optional)
# =========================================================

printf "\n"
read -rp "  Configure manual settings (Apple Watch unlock, lock screen)? [y/N] " manual_setup
if [[ "${manual_setup}" =~ ^[Yy]$ ]]; then
	ask "Enable Unlock with Apple Watch:"
	info "Settings -> Touch ID & Password"
	info "-> Use your Apple Watch to unlock apps and your Mac"
	echo "     Press ENTER when done"
	read -r

	ask "Change lock screen password timeout:"
	info "Settings -> Lock Screen"
	info "-> Require password after screen saver begins or display is turned off"
	echo "     Press ENTER when done"
	read -r
else
	skip "Manual settings"
fi

# =========================================================
# macOS defaults — General
# =========================================================

section "macOS defaults"

osascript -e 'tell application "System Settings" to quit'
info "Closed System Settings to prevent conflicts"

# Prompt for sudo (needed for chflags below)
sudo -v
if ! pgrep -f "sudo -n true.*sleep 60" &>/dev/null; then
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
fi

info "Configuring system-wide defaults..."

# Save/print dialogs
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
ok "Expanded save/print panels by default"

defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
ok "Save to disk (not iCloud) by default"

defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
ok "Auto-quit printer app when done"

defaults write com.apple.CrashReporter DialogType -string "none"
ok "Crash reporter dialog disabled"

# Text input
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
ok "Auto-capitalization, smart dashes/quotes/periods disabled"

# =========================================================
# macOS defaults — Finder
# =========================================================

section "Finder"

defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
ok "Show hidden files, extensions, status bar, path bar"

defaults write com.apple.finder _FXSortFoldersFirst -bool true
ok "Folders on top when sorting by name"

defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
ok "Search current folder by default"

defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
ok "No warning when changing file extensions"

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
ok "No .DS_Store on network/USB volumes"

defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
ok "Disk image verification disabled"

finder_plist=~/Library/Preferences/com.apple.finder.plist
for prefix in DesktopViewSettings FK_StandardViewSettings StandardViewSettings; do
	plist_set ":${prefix}:IconViewSettings:arrangeBy" string grid "$finder_plist"
	plist_set ":${prefix}:IconViewSettings:gridSpacing" integer 100 "$finder_plist"
	plist_set ":${prefix}:IconViewSettings:iconSize" integer 80 "$finder_plist"
done
ok "Icon views: snap-to-grid, spacing=100, size=80"

defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
ok "Default view: list"

defaults write com.apple.finder WarnOnEmptyTrash -bool false
ok "No warning before emptying Trash"

sudo chflags nohidden /Volumes
ok "Show /Volumes folder"

defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true
ok "Expanded Get Info panes: General, Open With, Permissions"

# =========================================================
# macOS defaults — Dock
# =========================================================

section "Dock"

defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock mouse-over-hilite-stack -bool true
ok "Process indicators and hover highlight enabled"

defaults write com.apple.dock mru-spaces -bool false
ok "Don't auto-rearrange Spaces"

defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide -bool true
ok "Auto-hide with no delay or animation"

defaults write com.apple.dock showhidden -bool true
ok "Translucent icons for hidden apps"

defaults write com.apple.dock show-recents -bool false
ok "No recent apps in Dock"

defaults write com.apple.dock persistent-apps -array \
	"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Ghostty.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
	"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Messages.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
	"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Zen.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
ok "Dock apps: Ghostty, Messages, Zen"

# =========================================================
# macOS defaults — Hot Corners
# =========================================================

section "Hot Corners"

# Values: 1=disabled, 10=put display to sleep
defaults write com.apple.dock wvous-tl-corner -int 10
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 0
ok "Top-left: Display Sleep | Others: disabled"

# =========================================================
# macOS defaults — Menu Bar & Control Center
# =========================================================

section "Menu Bar"

defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
ok "Battery percentage visible"

# =========================================================
# macOS defaults — Time Machine
# =========================================================

section "Time Machine"

defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
ok "Don't prompt for new backup volumes"

# =========================================================
# macOS defaults — Activity Monitor
# =========================================================

section "Activity Monitor"

defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor IconType -int 5
defaults write com.apple.ActivityMonitor ShowCategory -int 0
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
ok "Show all processes, sort by CPU, CPU icon in Dock"

# =========================================================
# Apply changes
# =========================================================

section "Applying changes"

info "Restarting affected applications..."
for app in "Activity Monitor" "cfprefsd" "Dock" "Finder" "SystemUIServer"; do
	pkill "${app}" &>/dev/null || true
done
ok "Restarted Dock, Finder, SystemUIServer, cfprefsd"

printf '\n%b  Done!%b Restart to ensure every config is fully applied.\n\n' "${bold}${green}" "${reset}"
