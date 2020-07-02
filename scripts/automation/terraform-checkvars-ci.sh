fail=0

if [ -z "${ARM_SUBSCRIPTION_ID}" ]; then
  echo "ARM_SUBSCRIPTION_ID not set."
  echo "Please set to the id of the subscription you wish to deploy to."
  echo "(az account list)"
  fail=1
fi

if [ -z "${ARM_CLIENT_ID}" ]; then
  echo "ARM_CLIENT_ID not set."
  echo "Please set to the id of a service principal authorised to deploy to your subscription"
  echo "(az ad sp list --show-mine)" 
  fail=1
fi

if [ -z "${ARM_CLIENT_SECRET}" ]; then
  echo "ARM_CLIENT_SECRET not set."
  echo "Please set to the password of a service principal authorised to deploy to your subscription"
  echo "(az ad sp create-for-rbac --name XXXXXXXXXXX)"
  fail=1
fi

if [ -z "${ARM_TENANT_ID}" ]; then
  echo "ARM_TENANT_ID not set."
  echo "Please set to the tenant id of the AAD instance you are using for authorisation"
  echo "(az account show)"
  fail=1
fi

if [ "$fail" = 1 ]; then
  echo
  echo "Failed to find required env vars (did you forget to explictly reference secrets in the env block?)"
  exit 1
fi
