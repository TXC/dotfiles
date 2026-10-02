#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Installing iTerm2 color schemes"

curl -L -o "${HOME}/Downloads/Solarized Dark Higher Contrast.itermcolors" \
  "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Solarized Dark Higher Contrast.itermcolors"

# link "${DOTFILES}/conf/claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"

