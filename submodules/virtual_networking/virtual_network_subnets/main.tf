provider "azurerm" {
  features {}
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = var.suffix
}

module "network_security_group_rules" {
  source = "git::https://github.com/Azure/terraform-azurerm-sec-network-security-group-rules"
}

///////////////////////////////////
// Secrets Subnet
///////////////////////////////////

module "secrets_subnet_naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = var.suffix
}

resource "azurerm_subnet" "secrets_subnet" {
  name                                           = join(module.secrets_subnet_naming.subnet.dashes ? "-" : "", [module.secrets_subnet_naming.subnet.name, "secrets"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr[0], 4, 1)]
  service_endpoints                              = ["Microsoft.KeyVault", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "secrets_nsg" {
  name                = module.secrets_subnet_naming.network_security_group.name_unique
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "secrets_nsg_asso" {
  subnet_id                 = azurerm_subnet.secrets_subnet.id
  network_security_group_id = azurerm_network_security_group.secrets_nsg.id
}

///////////////////////////////////
// Audit Subnet
///////////////////////////////////

module "audit_subnet_naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = var.suffix
}

resource "azurerm_subnet" "audit_subnet" {
  name                                           = join(module.audit_subnet_naming.subnet.dashes ? "-" : "", [module.audit_subnet_naming.subnet.name, "audit"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr[0], 4, 2)]
  service_endpoints                              = ["Microsoft.EventHub", "Microsoft.Storage", "Microsoft.KeyVault"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "audit_nsg" {
  name                = module.audit_subnet_naming.network_security_group.name_unique
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "audit_nsg_asso" {
  subnet_id                 = azurerm_subnet.audit_subnet.id
  network_security_group_id = azurerm_network_security_group.audit_nsg.id
}

///////////////////////////////////
// Data Lake Subnet
///////////////////////////////////

module "data_subnet_naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = var.suffix
}

resource "azurerm_subnet" "data_subnet" {
  name                                           = join(module.data_subnet_naming.subnet.dashes ? "-" : "", [module.data_subnet_naming.subnet.name, "data"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr[0], 4, 3)]
  service_endpoints                              = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.AzureActiveDirectory"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "data_nsg" {
  name                = module.data_subnet_naming.network_security_group.name_unique
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "data_nsg_asso" {
  subnet_id                 = azurerm_subnet.data_subnet.id
  network_security_group_id = azurerm_network_security_group.data_nsg.id
}

///////////////////////////////////
// Firewall Subnet
///////////////////////////////////

/* resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr[0], 4, 4)]
  service_endpoints    = ["Microsoft.Storage"]
} */
