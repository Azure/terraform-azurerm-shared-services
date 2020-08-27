provider "azurerm" {
  features {}
}

locals {
  suffix               = join("-", var.suffix)
  virtual_network_cidr = data.azurerm_virtual_network.virtual_network.address_space
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

resource "azurerm_subnet" "secrets_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.slug, "secrets", local.suffix])
  resource_group_name                            = var.virtual_network_resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = [cidrsubnet(local.virtual_network_cidr[0], 4, 1)]
  service_endpoints                              = ["Microsoft.KeyVault", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "secrets_nsg" {
  name                = join(module.naming.network_security_group.dashes ? "-" : "", [module.naming.network_security_group.slug, "secrets", local.suffix])
  location            = var.virtual_network_resource_group_location
  resource_group_name = var.virtual_network_resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "secrets_nsg_asso" {
  subnet_id                 = azurerm_subnet.secrets_subnet.id
  network_security_group_id = azurerm_network_security_group.secrets_nsg.id
}

///////////////////////////////////
// Audit Subnet
///////////////////////////////////

resource "azurerm_subnet" "audit_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.slug, "audit", local.suffix])
  resource_group_name                            = var.virtual_network_resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = [cidrsubnet(local.virtual_network_cidr[0], 4, 2)]
  service_endpoints                              = ["Microsoft.EventHub", "Microsoft.Storage", "Microsoft.KeyVault"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "audit_nsg" {
  name                = join(module.naming.network_security_group.dashes ? "-" : "", [module.naming.network_security_group.slug, "audit", local.suffix])
  location            = var.virtual_network_resource_group_location
  resource_group_name = var.virtual_network_resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "audit_nsg_asso" {
  subnet_id                 = azurerm_subnet.audit_subnet.id
  network_security_group_id = azurerm_network_security_group.audit_nsg.id
}

///////////////////////////////////
// Data Lake Subnet
///////////////////////////////////

resource "azurerm_subnet" "data_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.slug, "data", local.suffix])
  resource_group_name                            = var.virtual_network_resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = [cidrsubnet(local.virtual_network_cidr[0], 4, 3)]
  service_endpoints                              = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.AzureActiveDirectory"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "data_nsg" {
  name                = join(module.naming.network_security_group.dashes ? "-" : "", [module.naming.network_security_group.slug, "data", local.suffix])
  location            = var.virtual_network_resource_group_location
  resource_group_name = var.virtual_network_resource_group_name
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
  resource_group_name  = var.virtual_network_resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(local.virtual_network_cidr[0], 4, 4)]
  service_endpoints    = ["Microsoft.Storage"]
} */

#NOTE: An Azure Firewall has an associated monthly cost irrespective of whether or not it is being actively used. Current usecase does not require the firewall
# to be in place.  

/* module "firewall" {
  source             = "git::https://github.com/Azure/terraform-azurerm-sec-firewall"
  virtual_network    = data.azurerm_virtual_network.virtual_network
  firewall_subnet_id = azurerm_subnet.firewall_subnet.id
  suffix             = local.suffix
  public_ip_sku      = var.firewall_public_ip_sku
} */
