#! /usr/bin/env zsh
# vim: set tw=80 ts=2 sw=2 ft=zsh noet:
source "${0:A:h}/../common.sh"

heading "Applying SSH Config"

ensure_dir "${HOME}/.ssh" 700
ensure_dir "${HOME}/.ssh/conf.d" 700

## Split the key pairs apart so the private keys get 600 and the public ones
## 644. The (.N) qualifier keeps this quiet on a machine with no keys at all.
typeset -a pubkeys privkeys
pubkeys=( ${HOME}/.ssh/id_*.pub(.N) )
privkeys=( ${HOME}/.ssh/id_*(.N) )
privkeys=( ${privkeys:|pubkeys} )

## No -- here: BSD chmod takes the mode as its first operand and would read
## the -- as a filename. The globs only ever yield absolute paths anyway.
(( ${#privkeys} )) && chmod 600 ${privkeys}
(( ${#pubkeys} )) && chmod 644 ${pubkeys}

touch "${HOME}/.ssh/authorized_keys" "${HOME}/.ssh/known_hosts"
chmod 644 "${HOME}/.ssh/authorized_keys" "${HOME}/.ssh/known_hosts"

link "${DOTFILES}/conf/ssh/config" "${HOME}/.ssh/config"
