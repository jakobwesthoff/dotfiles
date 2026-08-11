##
# Secrets are kept outside this repository, which is public. The file below is
# sourced verbatim, so it contains plain `export NAME=value` lines.
#
# Loaded early (010) so later modules can consume the tokens they need.
##

if [ -f "${HOME}/.zsh_secrets" ]; then
    source "${HOME}/.zsh_secrets"
fi
