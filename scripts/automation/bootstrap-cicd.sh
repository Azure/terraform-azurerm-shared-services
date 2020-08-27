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

# Ensure backend terraform file
ensure_terraform_azure_backend_config_file submodules/bootstrap/backend.tf

BOOTSTRAP_TFSTATE_NAME="bootstrap/terraform.tfstate"
if [ check_backend_config_exists_in_azure ]; then
    # Ensure backend.config file for existing azure backend
    rm -f backend.config
    create_backend_config "$BOOTSTRAP_TFSTATE_NAME" > backend.config
    # Init and apply using existing azure backend to update resources
    terraform init -backend-config=./backend.config submodules/bootstrap
    terraform apply -auto-approve submodules/bootstrap
else
    # Init and apply using a local state backend to create azure resources
    terraform init submodules/bootstrap
    terraform apply -auto-approve submodules/bootstrap
    # Ensure backend.config file for newly deployed azure resources
    rm -f backend.config
    create_backend_config "$BOOTSTRAP_TFSTATE_NAME" > backend.config
    # Reinitialize terraform to copy local state to new azure backend
    terraform init -backend-config=./backend.config -force-copy
fi