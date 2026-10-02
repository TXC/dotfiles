#!/bin/bash

NS="openshift-gitops"
SECRET_NAME="azure-bootstrap-credentials"
#NS="openshift-config"
#SECRET_NAME="entra-oauth-credentials"

#DATA=$(oc get secret ${SECRET_NAME} -n ${NS} -o json)
DATA=$(oc get secret/${SECRET_NAME} -n ${NS} -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' | yq -py -ojson)

AZURE_CLIENT_ID=$(echo "${DATA}" | jq -r '.AZURE_CLIENT_ID')
AZURE_CLIENT_SECRET=$(echo "${DATA}" | jq -r '.AZURE_CLIENT_SECRET')
AZURE_SUBSCRIPTION_ID=$(echo "${DATA}" | jq -r '.AZURE_SUBSCRIPTION_ID')
AZURE_TENANT_ID=$(echo "${DATA}" | jq -r '.AZURE_TENANT_ID')

if [ -z "${AZURE_CLIENT_ID}" ] || [ -z "${AZURE_CLIENT_SECRET}" ] || [ -z "${AZURE_TENANT_ID}" ]; then
  echo "One or more required Azure credentials are missing in the secret ${SECRET_NAME} in namespace ${NS}."
  exit 1
fi

echo "Got credentials! Logging in..."

az login --service-principal \
  --username "${AZURE_CLIENT_ID}" \
  --password "${AZURE_CLIENT_SECRET}" \
  --tenant "${AZURE_TENANT_ID}"

DEFAULT_SUBSCRIPTION=$(az account list --query "[?isDefault].id | [0]")

echo "Checking for subscriptions..."
if [[ -n "$AZURE_SUBSCRIPTION_ID" ]]; then
  echo "Got subscription, setting it to "${AZURE_SUBSCRIPTION_ID}""
  az account set --subscription "${AZURE_SUBSCRIPTION_ID}"
elif [[ -n "$DEFAULT_SUBSCRIPTION" ]]; then
  echo "No subscription found, using default, setting it to "${DEFAULT_SUBSCRIPTION}""
  az account set --subscription "${DEFAULT_SUBSCRIPTION}"
fi

TOKEN=$(az account get-access-token --query accessToken -o tsv)

echo "Logged in to Azure CLI successfully."
#echo "Access Token: ${TOKEN}"