#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Setting up python"

link "${DOTFILES}/conf/python/rc.py" "${HOME}/.pythonrc"
