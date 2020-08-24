#!/bin/bash

set -ex

RG_NAME=backend-${TF_VAR_suffix}
ACR_NAME=ACR$TF_VAR_suffix
ACR_HOSTNAME=acr$TF_VAR_suffix
CONNECTION_NAME=acr-shared-services

echo $TF_VAR_azure_devops_pat | az devops login --organization $TF_VAR_azure_devops_organisation

PROJECT_ID=$(az devops project show -p $TF_VAR_azure_devops_project --organization $TF_VAR_azure_devops_organisation --query "id" -o tsv)

sed \
-e "s/\${ACR_NAME}/$ACR_NAME/" \
-e "s/\${ACR_HOSTNAME}/$ACR_HOSTNAME/" \
-e "s/\${SUBSCRIPTION_ID}/$ARM_SUBSCRIPTION_ID/" \
-e "s/\${RG_NAME}/$RG_NAME/" \
-e "s/\${ARM_TENANT_ID}/$ARM_TENANT_ID/" \
-e "s/\${ENDPOINT_NAME}/$CONNECTION_NAME/" \
-e "s/\${PROJECT_ID}/$PROJECT_ID/" \
./scripts/acr_connection.template > service_connection.json

az devops service-endpoint create --service-endpoint-configuration service_connection.json --organization $TF_VAR_azure_devops_organisation --project $TF_VAR_azure_devops_project
