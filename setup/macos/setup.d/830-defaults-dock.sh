# shellcheck shell=bash
# description: Defaults: Dock

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
