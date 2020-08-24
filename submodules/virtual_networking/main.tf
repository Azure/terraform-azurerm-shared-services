provider "azurerm" {
  features {}
}

locals {
  suffix         = var.suffix
  resource_group = data.azurerm_resource_group.virtual_network_resource_group
}

module "virtual_network" {
  source               = "./virtual_network_subnets"
  virtual_network_cidr = data.azurerm_virtual_network.virtual_network.address_space
  virtual_network_name = var.virtual_network_name
  resource_group       = local.resource_group
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
