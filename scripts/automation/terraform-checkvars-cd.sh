#!/bin/bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-common.sh && $DIR/terraform-checkvars-bootstrap.sh

fail=$?

if [ -z "${TF_VAR_virtual_network_cidr}" ]; then
  echo
  echo "TF_VAR_virtual_network_cidr not set."
  echo "Please set to to a valid CIDR e.g. 10.0.0.0/24"
  fail=1
fi

if [ "$fail" = 1 ]; then
  exit 1
fi
