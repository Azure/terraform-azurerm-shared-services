provider "azurerm" {
  features {}
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = var.suffix
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
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 3, 0)]
  service_endpoints    = ["Microsoft.Storage"]
  depends_on           = [azurerm_virtual_network.virtual_network]
}

resource "azurerm_subnet" "secrets_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "secrets"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 3, 1)]
  service_endpoints                              = ["Microsoft.KeyVault", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
  depends_on                                     = [azurerm_subnet.firewall_subnet]
}

resource "azurerm_subnet" "audit_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "audit"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 3, 2)]
  service_endpoints                              = ["Microsoft.EventHub", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
  depends_on                                     = [azurerm_subnet.secrets_subnet]
}

resource "azurerm_subnet" "data_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "data"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 3, 3)]
  service_endpoints                              = ["Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
  depends_on                                     = [azurerm_subnet.audit_subnet]
}

module "secrets_nsg" {
  source                          = "git::https://github.com/Azure/terraform-azurerm-sec-network-security-group"
  resource_group_name             = var.resource_group.name
  associated_virtual_network_name = azurerm_virtual_network.virtual_network.name
  associated_subnet_name          = azurerm_subnet.secrets_subnet.name
  suffix                          = concat(var.suffix, ["sec"])
  security_rule_names             = []
  module_depends_on               = [azurerm_subnet.data_subnet]
}

module "audit_nsg" {
  source                          = "git::https://github.com/Azure/terraform-azurerm-sec-network-security-group"
  resource_group_name             = var.resource_group.name
  associated_virtual_network_name = azurerm_virtual_network.virtual_network.name
  associated_subnet_name          = azurerm_subnet.audit_subnet.name
  suffix                          = concat(var.suffix, ["aud"])
  security_rule_names             = []
  module_depends_on               = [module.secrets_nsg]
}

module "data_nsg" {
  source                          = "git::https://github.com/Azure/terraform-azurerm-sec-network-security-group"
  resource_group_name             = var.resource_group.name
  associated_virtual_network_name = azurerm_virtual_network.virtual_network.name
  associated_subnet_name          = azurerm_subnet.data_subnet.name
  suffix                          = concat(var.suffix, ["dat"])
  security_rule_names             = []
  module_depends_on               = [module.audit_nsg]
}
