#!/bin/bash

# Login to multiple OpenShift environments with optional GUI prompt via yad

environments=(infra01 test01 test02 prod01 nonprodhub01)

username_file="$HOME/.oc_login_credentials.json"

prompt_with_yad() {
  # Load saved username if exists
  saved_username=""
  if [[ -f "$username_file" ]]; then
    saved_username=$(<"$username_file")
  fi

  result=$(yad --form --title="Login" --center --width=400 \
    --field="Username" "$saved_username" \
    --field="Password:":H)
  [ $? -ne 0 ] && echo "Cancelled." && exit 1

  username=$(echo "$result" | cut -d'|' -f1)
  password=$(echo "$result" | cut -d'|' -f2)

  # Save username for next time
  echo "$username" > "$username_file"
}


# Function: Prompt via terminal
prompt_with_terminal() {
  read -p "Enter your username: " username
  echo
  read -sp "Enter your password: " password
  echo
}

# Determine how to prompt
if command -v yad >/dev/null 2>&1 && ! [ -t 0 ]; then
  prompt_with_yad
else
  prompt_with_terminal
fi

# After prompting for username/password, validate inputs
if [[ -z "$username" || -z "$password" ]]; then
  echo "Error: Username and password must not be empty."
  exit 1
fi


# Login to all environments
for context in "${environments[@]}"; do
  echo "Logging into ${context}..."
  oc login --server="https://api.ocp${context}.csni.se:6443" \
    --username="$username" --password="$password"

done