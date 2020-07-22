set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-cd.sh

# Add remote backend
#
cat << EOF > backend.tf
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


export TF_VAR_suffix=[\"$TF_VAR_environment_id\"]
export TF_VAR_resource_group_location=$TF_VAR_location
#export TF_VAR_authorized_security_client_ips=[\"$(curl -s https://api.ipify.org)\"]

terraform init -backend-config=./backend.config && terraform plan && terraform apply -auto-approve
