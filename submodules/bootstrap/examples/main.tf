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
  build_agent_admin_username  = ""
  build_agent_admin_password  = ""
  azure_devops_organisation   = ""
  azure_devops_project        = ""
  azure_devops_pat            = ""
  suffix                      = [local.unique_name_stub]
  use_existing_resource_group = false
  resource_group_name         = ""
}
