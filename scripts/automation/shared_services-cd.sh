set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars.sh
 
export TF_VAR_authorized_security_subnet_ids=$BUILD_AGENT_SUBNET_ID
$DIR/deploy_shared_services.sh

