######################################################################################
# bootstrap.sh - Initial setup of CI/CD environment
# 
# This script will:
#
#   - tf apply /bootstrap/main.tf to create a storage account, build agent & ACR instance
#   - Add remote backend to /bootstrap/main.tf
#   - tf init to migrate local state to remote backend
#   - Subsequent CD runs will use same remote backend
#
#   ** THIS SCRIPT EXPECTS TO BE RUN FROM THE PROJECT ROOT ***
#
######################################################################################

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-common.sh

# Apply the initial boostrapping TF, local state
#
rm -f bootstrap/backend.tf
terraform init bootstrap && terraform plan bootstrap && terraform apply --auto-approve bootstrap

# Add remote backend
#
cat << EOF > bootstrap/backend.tf
terraform { 
    backend "azurerm" {} 
}
EOF

RG_NAME=backend-${TF_VAR_environment_id}
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

# Re-init with remote backend
terraform init --backend-config=./backend.config bootstrap
