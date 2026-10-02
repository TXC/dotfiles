#--------------------------------------
#  Bootstrappin' zsh config stuff
#--------------------------------------
[ -t 1 ] && echo "Loading config..."

# If this file isn't included from ~/.zshrc
: ${DOTFILES:=${HOME}/.dotfiles}

# Load all zsh-files from $DOTFILES/zsh
local configs=( ~/.dotfiles/zsh/*(.N) )
configs=( ${configs:#*/(bootstrap|prezto).zsh} )

for config in $configs; do
  source $config
done

if [[ -f "${HOME}/.config/zshrc.local" ]]; then
  source "${HOME}/.config/zshrc.local"
fi

# That's it. We're all done.
[ -t 1 ] && echo "All Done! Have fun!"