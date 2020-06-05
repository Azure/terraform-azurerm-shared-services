provider "azurerm" {
  features {}
}

module "naming" {
  source = "git@github.com:Azure/terraform-azurerm-naming"
  suffix = var.suffix
  prefix = var.prefix
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = module.naming.virtual_network.name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = [var.virtual_network_cidr]
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 2, 0)]
}

resource "azurerm_subnet" "secrets_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "secrets"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 2, 1)]
  service_endpoints                              = ["Microsoft.KeyVault"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "audit_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "audit"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 2, 2)]
  service_endpoints                              = ["Microsoft.EventHub"]
  enforce_private_link_endpoint_network_policies = true
}
