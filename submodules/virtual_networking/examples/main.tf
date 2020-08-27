provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  unique_name_stub = substr(module.naming.unique-seed, 0, 3)
  suffix           = concat(["ss"], [local.unique_name_stub])
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
  address_space       = ["9.0.0.0/20"]
}

resource "azurerm_subnet" "example_subnet" {
  name                 = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.slug, "dev", join("-", local.suffix)])
  resource_group_name  = azurerm_resource_group.example_resource_group.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.example_vnet.address_space[0], 4, 0)]
}

module "virtual_network" {
  source                                  = "../"
  virtual_network_name                    = azurerm_virtual_network.example_vnet.name
  virtual_network_resource_group_name     = azurerm_resource_group.example_resource_group.name
  virtual_network_resource_group_location = azurerm_resource_group.example_resource_group.location
  suffix                                  = local.suffix
}
