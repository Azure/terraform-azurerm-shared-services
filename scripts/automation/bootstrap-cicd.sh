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

# Remove existing backend terraform file if exists
rm -f submodules/bootstrap/backend.tf

# Apply the initial boostrapping terraform using a local state store
terraform init submodules/bootstrap
terraform plan submodules/bootstrap
terraform apply -auto-approve submodules/bootstrap

# Create a remote terraform backend configuration file from the 
# deployed resources to store the bootstrap state
$DIR/create_backend_config.sh "bootstrap/terraform.tfstate"

# Reinitialize the bootstrap terraform using 
# the new backend to persiste state remotely
terraform init -backend-config=./backend.config -force-copy