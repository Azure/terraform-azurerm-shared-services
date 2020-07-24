#!/bin/bash

set -ex

RG_NAME=backend-${TF_VAR_environment_id}
ACR_NAME=ACR$TF_VAR_environment_id
ACR_HOSTNAME=acr$TF_VAR_environment_id
CONNECTION_NAME=acr_shared_services

export AZURE_DEVOPS_EXT_PAT=$TF_VAR_devops_pat_token
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az devops login --organization $TF_VAR_devops_org

PROJECT_ID=$(az devops project show -p $TF_VAR_devops_project --organization $TF_VAR_devops_org --query "id" -o tsv)

sed \
-e "s/\${ACR_NAME}/$ACR_NAME/" \
-e "s/\${ACR_HOSTNAME}/$ACR_HOSTNAME/" \
-e "s/\${SUBSCRIPTION_ID}/$ARM_SUBSCRIPTION_ID/" \
-e "s/\${RG_NAME}/$RG_NAME/" \
-e "s/\${ARM_TENANT_ID}/$ARM_TENANT_ID/" \
-e "s/\${ENDPOINT_NAME}/$CONNECTION_NAME/" \
-e "s/\${PROJECT_ID}/$PROJECT_ID/" \
acr_connection.template > service_connection.json

az devops service-endpoint create --service-endpoint-configuration service_connection.json --organization $TF_VAR_devops_org --project $TF_VAR_devops_project
