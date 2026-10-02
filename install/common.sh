#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
#
# Shared helpers for the install modules.
#
# This file is meant to be sourced, never executed:
#
#   source "${0:A:h}/../common.sh"

## Guard against being sourced more than once
(( ${+_DOTFILES_COMMON} )) && return 0
typeset -g _DOTFILES_COMMON=1

## Hardcode the dotfiles directory to avoid issues with symlinks.
## Respect an existing value so the modules can be tested against a checkout
## somewhere other than ~/.dotfiles.
: ${DOTFILES:=${HOME}/.dotfiles}
export DOTFILES

setopt EXTENDED_GLOB

#--------------------------------------
#  Output
#--------------------------------------

if [[ -t 1 ]]; then

  typeset -g FG_BLACK=$(tput setaf 0)
  typeset -g FG_RED=$(tput setaf 1)
  typeset -g FG_GREEN=$(tput setaf 2)
  typeset -g FG_YELLOW=$(tput setaf 3)
  typeset -g FG_BLUE=$(tput setaf 4)
  typeset -g FG_MAGENTA=$(tput setaf 5)
  typeset -g FG_CYAN=$(tput setaf 6)
  typeset -g FG_LIGHTGRAY=$(tput setaf 7)
  typeset -g FG_GRAY=$(tput setaf 8)
  typeset -g FG_LIGHTRED=$(tput setaf 9)
  typeset -g FG_LIGHTGREEN=$(tput setaf 10)
  typeset -g FG_LIGHTYELLOW=$(tput setaf 11)
  typeset -g FG_LIGHTBLUE=$(tput setaf 12)
  typeset -g FG_LIGHTMAGENTA=$(tput setaf 13)
  typeset -g FG_LIGHTCYAN=$(tput setaf 14)
  typeset -g FG_WHITE=$(tput setaf 15)

  typeset -g BG_BLACK=$(tput setab 0)
  typeset -g BG_RED=$(tput setab 1)
  typeset -g BG_GREEN=$(tput setab 2)
  typeset -g BG_YELLOW=$(tput setab 3)
  typeset -g BG_BLUE=$(tput setab 4)
  typeset -g BG_MAGENTA=$(tput setab 5)
  typeset -g BG_CYAN=$(tput setab 6)
  typeset -g BG_LIGHTGRAY=$(tput setab 7)
  typeset -g BG_GRAY=$(tput setab 8)
  typeset -g BG_LIGHTRED=$(tput setab 9)
  typeset -g BG_LIGHTGREEN=$(tput setab 10)
  typeset -g BG_LIGHTYELLOW=$(tput setab 11)
  typeset -g BG_LIGHTBLUE=$(tput setab 12)
  typeset -g BG_LIGHTMAGENTA=$(tput setab 13)
  typeset -g BG_LIGHTCYAN=$(tput setab 14)
  typeset -g BG_WHITE=$(tput setab 15)

  typeset -g RESET=$(tput sgr0)
  typeset -g BOLD=$(tput bold)
  typeset -g DIM=$(tput dim)
  typeset -g ITALIC=$(tput sitm)
  typeset -g UNDERLINE=$(tput smul)
else
  typeset -g FG_BLACK='' FG_RED='' FG_GREEN='' FG_YELLOW='' \
    FG_BLUE='' FG_MAGENTA='' FG_CYAN='' FG_LIGHTGRAY='' \
    FG_GRAY='' FG_LIGHTRED='' FG_LIGHTGREEN='' \
    FG_LIGHTYELLOW='' FG_LIGHTBLUE='' FG_LIGHTMAGENTA='' \
    FG_LIGHTCYAN='' FG_WHITE='' \
    BG_BLACK='' BG_RED='' BG_GREEN='' BG_YELLOW='' \
    BG_BLUE='' BG_MAGENTA='' BG_CYAN='' BG_LIGHTGRAY='' \
    BG_GRAY='' BG_LIGHTRED='' BG_LIGHTGREEN='' \
    BG_LIGHTYELLOW='' BG_LIGHTBLUE='' BG_LIGHTMAGENTA='' \
    BG_LIGHTCYAN='' BG_WHITE='' \
    RESET='' BOLD='' DIM='' ITALIC='' UNDERLINE=''
fi

function info() {
  print -r -- "${FG_BLUE}  ..${RESET} $*"
}
function ok() {
  print -r -- "${FG_GREEN}  ok${RESET} $*"
}
function warn() {
  print -r -- "${FG_YELLOW}warn${RESET} $*" >&2
}
function error() {
  print -r -- "${FG_RED} err${RESET} $*" >&2
}

## Section heading, printed once per module
function heading() {
  print -r -- "${FG_BLUE}==>${RESET} $*"
}

#--------------------------------------
#  Platform
#--------------------------------------

function is_macos() { [[ ${OSTYPE} == darwin* ]] }
function is_linux() { [[ ${OSTYPE} == linux* ]] }

## Is the given command available?
function has() { (( ${+commands[$1]} )) }

#--------------------------------------
#  Filesystem
#--------------------------------------

## Move an existing path aside, timestamped. Broken symlinks count as existing.
function backup() {
  local target=$1
  [[ -e ${target} || -L ${target} ]] || return 0

  local stamp=$(date +%s)
  info "Backing up ${target} to ${target}.${stamp}"
  mv -- "${target}" "${target}.${stamp}"
}

## Create a directory if needed, optionally setting its mode.
function ensure_dir() {
  local dir=$1 mode=$2
  [[ -d ${dir} ]] || mkdir -p -- "${dir}" || return 1
  [[ -n ${mode} ]] && chmod "${mode}" "${dir}"
  return 0
}

## Symlink ${1} to ${2}, backing up whatever is in the way.
##
## Re-running this is a no-op when the link already points where it should,
## which is what keeps repeat installs from littering ~ with backup copies.
function link() {
  local source=$1 dest=$2

  if [[ ! -e ${source} ]]; then
    error "Cannot link ${dest}: ${source} does not exist"
    return 1
  fi

  ## Already correct? Leave it alone.
  if [[ -L ${dest} && ${dest:A} == ${source:A} ]]; then
    ok "${dest} (unchanged)"
    return 0
  fi

  ensure_dir "${dest:h}" || return 1

  ## A symlink pointing somewhere else is just wrong, not worth archiving.
  if [[ -L ${dest} ]]; then
    rm -- "${dest}"
  else
    backup "${dest}"
  fi

  ln -sn -- "${source}" "${dest}" || return 1
  ok "${dest} -> ${source}"
}
