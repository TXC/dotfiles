#!/bin/bash

source "${HOME}/bin/colors.sh"
DRY_RUN=false

#CUTOFF_TIME="17:30"
AZ_PIM_CLI="${HOME}/go/bin/az-pim-cli"
CFG_FILE=".az-pim.json"
reason="work hard, play hard"
dnow=$(date '+%d/%m/%Y')

work() {
  PIM_OUTPUT=$(${AZ_PIM_CLI} list resource)
  
  # This creates: {"subscription-name": ["Role1", "Role2"], ...}
  MAPPED_PIM=$(echo "$PIM_OUTPUT" | sed 's/^[[:space:]]*//' | awk '
    /^==/ { sub(/== /,""); sub(/ ==/,""); key=$0; next }
    /^-/ { sub(/^- /,""); roles[key] = (roles[key] ? roles[key] "," : "") "\"" $0 "\"" }
    END { 
      printf "{"
      for (k in roles) {
        printf "\"%s\": [%s],", k, roles[k]
        delete roles[k]
      }
      printf "}" 
    }' | sed 's/,}/}/')

  CONFIG=$(cat "${HOME}/${CFG_FILE}" | sed 's/^ *\/\/.*//' | jq -cr '.')

  SUBS=$(jq -crn --argjson pim "${MAPPED_PIM}" --argjson config "${CONFIG}" '
    $config.subscriptions | map(
      . as $sub |
      # Filter the roles array inside this subscription to match what PIM says
      .roles |= map(select(. as $role | $pim[$sub.name] // [] | contains([$role])))
    ) | 
    # Remove subscriptions that ended up with 0 matching roles
    map(select(.roles | length > 0)) |
    { subscriptions: . }
  ')

  # Extract each subscription object from the config
  echo "${SUBS}" | jq -cr '.subscriptions[]' | \
  while read -r payload; do
    
    local max_t=$(echo "${payload}" | jq -r '.times // 1')
    # Extract max_duration from this specific payload (default to 240 if null)
    local max_d=$(echo "${payload}" | jq -r '.max_duration // 240')
    local max_d2=$((max_d * 2))
    
    # Calculate offsets dynamically based on the max_duration
    local TNOW=$(get_offset_time "0")
    #local TLAT=$(get_offset_time "${max_d}")
    #local TLAT2=$(get_offset_time "${max_d2}")
    local TLAT2=$(get_offset_time "$((max_d * 2))")

    local sub_name=$(echo "${payload}" | jq -r '.name')
    echo -en "${HM_BOLD}---${RESET}"
    echo -en " ${FG_CYAN}Subscription: ${FG_GREEN}${sub_name}${RESET}"
    echo -en " (${FG_YELLOW}Max Duration${RESET}: ${FG_MAGENTA}${max_d}m${RESET})"
    echo -e " ${HM_BOLD}---${RESET}"

		if [ -z "${CUTOFF_TIME}" ]; then
      echo -e "${FG_YELLOW}Scheduling Block ${FG_CYAN}${i}${FG_YELLOW} for ${FG_MAGENTA}${max_d}m${RESET}...${RESET}"
      #local TS=$(get_offset_time "${max_d}")
      local TS=$(get_offset_time)
      activate "${TS}" "${payload}" "${max_d}"
    else
  		for i in $(seq 1 ${max_t}); do
        echo -e "${FG_YELLOW}Scheduling Block ${FG_CYAN}${i}${FG_YELLOW} for ${FG_MAGENTA}${max_d}m${RESET}...${RESET}"
        local TS=$(get_offset_time "$((max_d * (i - 1)))")
        activate "${TS}" "${payload}" "${max_d}"
      done
		fi;
  done
}

activate() {
  local target_ts="${1}"
  local payload="${2}"
  local current_duration="${3}"

  local target_date="$(echo "${target_ts}" | cut -d' ' -f1)"
  local target_time="$(echo "${target_ts}" | cut -d' ' -f2)"

  if [ -n "${CUTOFF_TIME}" ]; then 
    # Ensure we actually got numbers before comparing
    if [[ -z "$start_epoch" || -z "$cutoff_epoch" ]]; then
        echo -e "${FG_RED}Error: Could not parse dates. Check your date format.${RESET}"
        echo -e "${FG_MAGENTA}Start: ${start_epoch}${RESET}"
        echo -e "${FG_MAGENTA}Cutoff: ${cutoff_epoch}${RESET}"
        return
    fi

    # Convert target start and the 17:00 cutoff to Unix timestamps for comparison
    local start_epoch=$(get_epoch "${target_ts}")
    local cutoff_epoch=$(get_epoch "${target_date} ${CUTOFF_TIME}")

    # Skip if the block starts after cutoff
    if [ "${start_epoch}" -ge "${cutoff_epoch}" ]; then
      echo -ne "    ${FG_RED}XX Skipping Block: Start time (${target_time}) "
			echo -e  "is after ${CUTOFF_TIME}${RESET}"
      return
    fi

    # Shorten if the block ends after cutoff
    local end_epoch=$(( start_epoch + (current_duration * 60) ))
    if [ "${end_epoch}" -gt "${cutoff_epoch}" ]; then
      local new_duration=$(( (cutoff_epoch - start_epoch) / 60 ))
      echo -ne "    ${FG_YELLOW}!! Adjusting duration from "
			echo -ne "${FG_MAGENTA}${current_duration}m${FG_YELLOW} to "
			echo -ne "${FG_MAGENTA}${new_duration}m${FG_YELLOW} to respect "
			echo -e  "${CUTOFF_TIME} cutoff.${RESET}"
      current_duration=$new_duration
    fi
    # ---------------------------
	fi

  # Extract roles and loop through them
  # Using '|' as a delimiter in case role names have spaces
  echo "${payload}" | jq -r '.name as $name | .roles[] | "\($name)|\(.)"' | \
  while IFS='|' read -r name role; do
    echo -ne "    ${HM_BOLD}->${RESET} "
    echo -ne "${FG_YELLOW}Activating ${FG_GREEN}${role}${FG_YELLOW} for "
		echo -e "${FG_MAGENTA}${current_duration}${FG_YELLOW} minutes...${RESET}"

    if $DRY_RUN; then
      echo -n "${AZ_PIM_CLI} activate resource"
      echo -n " --name \"${name}\" --role \"${role}\""
      #echo -n " --duration \"${current_duration}\" --reason \"${reason}\""
      echo -n " --start-date \"${target_date}\" --start-time \"${target_time}\""
      echo ""
    else
      ${AZ_PIM_CLI} activate resource \
        --name "${name}" --role "${role}" \
        --start-date "${target_date}" --start-time "${target_time}"
      #${AZ_PIM_CLI} activate resource \
      #  --name "${name}" --role "${role}" \
      #  --duration "${current_duration}" --reason "${reason}" \
      #  --start-date "${target_date}" --start-time "${target_time}"
    fi
  done
}

work
