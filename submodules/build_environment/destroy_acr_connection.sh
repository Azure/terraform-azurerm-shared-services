#!/bin/bash

set -ex

CONNECTION_NAME=acr-shared-services

echo $TF_VAR_azure_devops_pat | az devops login --organization $TF_VAR_azure_devops_organisation

CONNECTION_ID=$(az devops service-endpoint list --organization $TF_VAR_azure_devops_organisation --project $TF_VAR_azure_devops_project --query "[?name=='$CONNECTION_NAME'].id" -o tsv)
az devops service-endpoint delete --id $CONNECTION_ID --organization $TF_VAR_azure_devops_organisation --project $TF_VAR_azure_devops_project -y
