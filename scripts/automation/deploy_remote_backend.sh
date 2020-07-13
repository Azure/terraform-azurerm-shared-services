#!/bin/bash

####################################################################################
#
# deploy_remote_backend.sh - Boostrap remote backend storage for Terraform
#
#  1) Validate required ENV TF_VAR_environment_id
#  2) Check for existence of a storage account ${TF_VAR_environment_id}
#  3) If not exists, tf apply to create
#  4) Create backend.config pointing to created or pre-existing backend storage
#     - Can do this without local tfstate because naming rules are known and
#       we can recover the storage access key using az cli
#
#  ** This script should be run with a working directory at the root of this repo ** 
#
####################################################################################

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars.sh

function add_backend_to_terraform_config 
{
  # Write azurerm backend to terraform file
  cat << EOF > backend.tf
terraform { 
    backend "azurerm" {} 
}
EOF
}

function validate_environment_id 
{
  if [ -z $TF_VAR_environment_id ]; then
    echo "ERROR: MUST provide a value for TF_VAR_environment_id"
    exit 1
  fi

  if [[ ! $TF_VAR_environment_id =~ ^[[:alnum:]]{3,21}$ ]]; then
    echo "ERROR: TF_VAR_environment_id must contain only numbers or letters and be between 3 and 21 characters in length"
    exit 1
  fi
}


validate_environment_id
add_backend_to_terraform_config

echo "Log in as service principal.."
az login --service-principal --username $ARM_CLIENT_ID  --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
backend_exists=$(az storage account list --query "length([?name=='$TF_VAR_environment_id'].name)")

if [ $backend_exists = "0" ]; then
  echo "INFO: Creating new backend: $TF_VAR_environment_id"
  pushd terraform-azurerm-remote-state && terraform init && terraform plan && terraform apply -auto-approve && popd
else
  echo "INFO: Backend appears to already exist for $TF_VAR_environment_id"
fi

# Collect up the vars.
# NB: This is tightly-coupled with the backend main.tf
# and replicates the naming conventions applied there

RG_NAME=be-${TF_VAR_environment_id}
SA_NAME=${TF_VAR_environment_id}
CT_NAME="terraform-tfstate"
SA_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $SA_NAME --query "[0].value")

# Create fresh backend.config

BACKEND_CONFIG="backend.config"

rm -f $BACKEND_CONFIG
echo "resource_group_name=\"$RG_NAME\"" >> $BACKEND_CONFIG
echo "storage_account_name=\"$SA_NAME\"" >> $BACKEND_CONFIG
echo "container_name=\"$CT_NAME\"" >> $BACKEND_CONFIG
echo "key=\"terraform.tfstate\"" >> $BACKEND_CONFIG
echo "access_key=$SA_KEY" >> $BACKEND_CONFIG
