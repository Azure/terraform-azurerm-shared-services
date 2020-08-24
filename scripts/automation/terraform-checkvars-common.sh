#!/bin/bash

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

if [ -z "${TF_VAR_resource_group_location}" ]; then
  echo
  echo "TF_VAR_resource_group_location not set"
  echo "Please set to a valid Azure region e.g. uksouth"
  fail=1
fi

if [ -z "${TF_VAR_suffix}" ]; then
  echo
  echo "TF_VAR_suffix not set"
  echo "Please set to a unique 5 character alphanumeric identifier"
  fail=1
fi

MIN=3
MAX=5
if [[ ! $TF_VAR_suffix =~ ^[[:alnum:]]{$MIN,$MAX}$ ]]; then
  echo "ERROR: TF_VAR_suffix must contain only numbers or letters and be between $MIN and $MAX characters in length"
  fail=1
fi

exit $fail
