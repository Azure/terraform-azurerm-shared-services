set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-cd.sh

export TF_VAR_suffix=[\"$TF_VAR_environment_id\"]
export TF_VAR_resource_group_location=$TF_VAR_location

$DIR/create_backend_config.sh
terraform init -backend-config=./backend.config && terraform plan && terraform apply -auto-approve

