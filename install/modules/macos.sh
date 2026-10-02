#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Setting up OSX related shenanigans"

if ! is_macos; then
  info "Not macOS, skipping"
  exit 0
fi

## osx.sh declares #!/usr/bin/env bash, so run it with bash rather than sh
bash "${DOTFILES}/install/osx.sh"
