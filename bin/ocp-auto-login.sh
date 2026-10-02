#!/bin/bash

# Little script which can be run in background, pairs with login_all_ocp.sh and
# together they mean you can get auto-login with a popup.
# For example, using: in tmux makes it very automatic
# set-option -g status-left "#(ocp-auto-login.sh)"
# or like:
# set-option -g status-left "#[fg=green,bg=default]#(~/bin/tmux_git_status.sh #{pane_current_path}) | #(ocp-auto-login.sh)"

MAX_TRIES=3
for i in $(seq 1 $MAX_TRIES); do
  if oc whoami &>/dev/null; then
    echo "#[fg=green]$(oc config current-context | cut -d/ -f2 | cut -d- -f2)"
    exit 0
  fi
  if ! nc -z $(oc config view -o jsonpath='{.clusters[0].cluster.server}'| sed s,https://,, | sed s,:," ",); then
    echo "#[fg=red]No Network connection"
    exit 1
  fi
  sleep 1
done

$HOME/bin/ocp_login_all.sh
echo "#[fg=red]popup?"