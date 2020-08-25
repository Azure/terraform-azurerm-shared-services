######################################################################################
# bootstrap.sh - Initial setup of CI/CD environment
# 
# This script will:
#
#   - tf apply /bootstrap/main.tf to create a storage account, build agent & ACR instance
#   - Add remote backend to /bootstrap/main.tf
#   - tf init to migrate local state to remote backend
#   - Subsequent CD runs will use same remote backend
#
#   ** THIS SCRIPT EXPECTS TO BE RUN FROM THE PROJECT ROOT ***
#
######################################################################################

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/terraform-checkvars-bootstrap.sh

# Apply the initial boostrapping TF, local state
#
rm -f submodules/bootstrap/backend.tf
# Create shared docker volume to persiste terraform data between container runs
DOCKER_VOLUME_NAME=data
docker volume create "$DOCKER_VOLUME_NAME"
# Run terraform init and apply in docker
chmod +x scripts/automation/bootstrap-docker-apply.sh
docker run \
-v `pwd`:/ss \
-v "$DOCKER_VOLUME_NAME":/data \
-w /ss/submodules/bootstrap \
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
--entrypoint="/bin/sh" \
hashicorp/terraform:0.12.29 "/ss/scripts/automation/bootstrap-docker-apply.sh"

# Create terraform backend config
./scripts/automation/create_backend_config.sh
# Reinit terraform to migrate boostrap state to remote backend
docker run \
-v backend.config:/backend.config \
-v "$DOCKER_VOLUME_NAME":/data \
-w /data/bootstrap \
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
hashicorp/terraform:0.12.29 init -backend-config=/data/backend.config -force-copy