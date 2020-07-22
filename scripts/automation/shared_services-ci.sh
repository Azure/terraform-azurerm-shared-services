set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-ci.sh

export TF_VAR_resource_group_location=$TF_VAR_location

terraform init
terraform fmt
terraform validate
terraform plan
