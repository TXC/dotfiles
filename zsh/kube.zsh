# Oneliner if you want to use it manually:
#
# export KUBECONFIG=~/.kube/config:$(paste -sd: <(find ~/.kube/config.d -type f \( -name "*.yaml" -o -name "*.yml" -o -name "config" \)))
#

if [[ -d "${HOME}/.kube" ]]; then
  local base_config="${HOME}/.kube/config"
  local config_dir="${HOME}/.kube/config.d"
  #local paths="${KUBECONFIG:-${base_config}}"
  local paths="${base_config}"

  if [ -d "${config_dir}" ]; then
    for file in "${config_dir}"/*(N-.); do
      paths="${paths}:${file}"
    done
  fi
  export KUBECONFIG="${paths}"
fi

#export KUBECONFIG=${base_config}:$(paste -sd: <(find ${config_dir} -type f \( -name "*.yaml" -o -name "*.yml" -o -name "config" \)))

if [[ -n "${KREW_ROOT}" ]] || [[ -d "${HOME}/.krew" ]]; then
  : ${KREW_ROOT:=${HOME}/.krew}
  [[ "${PATH#*${KREW_ROOT}/bin:}" == "$PATH" ]] && export PATH="${KREW_ROOT}/bin:$PATH"
fi
