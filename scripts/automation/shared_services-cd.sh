set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-cd.sh

# Source lib
. "$DIR/backend_config.sh"

# Create a terraform backend configuration file to store the shared services state
create_backend_config "terraform.tfstate" > backend.config

# Mangle env vars into the correct format for terraform and export
export TF_VAR_suffix=[\"$TF_VAR_suffix\"]
export TF_VAR_resource_group_location=$TF_VAR_resource_group_location

# Initialize terraform using the new shared services backend
terraform init -backend-config=./backend.config
terraform plan
terraform apply -auto-approve