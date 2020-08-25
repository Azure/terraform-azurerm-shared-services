set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-cd.sh

$DIR/create_backend_config.sh

export TF_VAR_suffix=[\"$TF_VAR_suffix\"]
export TF_VAR_resource_group_location=$TF_VAR_resource_group_location

terraform init -backend-config=./backend.config && terraform plan && terraform apply -auto-approve

