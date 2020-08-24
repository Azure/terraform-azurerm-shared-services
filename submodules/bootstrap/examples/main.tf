provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  #unique_name_stub          = substr(module.naming.unique-seed, 0, 5)
  unique_name_stub          = "luked"
  azure_devops_organisation = ""
  azure_devops_project      = ""
  azure_devops_PAT          = ""
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}

#NOTE: SET THESE ENV VARS MANUALLY BEFORE RUNNING THIS EXAMPLE OTHERWISE THE SAMPLE SCRIPTS WILL FAIL 

#export TF_VAR_environment_id=
#export TF_VAR_devops_pat_token=
#export TF_VAR_devops_org=
#export TF_VAR_devops_project=
#export ARM_SUBSCRIPTION_ID=
#export ARM_TENANT_ID= 

module "bootstrap" {
  source                              = "../"
  virtual_network_name                = ""
  virtual_network_resource_group_name = ""
  build_agent_admin_username          = ""
  build_agent_admin_password          = ""
  suffix                              = [local.unique_name_stub]
  resource_group_location             = "uksouth"
  azure_devops_org                    = local.azure_devops_organisation
  azure_devops_project                = local.azure_devops_project
  azure_devops_pat_token              = local.azure_devops_PAT
  use_existing_resource_group         = false
}
