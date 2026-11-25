# shellcheck shell=bash
# description: Defaults: Finder

# Helper: set a PlistBuddy value, falling back to Add if the key doesn't exist
plist_set() {
	local key="$1" type="$2" value="$3" file="$4"
	/usr/libexec/PlistBuddy -c "Set ${key} ${value}" "${file}" 2>/dev/null ||
		/usr/libexec/PlistBuddy -c "Add ${key} ${type} ${value}" "${file}"
}

defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder ShowPathbar -bool true
ok "Show hidden files and path bar, hide status bar"

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
	MetaData -bool true \
	OpenWith -bool true \
	Privileges -bool true
ok "Expanded Get Info panes: General, More Info, Open With, Permissions"
