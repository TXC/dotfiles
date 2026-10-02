#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
#
# Entry point for installing these dotfiles.
#
#   install.sh              install everything
#   install.sh git ssh      install only those modules
#
# Individual modules can also be run on their own:
#
#   zsh install/modules/git.sh

## Hardcode the dotfiles directory to avoid issues with symlinks.
## Respect an existing value so this can be tested against another checkout.
: ${DOTFILES:=${HOME}/.dotfiles}
export DOTFILES

#--------------------------------------
#  Phase 1: bootstrap
#--------------------------------------
#
# When this script is piped straight from the network:
#
#   sh -c "$(curl -fsSL .../install/install.sh)"
#
# there is no repository yet and no common.sh to source, and the interpreter is
# sh rather than zsh. Everything up to the exec below therefore stays POSIX and
# self-contained; the real work happens after re-running from the checkout.

_here=$(dirname "$0")

if [ ! -r "${_here}/common.sh" ]; then
  # Check for Homebrew and install if we don't have it
  if [ -z "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Move any existing dotfiles directory aside before cloning over it
  if [ -e "${DOTFILES}" ]; then
    _stamp=$(date +%s)
    echo "Backing up ${DOTFILES} to ${DOTFILES}.${_stamp}"
    mv "${DOTFILES}" "${DOTFILES}.${_stamp}"
  fi

  echo 'Cloning dotfiles repo'
  git clone https://github.com/TXC/dotfiles.git "${DOTFILES}" || exit 1

  echo 'Done cloning, handing over to the checked out installer'
  exec zsh "${DOTFILES}/install/install.sh" "$@"
fi

#--------------------------------------
#  Phase 2: run the modules
#--------------------------------------

source "${0:A:h}/common.sh"

## Ordered on purpose: homebrew provides powerlevel10k, which zsh expects.
typeset -a MODULES
MODULES=(homebrew macos zsh mackup python ssh vim git tmux)

typeset -a requested
if (( $# )); then
  for name in "$@"; do
    if (( ${MODULES[(Ie)${name}]} )); then
      requested+=("${name}")
    else
      error "Unknown module: ${name}"
      error "Available modules: ${MODULES}"
      exit 1
    fi
  done
else
  requested=(${MODULES})
fi

typeset -a failed
for name in ${requested}; do
  module="${0:A:h}/modules/${name}.sh"

  if [[ ! -r ${module} ]]; then
    error "Missing module file: ${module}"
    failed+=("${name}")
    continue
  fi

  ## Run as a subprocess so one broken module cannot take the rest down
  ## with it, or leak variables into them.
  if ! zsh "${module}"; then
    error "Module failed: ${name}"
    failed+=("${name}")
  fi
done

if (( ${#failed} )); then
  error "Finished with failures: ${failed}"
  exit 1
fi

heading "Everything installed!"
info "Run 'exec zsh' to pick up the new shell configuration."
