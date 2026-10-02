#!/bin/bash

# Small script to change which cluster you are working towards

clean_contexts() {
  for context in $(oc config get-contexts -o name | grep -v default); do
    kubectl config delete-context "$context"
  done
  for context in $(oc config get-contexts -o name | grep kube:admin); do
    kubectl config delete-context "$context"
  done
}

while true; do
  PS3="Choose environment (or select 'Clean Contexts' to delete old contexts): "
  mapfile -t options < <(oc config get-contexts -o name)
  options+=("Clean Contexts")

  select context in "${options[@]}"; do
    if [[ -z "$context" ]]; then
      echo "Invalid selection."
      break
    elif [[ "$context" == "Clean Contexts" ]]; then
      clean_contexts
      clear
      echo "cleaned contexts"
      break  # exit `select`, re-enter outer `while` to refresh options
    else
      oc config use-context "$context"
      if oc status > /dev/null 2>&1; then
        exit 0
      else
        oc login
        exit 1
      fi
    fi
  done
done