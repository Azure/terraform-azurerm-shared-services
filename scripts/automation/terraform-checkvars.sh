fail=0

if [ -z "${ARM_SUBSCRIPTION_ID}" ]; then
  echo
  echo "ARM_SUBSCRIPTION_ID not set."
  echo "Please set to the id of the subscription you wish to deploy to."
  echo "(az account list)"
  fail=1
fi

if [ -z "${ARM_CLIENT_ID}" ]; then
  echo
  echo "ARM_CLIENT_ID not set."
  echo "Please set to the id of a service principal authorised to deploy to your subscription"
  echo "(az ad sp list --show-mine)" 
  fail=1
fi

if [ -z "${ARM_CLIENT_SECRET}" ]; then
  echo
  echo "ARM_CLIENT_SECRET not set."
  echo "Please set to the password of a service principal authorised to deploy to your subscription"
  echo "(az ad sp create-for-rbac --name XXXXXXXXXXX)"
  fail=1
fi

if [ -z "${ARM_TENANT_ID}" ]; then
  echo
  echo "ARM_TENANT_ID not set."
  echo "Please set to the tenant id of the AAD instance you are using for authorisation"
  echo "(az account show)"
  fail=1
fi

if [ -z "${TF_VAR_virtual_network_cidr}" ]; then
  echo
  echo "TF_VAR_virtual_network_cidr not set."
  echo "Please set to to a valid CIDR e.g. 10.0.0.0/24"
  fail=1
fi

if [ -z "${TF_VAR_location}" ]; then
  echo
  echo "TF_VAR_location not set"
  echo "Please set to a valid Azure region e.g. uksouth"
  fail=1
fi

if [ "$fail" = 1 ]; then
  exit 1
fi
