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
$DIR/terraform-checkvars-bootstrap.sh

# Apply the initial boostrapping TF, local state
#
rm -f submodules/bootstrap/backend.tf
terraform init submodules/bootstrap && terraform plan submodules/bootstrap && terraform apply -auto-approve submodules/bootstrap

# Move bootstrap to the module it becomes in root and then re-init with remote backend

#resources=$(terraform state list)

#for resource in $resources
#do
#  terraform state mv $resource module.backend.$resource
#done

$DIR/create_backend_config.sh
terraform init -backend-config=./backend.config -force-copy