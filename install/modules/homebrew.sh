#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Setting up Homebrew"

if ! has brew; then
  info "brew not found, skipping"
  exit 0
fi

brew update
brew tap homebrew/bundle
brew bundle --file="${DOTFILES}/install/Brewfile"
brew install romkatv/powerlevel10k/powerlevel10k
