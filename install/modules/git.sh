#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Setting up git"

GITCONFIG_MAIN="${HOME}/.gitconfig"
DOTFILES_GIT="${DOTFILES}/conf/git"

## Identity is pulled from macOS-only sources. Elsewhere, keep whatever is
## already configured rather than blanking it out.
if is_macos; then
	REAL_NAME=$(id -F)
	ICLOUD_EMAIL=$(defaults read MobileMeAccounts Accounts 2>/dev/null \
		| grep AccountID | cut -d \" -f2)

	[[ -n ${REAL_NAME} ]] && git config --global user.name "${REAL_NAME}"
	[[ -n ${ICLOUD_EMAIL} ]] && git config --global user.email "${ICLOUD_EMAIL}"
else
	[[ -n $(git config --global user.name) ]] \
		|| warn "git user.name is unset and cannot be detected on this platform"
	[[ -n $(git config --global user.email) ]] \
		|| warn "git user.email is unset and cannot be detected on this platform"
fi

git config --global core.excludesfile "${DOTFILES_GIT}/gitignore"

## Append the include block once. Without this check a re-run either duplicates
## the block or, as the old installer did, discards the whole ~/.gitconfig into
## a backup first, taking any manual edits with it.
INCLUDE_MARKER='# Include generic settings from dotfiles repository'

if grep -qF -- "${INCLUDE_MARKER}" "${GITCONFIG_MAIN}" 2>/dev/null; then
	ok "${GITCONFIG_MAIN} already includes the dotfiles config"
else
	info "Adding dotfiles includes to ${GITCONFIG_MAIN}"

	## <<- strips leading tabs, so the block is indented here but not on disk.
	cat <<-EOF >> "${GITCONFIG_MAIN}"
	${INCLUDE_MARKER} dynamically
	[include]
	  path = ${DOTFILES_GIT}/generic
	# Local personal overrides
	[include]
	  path = ~/.config/git/personal.conf

	## Ensure the directory pattern ends with /** or / so Git knows to match
	## subdirectories inside it:
	##   "gitdir:~/Projects/Work/" matches everything under "~/Projects/Work/".
	##   "gitdir:~/Projects/Work/**" also works identically in newer Git versions.
	##
	## On macOS (which uses a case-insensitive filesystem by default),
	## "gitdir:" can sometimes be picky.
	## If you hit issues, use "gitdir/i:" for case-insensitive path matching:

	## Conditional include for work projects
	# [includeIf "gitdir:~/Projects/Work/**"]
	#   path = ~/.config/git/work.conf

	## Include machine-specific config (e.g., custom diff tools, GPG keys)
	## This should be last so that it can override any other settings.
	[include]
	  path = ~/.gitconfig.local
	EOF
fi
