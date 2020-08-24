provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  unique_name_stub = substr(module.naming.unique-seed, 0, 3)
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}

resource "azurerm_resource_group" "example_resource_group" {
  name     = "${module.naming.resource_group.slug}-net-complete-${local.unique_name_stub}"
  location = "uksouth"
}

resource "azurerm_virtual_network" "example_vnet" {
  name                = "${module.naming.virtual_network.slug}-shared-${local.unique_name_stub}"
  resource_group_name = azurerm_resource_group.example_resource_group.name
  location            = azurerm_resource_group.example_resource_group.location
  address_space       = ["10.0.0.0/20"]
}

module "virtual_networking" {
  source                              = "../.."
  virtual_network_name                = azurerm_virtual_network.example_vnet.name
  virtual_network_resource_group_name = azurerm_resource_group.example_resource_group.name
  suffix                              = [local.unique_name_stub]
}
