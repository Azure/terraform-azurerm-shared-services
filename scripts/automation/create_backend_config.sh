# Add remote backend
#
cat << EOF > backend.tf
terraform { 
    backend "azurerm" {} 
}
EOF

RG_NAME=rg-dev-ss-${TF_VAR_suffix}
SA_NAME=sadevss-${TF_VAR_suffix}
CT_NAME="terraform-tfstate"
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
SA_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $SA_NAME --query "[0].value")

# Create fresh backend.config

BACKEND_CONFIG="backend.config"

rm -f $BACKEND_CONFIG
echo "resource_group_name=\"$RG_NAME\"" >> $BACKEND_CONFIG
echo "storage_account_name=\"$SA_NAME\"" >> $BACKEND_CONFIG
echo "container_name=\"$CT_NAME\"" >> $BACKEND_CONFIG
echo "key=\"terraform.tfstate\"" >> $BACKEND_CONFIG
echo "access_key=$SA_KEY" >> $BACKEND_CONFIG
