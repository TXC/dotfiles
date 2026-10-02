# If this file isn't included from ~/.zshrc
: ${DOTFILES:=${HOME}/.dotfiles}

#export HOMEBREW_NO_AUTO_UPDATE=1

[[ "${PATH#*$HOME/bin:}" == "$PATH" ]] && export PATH="$HOME/bin:$PATH"
[[ "${PATH#*$HOME/go/bin:}" == "$PATH" ]] && export PATH="$HOME/go/bin:$PATH"
[[ "${PATH#*$HOME/.local/bin:}" == "$PATH" ]] && export PATH="$HOME/.local/bin:$PATH"

###
# Manage PATH for Homebrew on macOS
###

# Remove /opt/homebrew/bin if it exists in the array
path=(${path:#/opt/homebrew/bin})
# Find the index of /usr/bin
idx=${path[(I)/usr/bin]}
if (( idx )); then
  # Insert /opt/homebrew/bin right before /usr/bin
  path=(${path[1,idx-1]} /opt/homebrew/bin ${path[idx,-1]})
else
  # Fallback: prepend if /usr/bin is not in PATH
  path=(/opt/homebrew/bin $path)
fi

###
#
###

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

# Go configuration
export GOPRIVATE=github.com/stakater-ab/*

# ArgoCD configuration
#export ARGOCD_SERVER_NAME="openshift-gitops-server"
#export ARGOCD_REPO_SERVER_NAME="openshift-gitops-repo-server"
#export ARGOCD_REDIS_HAPROXY_NAME="openshift-gitops-redis-ha-haproxy"
#export ARGOCD_APPLICATION_CONTROLLER_NAME="openshift-gitops-application-controller"
##export ARGOCD_APPLICATION_CONTROLLER_NAME="openshift-gitops-applicationset-controller"

# Python configuration
[ -f "${HOME}/.pythonrc" ] && export PYTHONSTARTUP="${HOME}/.pythonrc"

