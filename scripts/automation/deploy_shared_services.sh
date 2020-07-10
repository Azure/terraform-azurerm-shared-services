set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars.sh

export TF_VAR_suffix=[\"$TF_VAR_environment_id\"]
export TF_VAR_authorized_security_client_ips=[\"$(dig +short myip.opendns.com @resolver1.opendns.com)\"]
terraform init -backend-config=./backend.config && terraform plan && terraform apply -auto-approve
