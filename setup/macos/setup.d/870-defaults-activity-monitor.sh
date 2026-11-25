# shellcheck shell=bash
# description: Defaults: Activity Monitor

defaults write com.apple.ActivityMonitor IconType -int 5
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
ok "Sort by CPU, CPU icon in Dock"
