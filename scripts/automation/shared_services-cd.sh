set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars.sh
 
export TF_VAR_authorized_audit_subnet_ids=$BUILD_AGENT_SUBNET_ID
$DIR/deploy_remote_backend.sh && $DIR/deploy_shared_services.sh

