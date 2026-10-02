#!/bin/bash

CFG_FILE=".oc_login_credentials.json"
FULL_PATH="${HOME}/${CFG_FILE}"

# Ensure the config file exists
if [ ! -f "$FULL_PATH" ]; then
    echo "Configuration file not found: $FULL_PATH" >&2
    exit 1
fi

ctx=$(oc config current-context)

# Strip comments and read JSON
CONFIG=$(sed 's/^ *\/\/.*//' "$FULL_PATH" | jq -cr '.')

if [ -z "${CONFIG}" ] || [ "${CONFIG}" = "null" ]; then
    echo "No cached credentials found..." >&2
    exit 1
fi

echo "${CONFIG}" | jq -c '.[]' | while read -r i; do
    if [ -z "${i}" ] || [ "${i}" = "null" ]; then
        continue
    fi

    # Extract fields safely using jq
    server=$(echo "${i}" | jq -r '.server // empty')
    context=$(echo "${i}" | jq -r '.context // empty')
    username=$(echo "${i}" | jq -r '.username // empty')
    password=$(echo "${i}" | jq -r '.password // empty')
    web=$(echo "${i}" | jq -r '.web // false')

    param=()

    # Append server (positional argument for oc login)
    if [ -n "${server}" ]; then
        param+=("${server}")
    fi

    # Append context if present
    if [ -n "${context}" ]; then
        param+=("--context=${context}")
    fi

    # Evaluate the 'web' logic
    if [ "${web}" = "true" ]; then
        # Append --web and ignore username/password
        param+=("--web")
    else
        # If web is false, username and password are mandatory
        if [ -z "${username}" ] || [ -z "${password}" ]; then
            echo "Error: 'username' and 'password' are mandatory when 'web' is false for server: ${server:-unknown}" >&2
            continue # Skip this entry and move to the next cluster
        fi
        param+=("--username=${username}" "--password=${password}")
    fi

    echo "Checking for credentials for ${server} ..."

    # Execute login with dynamically built parameters
    oc login "${param[@]}" || echo "Failed to login to ${server} with context ${context}"
done

# Restore the original context
oc config use-context "${ctx}"