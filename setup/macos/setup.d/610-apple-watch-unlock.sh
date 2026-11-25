# shellcheck shell=bash
# description: Turn on unlocking with the Apple Watch (by hand)

# Apple documents only the switch in System Settings for this; there is
# no supported command or defaults key that turns it on.
ask "Enable Unlock with Apple Watch:"
info "Settings -> Touch ID & Password"
info "-> Use your Apple Watch to unlock apps and your Mac"
echo "     Press ENTER when done"
read -r
