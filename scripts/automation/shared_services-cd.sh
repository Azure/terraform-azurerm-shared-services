DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars.sh

$DIR/deploy_remote_backend.sh
$DIR/deploy_shared_services.sh
