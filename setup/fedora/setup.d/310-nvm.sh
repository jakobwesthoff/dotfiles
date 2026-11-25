# shellcheck shell=bash
# description: Install or update nvm in ~/.nvm

# nvm's documented manual install: a git checkout in ~/.nvm on the latest
# release tag. Its install script would edit ~/.zshrc, which is a stow
# link into the dotfiles. .zshrc.d/050_nvm.sh loads it from ~/.nvm.
if [ -d "$HOME/.nvm/.git" ]; then
	info "Updating nvm..."
	git -C "$HOME/.nvm" fetch --tags --quiet
else
	info "Cloning nvm..."
	git clone --quiet https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
fi
nvm_tag=$(git -C "$HOME/.nvm" describe --abbrev=0 --tags --match "v[0-9]*" \
	"$(git -C "$HOME/.nvm" rev-list --tags --max-count=1)")
git -C "$HOME/.nvm" -c advice.detachedHead=false checkout --quiet "${nvm_tag}"
ok "nvm ${nvm_tag} in ~/.nvm"
