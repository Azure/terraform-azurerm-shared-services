provider "azurerm" {
  version = "~>2.0"
  features {}
}

provider "azuredevops" {
  version               = ">= 0.0.1"
  org_service_url       = var.devops_org
  personal_access_token = var.devops_pat_token
}

locals {
  suffix = concat(["ss", "net"], var.suffix)
  #The vnet_resource_group[0] is needed to index into the azurerm_resource_group because of the count used for conditional instantiation.
  resource_group = var.use_existing_resource_group ? data.azurerm_resource_group.current[0] : azurerm_resource_group.vnet_resource_group[0]
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = local.suffix
}

resource "azurerm_resource_group" "vnet_resource_group" {
  name     = module.naming.resource_group.name
  location = var.location
  count    = var.use_existing_resource_group ? 0 : 1
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = module.naming.virtual_network.name
  location            = azurerm_resource_group.vnet_resource_group[0].location
  resource_group_name = azurerm_resource_group.vnet_resource_group[0].name
  address_space       = [var.virtual_network_cidr]
}

module "private_build_environment" {
  source                              = "../build_environment"
  org                                 = var.devops_org
  project                             = var.devops_project
  pat_token                           = var.devops_pat_token
  environment_id                      = var.environment_id
  location                            = var.location
  virtual_network_name                = azurerm_virtual_network.virtual_network.name
  virtual_network_resource_group_name = azurerm_resource_group.vnet_resource_group[0].name
}
