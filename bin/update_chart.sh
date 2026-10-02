#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hvul] [-d name] [-n version] args ...
#%
#% DESCRIPTION
#%    This is a script template
#%    to start any good shell script.
#%
#% OPTIONS
#%    -d [name]         Set dependency name
#%    -n [version]      Set new version
#%    -u                Update dependencies
#%    -l                Use local dependencies
#%    -h                Print this help
#%    -v                Print script information
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -d loki -n 1.2.3 ./charts/mychart
#%    ${SCRIPT_NAME} -d loki -n 1.2.3 -u ./charts/mychart
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          
#-    copyright       None
#-    license         None
#-    script_id       !?
#-
#================================================================
#  HISTORY
#     2026/03/12 : 271829 : Script creation
# 
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#================================================================
# END_OF_HEADER
#================================================================

SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
SCRIPT_NAME="$(basename ${0})"

  #== usage functions ==#
usage() {
  printf "Usage: ";
  head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ;
}
usagefull() {
  head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ;
}
scriptinfo() {
  head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#-" | sed -e "s/^#-//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g";
}


# Default directory to current if not provided later
CHART_DIR=""
DEP_NAME=""
NEW_VERSION=""
UPDATE=1
USELOCAL=1

# Parse flags
while getopts "d:n:luhv" opt; do
  case $opt in
    d) DEP_NAME="$OPTARG"
      ;;
    n) NEW_VERSION="$OPTARG"
      ;;
    l) USELOCAL=0
      ;;
    u) UPDATE=0
      ;;
    h) usagefull;
      exit 0
      ;;
    v) scriptinfo;
      exit 0
      ;;
    *) usage
      ;;
  esac
done

# Shift off the options so $1 becomes the positional argument (directory)
shift $((OPTIND -1))
CHART_DIR=${1:-"."}
CHART_FILE="$CHART_DIR/Chart.yaml"

if [[ -z "${DEP_NAME}" || -z "${NEW_VERSION}" ]]; then
  echo "Error: Missing required flags -d (dependency) and -n (version)." >&2
  usage
  exit 1
fi

if [[ ! -f "${CHART_FILE}" ]]; then
  echo "Error: ${CHART_FILE} not found."
  exit 1
fi

# 2. Check if dependency exists
EXISTS=$(yq ".dependencies[] | \
  select(.name == \"${DEP_NAME}\") | \
  .name" "${CHART_FILE}")

if [ -z "$EXISTS" ]; then
  echo "Error: Dependency '${DEP_NAME}' not found in ${CHART_FILE}"
  exit 1
fi

yq -i "(.dependencies[] | \
  select(.name == \"${DEP_NAME}\")).version = \"${NEW_VERSION}\"" \
  "${CHART_FILE}"

if [ $USELOCAL -eq 0 ]; then
	echo "Setting local repository"
  REPO=$(yq ".dependencies[] | \
    select(.name == \"${DEP_NAME}\") | \
    .repository" "${CHART_FILE}")
  if [ "${REPO}" = "oci://molngruppengitopstest.azurecr.io/helm" ]; then
    # If local, set the repository to a local path (optional, adjust as needed)
    LOCAL_PATH="file://../../../../../molngruppen-catalogs/${DEP_NAME}"
    yq -i "(.dependencies[] | \
      select(.name == \"${DEP_NAME}\")).repository = \"${LOCAL_PATH}\"" \
      "${CHART_FILE}"
  fi
fi

if [ $UPDATE -eq 0 ]; then
  helm dependency update ${CHART_DIR} --skip-refresh > /dev/null 2>&1 || {
    echo "Error: Failed to update dependencies for ${CHART_DIR}"
    exit 1
  }
fi

echo "Updated '${DEP_NAME}' to '${NEW_VERSION}' in ${CHART_FILE}"