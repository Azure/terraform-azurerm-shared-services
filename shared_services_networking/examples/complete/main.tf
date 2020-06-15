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

module "virtual_networking" {
  source                      = "../"
  virtual_network_cidr        = "10.0.0.0/20"
  use_existing_resource_group = false
  resource_group_location     = "uksouth"
  firewall_public_ip_sku      = "Standard"
  suffix                      = [local.unique_name_stub]
}

