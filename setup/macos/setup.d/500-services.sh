# shellcheck shell=bash
# description: Start asimeow, skhd and yabai

eval "$(/opt/homebrew/bin/brew shellenv)"

# asimeow: Time Machine exclusions for build artifacts
if brew services list | grep -q "asimeow.*scheduled"; then
	skip "asimeow already running"
else
	info "Starting asimeow (Time Machine exclusions)..."
	brew services start mdnmdn/asimeow/asimeow
	ok "asimeow started"
fi

info "Configuring skhd..."
skhd --install-service 2>/dev/null || true
skhd --start-service 2>/dev/null || true
ok "skhd"

info "Configuring yabai..."
yabai --install-service 2>/dev/null || true
yabai --start-service 2>/dev/null || true
ok "yabai"
