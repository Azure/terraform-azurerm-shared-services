provider "azurerm" {
  features {}
}

locals {
  suffix = concat(["net"], var.suffix)
  #The resource_group[0] is needed to index into the azurerm_resource_group because of the count used for conditional instantiation.
  resource_group = var.use_existing_resource_group ? data.azurerm_resource_group.current[0] : azurerm_resource_group.resource_group[0]
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = local.suffix
}

resource "azurerm_resource_group" "resource_group" {
  name     = module.naming.resource_group.name
  location = var.resource_group_location
  count    = var.use_existing_resource_group ? 0 : 1
}

module "virtual_network" {
  source               = "./virtual_network_sub_module"
  resource_group       = local.resource_group
  virtual_network_cidr = var.virtual_network_cidr
  suffix               = local.suffix
}

#NOTE: An Azure Firewall has an associated monthly cost irrespective of whether or not it is being actively used. Current usecase does not require the firewall
# to be in place.  

/* module "firewall" {
  source             = "git::https://github.com/Azure/terraform-azurerm-sec-firewall"
  virtual_network    = module.virtual_network.virtual_network
  firewall_subnet_id = module.virtual_network.firewall_subnet.id
  suffix             = local.suffix
  public_ip_sku      = var.firewall_public_ip_sku
} */
