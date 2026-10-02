#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Installing custom script stuff"

ensure_dir "${HOME}/bin"

for f in ${DOTFILES}/bin/*(/N); do
  link "${DOTFILES}/bin/${f:t}" "${HOME}/bin/${f:t}"
done