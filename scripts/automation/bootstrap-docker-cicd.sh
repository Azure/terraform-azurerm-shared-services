#!/bin/bash

set -e

# Build the devcontainer
docker build -f .devcontainer/Dockerfile -t ssdev .

# Run bootstrap in devcontainer
docker run -v `pwd`:/ss \
-w /ss
-e TF_VAR_suffix="$TF_VAR_suffix" \
-e TF_VAR_resource_group_location="$TF_VAR_resource_group_location" \
-e TF_VAR_virtual_network_cidr="$TF_VAR_virtual_network_cidr" \
-e TF_VAR_build_agent_admin_username="$TF_VAR_build_agent_admin_username" \
-e TF_VAR_build_agent_admin_password="$TF_VAR_build_agent_admin_password" \
-e TF_VAR_azure_devops_organisation="$TF_VAR_azure_devops_organisation" \
-e TF_VAR_azure_devops_project="$TF_VAR_azure_devops_project" \
-e TF_VAR_azure_devops_pat="$TF_VAR_azure_devops_pat" \
-e ARM_CLIENT_ID="$ARM_CLIENT_ID" \
-e ARM_CLIENT_SECRET="$ARM_CLIENT_SECRET" \
-e ARM_SUBSCRIPTION_ID="$ARM_SUBSCRIPTION_ID" \
-e ARM_TENANT_ID="$ARM_TENANT_ID" \
ssdev ./scripts/automation/bootstrap-cicd.sh