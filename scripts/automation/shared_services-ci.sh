set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars.sh

terraform init
terraform format
terraform validate
terraform plan
