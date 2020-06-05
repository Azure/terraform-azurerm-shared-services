provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "naming" {
  source = "git@github.com:Azure/terraform-azurerm-naming"
}

module "virtual_networking" {
  source                      = "../"
  virtual_network_cidr        = "10.0.0.0/20"
  use_existing_resource_group = false
  resource_group_location     = "uksouth"
  firewall_public_ip_sku      = "Standard"
  prefix                      = substr(module.naming.unique-seed, 0, 6)
  suffix                      = substr(module.naming.unique-seed, 0, 6)
}

