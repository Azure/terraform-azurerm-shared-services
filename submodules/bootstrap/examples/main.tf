#NOTE: SET THESE ENV VARS MANUALLY BEFORE RUNNING THIS EXAMPLE OTHERWISE THE SAMPLE SCRIPTS WILL FAIL 

#export TF_VAR_environment_id=luked
#export TF_VAR_devops_pat_token=tn2qpocl67us3smyut7yh6v74sqmyw6mpzn6h2f3sttvupgchgeq
#export TF_VAR_devops_org=https://dev.azure.com/lukedevonshire
#export TF_VAR_devops_project=AnalyticsPlatform
#export ARM_SUBSCRIPTION_ID=d4bf2856-9a60-4ce4-b41f-423833662915 
#export ARM_TENANT_ID=72f988bf-86f1-41af-91ab-2d7cd011db47 

provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  unique_name_stub = "luked"
}

module "bootstrap" {
  source                      = "../"
  resource_group_location     = "uksouth"
  virtual_network_cidr        = "10.0.0.0/20"
  build_agent_admin_username  = "buildadmin"
  build_agent_admin_password  = "Ais4Alpha!"
  azure_devops_organisation   = "https://dev.azure.com/lukedevonshire"
  azure_devops_project        = "AnalyticsPlatform"
  azure_devops_pat            = "tn2qpocl67us3smyut7yh6v74sqmyw6mpzn6h2f3sttvupgchgeq"
  suffix                      = [local.unique_name_stub]
  use_existing_resource_group = false
  resource_group_name         = ""
}
