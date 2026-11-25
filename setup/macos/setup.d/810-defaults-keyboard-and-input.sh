# shellcheck shell=bash
# description: Defaults: key repeat, save and print panels, text input

# normal minimum is 15 (225 ms)
defaults write -g InitialKeyRepeat -int 12
# normal minimum is 2 (30 ms)
defaults write -g KeyRepeat -int 2
ok "Key repeat: InitialKeyRepeat=12, KeyRepeat=2 (relogin to apply)"

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
ok "Press-and-hold disabled (key repeat preferred)"

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
