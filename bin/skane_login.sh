#!/bin/bash

source "${HOME}/bin/colors.sh"

AZCLI=$(which az)
AZPIM=$(which az-pim-cli)
AZPIM_SH=$(which azure_pim.sh)
OCCLI=$(which oc)
OC_LOGIN=$(which ocp_login.sh)
AXIS_CLIENT="/Applications/Axis Security/Axis Security Client.app/Contents/MacOS/Axis Security Client"

# Trap SIGINT (Control+C)
trap "exit" SIGINT

#SUBSCRIPTION=""
#if [ -n "${1}" ]; then
#	SUBCRIPTION="--subscription ${1}"
#fi;


#${AZCLI} login "${SUBSCRIPTION}" || "Azure Login failed"
${AZCLI} login || "Azure Login failed"

if [ -n "${AZPIM}" ]; then
	${AZPIM_SH} || "Azure PIM Login failed"
fi;

az acr login --name molngruppengitopstest || "Azure Container Registry failed"

if [ -f "${AXIS_CLIENT}" ]; then
	echo -e "${FG_YELLOW}Launching Axis Security Client...${RESET}"
	"${AXIS_CLIENT}" &
else
	echo -e "${FG_RED}Failed to launch Axis Security Client.${RESET}"
	exit 1
fi
echo -e "${FG_YELLOW}Now connect the VPN...${RESET}"
read -p "Press [Enter] to continue or abort with Ctrl+C..."

if [ -n "${OCCLI}" ]; then
	${OC_LOGIN} || "OpenShift Login failed"
fi
