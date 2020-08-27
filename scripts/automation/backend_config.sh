#######################################
# Ensure an azurerm backend exists in the Terraform configuration
# Globals:
#   None
# Arguments:
#   The backend definition file, a path
#######################################
function ensure_terraform_azure_backend_config_file {
    if [ -z "$1" ]; then echo "$0: Argument 1 missing"; exit 1; fi

    if [ ! -f "$1" ]; then
    # Write azure backend to terraform file
    cat << EOF > $1
terraform { 
    backend "azurerm" {} 
}
EOF
    fi
}

#######################################
# Perform an Az CLI login
# Globals:
#   ARM_CLIENT_ID
#   ARM_CLIENT_SECRET
#   ARM_TENANT_ID
# Arguments:
#   None
#######################################
function az_login {
    az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
}

#######################################
# Returns success code if backend exists
# Globals:
#   TF_VAR_suffix
# Arguments:
#   None
#######################################
function check_backend_config_exists_in_azure {
    RG_NAME=rg-dev-ss-${TF_VAR_suffix}
    SA_NAME=sadevss${TF_VAR_suffix}
    set +e # disable exit on error
    az storage account keys list --resource-group $RG_NAME --account-name $SA_NAME --query "[0].value" > /dev/null 2>&1
    STATUS="$?"
    set -e # enable exit on error
    return $STATUS
}

#######################################
# Returns success code if backend exists
# Globals:
#   TF_VAR_suffix
# Arguments:
#   The terraform state file key
#######################################
function create_backend_config {
    if [ -z "$1" ]; then echo "$0: Argument 1 missing"; exit 1; fi

    RG_NAME=rg-dev-ss-${TF_VAR_suffix}
    SA_NAME=sadevss${TF_VAR_suffix}
    CT_NAME="terraform-tfstate"
    SA_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $SA_NAME --query "[0].value")
    echo "resource_group_name=\"$RG_NAME\""
    echo "storage_account_name=\"$SA_NAME\""
    echo "container_name=\"$CT_NAME\""
    echo "key=\"$1\""
    echo "access_key=$SA_KEY"
}