provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  #unique_name_stub          = substr(module.naming.unique-seed, 0, 5)
  unique_name_stub          = "luked"
  azure_devops_organisation = "https://dev.azure.com/lukedevonshire"
  azure_devops_project      = "AnalyticsPlatform"
  azure_devops_PAT          = "g25u6yfar532e35g7md37mb3dzsq4s4wbho4ku6kt4jd3sluqbfa"
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}

#NOTE: SET THESE ENV VARS MANUALLY BEFORE RUNNING THIS EXAMPLE OTHERWISE THE SAMPLE SCRIPTS WILL FAIL 

#export TF_VAR_environment_id=luked
#export TF_VAR_devops_pat_token=g25u6yfar532e35g7md37mb3dzsq4s4wbho4ku6kt4jd3sluqbfa 
#export TF_VAR_devops_org=https://dev.azure.com/lukedevonshire
#export TF_VAR_devops_project=AnalyticsPlatform
#export ARM_SUBSCRIPTION_ID=d4bf2856-9a60-4ce4-b41f-423833662915 
#export ARM_TENANT_ID=72f988bf-86f1-41af-91ab-2d7cd011db47 

module "build_environment" {
  source                      = "../../bootstrap"
  virtual_network_cidr        = "10.0.0.0/20"
  environment_id              = local.unique_name_stub
  suffix                      = [local.unique_name_stub]
  location                    = "uksouth"
  devops_org                  = local.azure_devops_organisation
  devops_project              = local.azure_devops_project
  devops_pat_token            = local.azure_devops_PAT
  use_existing_resource_group = false
}


