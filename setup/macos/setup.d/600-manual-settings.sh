# shellcheck shell=bash
# description: Walk through manual settings (Apple Watch unlock, lock screen)

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
