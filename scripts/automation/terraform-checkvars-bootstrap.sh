#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-common.sh

fail=0

if [ -z "${TF_VAR_devops_org}" ]; then
  echo
  echo "TF_VAR_devops_org not set."
  echo "Please set to the URL of the ADO devops into which the build agent will be installed"
  echo "e.g. https://dev.azure.com/MY_AWESOME_DEV_ORG"
  fail=1
fi

if [ -z "${TF_VAR_devops_project}" ]; then
  echo
  echo "TF_VAR_devops_project not set."
  echo "Please set to the name of the ADO devops project into which the build agent will be installed"
  echo "e.g. MY_INCREDIBLE_PROJECT"
  fail=1
fi

if [ -z "${TF_VAR_pat_token}" ]; then
  echo
  echo "TF_VAR_pat_token not set."
  echo "Please set to the a PAT token with 'Full' access to the devops project"
  echo "(See  https://dev.azure.com/<MY_AWESOME_DEV_ORG>/_usersSettings/tokens)"
  fail=1
fi

exit $fail
