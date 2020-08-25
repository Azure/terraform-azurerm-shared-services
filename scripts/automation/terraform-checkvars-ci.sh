#!/bin/bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-common.sh

fail=$?

if [ -z "${SHARED_SERVICES_VNET_NAME}" ]; then
  echo
  echo "TF_VAR_shared_services_virtual_network_name not set."
  echo "Please set to the name of the Shared Services Virtual Network deployed by bootstrap."
  echo "It should take the form vnet-net-ss-${SUFFIX}."
  fail=1
fi

if [ -z "${SHARED_SERVICES_RESOURCE_GROUP_NAME}" ]; then
  echo
  echo "TF_VAR_shared_services_virtual_network_resource_group_name not set."
  echo "Please set to the name of the Shared Services Resource Group where the" 
  echo "Virtual Network was to deployed by bootstrap."
  echo "It should take the form rg-net-ss-${SUFFIX}."
  fail=1
fi

if [ "$fail" = 1 ]; then
  exit 1
fi