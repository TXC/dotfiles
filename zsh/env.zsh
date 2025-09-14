export HOMEBREW_NO_AUTO_UPDATE=1
export PATH="/Users/txc/bin:/Users/txc/.local/bin:/usr/local/bin:${PATH}"

setopt clobber

export LC_COLLATE=en_US.UTF-8
export LC_CTYPE=UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NUMERIC=sv_SE.UTF-8
export LC_TIME=sv_SE.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Kubeseal configuration
export SEALED_SECRETS_CONTROLLER_NAME=sealed-secrets
export SEALED_SECRETS_CONTROLLER_NAMESPACE=sealed-secrets
export GOPRIVATE=github.com/stakater-ab/*


git config --global core.excludesfile ~/.dotfiles/conf/gitignore
