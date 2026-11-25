# shellcheck shell=bash
# description: Restart Dock, Finder and the other apps whose defaults changed

info "Restarting affected applications..."
for app in "Activity Monitor" "cfprefsd" "Dock" "Finder" "SystemUIServer"; do
	pkill "${app}" &>/dev/null || true
done
ok "Restarted Dock, Finder, SystemUIServer, cfprefsd"
info "Log out and in again, or restart, so every setting applies."
