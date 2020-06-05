provider "azurerm" {
  features {}
}

locals {
  prefix              = var.prefix
  suffix              = concat(["net"], var.suffix)
  resource_group_name = var.use_existing_resource_group ? var.resource_group_name : azurerm_resource_group.resource_group[0].name
}

module "naming" {
  source = "git@github.com:Azure/terraform-azurerm-naming"
  suffix = local.suffix
  prefix = local.prefix
}

resource "azurerm_resource_group" "resource_group" {
  name     = module.naming.resource_group.name
  location = var.resource_group_location
  count    = var.use_existing_resource_group ? 0 : 1
}

module "virtual_network" {
  source               = "./virtual_network_sub_module"
  resource_group       = data.azurerm_resource_group.current
  virtual_network_cidr = var.virtual_network_cidr
  prefix               = local.prefix
  suffix               = local.suffix
}

module "firewall" {
  source              = "git@github.com:Azure/terraform-azurerm-sec-firewall"
  resource_group_name = data.azurerm_resource_group.current.name
  virtual_network     = module.virtual_network.virtual_network
  prefix              = local.prefix
  suffix              = local.suffix
  public_ip_sku       = var.firewall_public_ip_sku
}
