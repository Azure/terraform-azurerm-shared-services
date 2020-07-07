DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# We share a bunch of vars with the CI scripts
$DIR/terraform-checkvars-ci.sh

fail=0
if [ -z "${TF_VAR_virtual_network_cidr}" ]; then
  echo "TF_VAR_virtual_network_cidr not set."
  echo "Please set to to a valid CIDR e.g. 10.0.0.0/24"
  fail=1
fi

if [ -z "${TF_VAR_resource_group_location}" ]; then
  echo "TF_VAR_resource_group_location not set"
  echo "Please set to a valid Azure region e.g. uksouth"
  fail=1
fi

if [ "$fail" = 1 ]; then
  echo
  echo "Failed to find required env vars (did you forget to explictly reference secrets in the env block?)"
  exit 1
fi
