TF_STATE_KEY=${1:-"terraform.tfstate"} 

# Add remote backend
cat << EOF > backend.tf
terraform { 
    backend "azurerm" {} 
}
EOF

BACKEND_CONFIG="backend.config"
# Remove existing terraform backend config file if exists
rm -f $BACKEND_CONFIG

# Get terraform backend config values
RG_NAME=rg-dev-ss-${TF_VAR_suffix}
SA_NAME=sadevss${TF_VAR_suffix}
CT_NAME="terraform-tfstate"
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
SA_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $SA_NAME --query "[0].value")

# Write new terraform backend config file
echo "resource_group_name=\"$RG_NAME\"" >> $BACKEND_CONFIG
echo "storage_account_name=\"$SA_NAME\"" >> $BACKEND_CONFIG
echo "container_name=\"$CT_NAME\"" >> $BACKEND_CONFIG
echo "key=\"$TF_STATE_KEY\"" >> $BACKEND_CONFIG
echo "access_key=$SA_KEY" >> $BACKEND_CONFIG
