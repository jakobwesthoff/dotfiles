# shellcheck shell=bash
# description: Defaults: Time Machine

defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
ok "Don't prompt for new backup volumes"
