#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Installing vim stuff"

## Mirror the directory layout of conf/vim (backups, swaps, undo) into ~/.vim
for dir in ${DOTFILES}/conf/vim/*(/N); do
  ensure_dir "${HOME}/.vim/${dir:t}"
done

link "${DOTFILES}/conf/vim/vimrc" "${HOME}/.vimrc"
