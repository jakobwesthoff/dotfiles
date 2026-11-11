#brew analytics off

# =========================================================
# Taps
# =========================================================

tap "mdnmdn/asimeow"
tap "azure/kubelogin"
tap "felixkratz/formulae"
tap "koekeishiya/formulae"
tap "mutagen-io/mutagen"
tap "bjoernschotte/tap"

# =========================================================
# Shell & Terminal
# =========================================================

brew "bash"
brew "zsh"
brew "fzf"
brew "zoxide"
brew "tmux"
brew "sesh"
brew "screen"
brew "yazi"
brew "dialog"
brew "ttyd"
brew "vhs"

# =========================================================
# Core CLI Utilities
# =========================================================

brew "coreutils"
brew "binutils"
brew "gnu-sed"
brew "gnu-tar"
brew "grep"
brew "moreutils"
brew "tree"
brew "watch"
brew "pv"
brew "pstree"
brew "fd"
brew "ripgrep"
brew "bat"
brew "jq"
brew "yq"
brew "kondo"

# =========================================================
# Networking & Transfer
# =========================================================

brew "aria2"
brew "curl"
brew "wget"
brew "rsync"
brew "mtr"
brew "nmap"
brew "sshpass"

# =========================================================
# Version Control
# =========================================================

brew "git"
brew "git-lfs"
brew "git-filter-repo"
brew "gh"
brew "glab"

# =========================================================
# Editors & IDE Support
# =========================================================

brew "neovim"
brew "lua-language-server"
brew "rust-analyzer"
brew "typescript-language-server"
brew "clang-format"
brew "stylua"
brew "luacheck"

# =========================================================
# Languages & Runtimes
# =========================================================

brew "python@3.14"
brew "node"
brew "nvm"
brew "go"
brew "php"
brew "llvm"
brew "uv"

# =========================================================
# Build Tools & Automation
# =========================================================

brew "cmake"
brew "autoconf"
brew "just"
brew "shellcheck"
brew "shfmt"
brew "ansible"
brew "stow"

# =========================================================
# Kubernetes & Cloud
# =========================================================

brew "kubernetes-cli"
brew "kubectx"
brew "kubecolor"
brew "kubeconform"
# helm@3 is keg-only. Without `link: true`, `brew bundle` unlinks it on
# every run and `helm` disappears from PATH.
brew "helm@3", link: true
brew "azure/kubelogin/kubelogin", trusted: true
brew "azure-cli"
brew "skopeo"
brew "sops"

# =========================================================
# Media & Image Processing
# =========================================================

brew "ffmpeg"
brew "flac"
brew "imagemagick"
brew "pngcrush"
brew "oxipng"
brew "webp"
brew "yt-dlp", args: ["HEAD"]

# =========================================================
# Document & Text Processing
# =========================================================

brew "aspell"
brew "pandoc"
brew "typst"

# =========================================================
# System Monitoring & Info
# =========================================================

brew "btop"
brew "htop"
brew "hwatch"
brew "fastfetch"
brew "smartmontools"
brew "watson"
brew "tokei"
brew "ccusage"

# =========================================================
# Compression & Archives
# =========================================================

brew "p7zip"
brew "pbzip2"

# =========================================================
# Security & Encryption
# =========================================================

brew "age"
brew "gnutls"

# =========================================================
# File Managers & Misc CLI
# =========================================================

brew "midnight-commander"
brew "mas"

# =========================================================
# Libraries & Low-Level
# =========================================================

brew "glib"
brew "e2fsprogs"

# =========================================================
# Third-Party Tapped Formulae
# =========================================================

# Homebrew only loads formulae from non-official taps once they are
# trusted. `trusted: true` writes that trust during `brew bundle`, and
# `brew bundle cleanup --force` resets the trust store to the entries
# declared here, so every tapped formula needs the flag to keep working.
brew "bjoernschotte/tap/atlcli", trusted: true
brew "felixkratz/formulae/borders", trusted: true
brew "koekeishiya/formulae/skhd", trusted: true
brew "koekeishiya/formulae/yabai", trusted: true
brew "mdnmdn/asimeow/asimeow", trusted: true
brew "mutagen-io/mutagen/mutagen", trusted: true

# =========================================================
# Backup
# =========================================================

brew "restic"

# =========================================================
# Casks — Browsers
# =========================================================

cask "zen"

# =========================================================
# Casks — Communication
# =========================================================

cask "slack"

# =========================================================
# Casks — Productivity
# =========================================================

cask "libreoffice"

# =========================================================
# Casks — Development
# =========================================================

cask "ghostty"
cask "orbstack"

# =========================================================
# Casks — Media & Design
# =========================================================

cask "imageoptim"
cask "upscayl"
cask "vlc"

# =========================================================
# Casks — System Utilities
# =========================================================

cask "1password"
cask "appcleaner"
cask "utm"
cask "viscosity"
cask "zerotier-one"

# =========================================================
# Casks — Hardware
# =========================================================

cask "raspberry-pi-imager"
