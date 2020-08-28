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

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-bootstrap.sh

# Source lib
. "$DIR/backend_config.sh"

# Azure login
az_login

BOOTSTRAP_TF_LOCAL_BACKEND_STATE_FILE="./terraform.tfstate.backup"
BOOTSTRAP_TF_LOCAL_BACKEND_CONFIG_FILE="backend.tf"
BOOTSTRAP_TF_REMOTE_BACKEND_STATE_FILE="bootstrap/terraform.tfstate"
BOOTSTRAP_TF_REMOTE_BACKEND_CONFIG_FILE="submodules/bootstrap/backend.tf"
if check_backend_config_exists_in_azure; then
    echo "initializing terraform using existing azure backend"
    # Ensure backend.config file for existing azure backend
    echo "ensuring backend config file backend.config"
    rm -f backend.config "$BOOTSTRAP_TF_REMOTE_BACKEND_CONFIG_FILE"
    create_backend_config "$BOOTSTRAP_TF_REMOTE_BACKEND_STATE_FILE" > backend.config
    echo "ensuring backend terraform file $BOOTSTRAP_TF_REMOTE_BACKEND_CONFIG_FILE"
    ensure_terraform_azure_backend_config_file "$BOOTSTRAP_TF_REMOTE_BACKEND_CONFIG_FILE"
    # Init and apply using existing azure backend to update resources
    echo "applying terraform to update bootstrap azure resources"
    terraform init -backend-config=./backend.config submodules/bootstrap
    terraform apply -auto-approve submodules/bootstrap
else
    echo "initializing terraform using local backend"
    # Init and apply using a local state backend to create azure resources
    terraform init submodules/bootstrap
    echo "applying terraform to create bootstrap azure resources"
    terraform apply -auto-approve submodules/bootstrap
    # Ensure backend.config file for newly deployed azure resources
    echo "ensuring backend config file backend.config"
    rm -f backend.config "$BOOTSTRAP_TF_LOCAL_BACKEND_CONFIG_FILE"
    create_backend_config "$BOOTSTRAP_TF_REMOTE_BACKEND_STATE_FILE" > backend.config
    echo "ensuring backend terraform file $BOOTSTRAP_TF_LOCAL_BACKEND_CONFIG_FILE"
    ensure_terraform_azure_backend_config_file "$BOOTSTRAP_TF_LOCAL_BACKEND_CONFIG_FILE"
    # Reinitialize terraform to copy local state to new azure backend
    echo "migrating local backend state to azurerm backend"
    terraform init -backend-config=./backend.config -force-copy
    # NOTE: azurerm backend doesn't support -force so needs to be done manually
    remove_existing_backend_state_file "$BOOTSTRAP_TF_REMOTE_BACKEND_STATE_FILE"
    terraform state push -force "$BOOTSTRAP_TF_LOCAL_BACKEND_STATE_FILE"
fi