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
}

resource "azurerm_subnet" "secrets_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "secrets"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 3, 1)]
  service_endpoints                              = ["Microsoft.KeyVault", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

module "secrets_nsg" {
  source                          = "git::https://github.com/Azure/terraform-azurerm-sec-network-security-group"
  resource_group_name             = var.resource_group.name
  associated_virtual_network_name = azurerm_virtual_network.virtual_network.name
  associated_subnet_name          = azurerm_subnet.secrets_subnet.name
  suffix                          = concat(var.suffix, ["sec"])
  security_rule_names             = []
  module_depends_on               = [time_sleep.until_subnets]
}

resource "azurerm_subnet" "audit_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "audit"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 3, 2)]
  service_endpoints                              = ["Microsoft.EventHub", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

module "audit_nsg" {
  source                          = "git::https://github.com/Azure/terraform-azurerm-sec-network-security-group"
  resource_group_name             = var.resource_group.name
  associated_virtual_network_name = azurerm_virtual_network.virtual_network.name
  associated_subnet_name          = azurerm_subnet.audit_subnet.name
  suffix                          = concat(var.suffix, ["aud"])
  security_rule_names             = []
  module_depends_on               = [time_sleep.until_subnets]
}

resource "azurerm_subnet" "data_subnet" {
  name                                           = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "data"])
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = [cidrsubnet(var.virtual_network_cidr, 3, 3)]
  service_endpoints                              = ["Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

module "data_nsg" {
  source                          = "git::https://github.com/Azure/terraform-azurerm-sec-network-security-group"
  resource_group_name             = var.resource_group.name
  associated_virtual_network_name = azurerm_virtual_network.virtual_network.name
  associated_subnet_name          = azurerm_subnet.data_subnet.name
  suffix                          = concat(var.suffix, ["dat"])
  security_rule_names             = []
  module_depends_on               = [time_sleep.until_subnets_2]
}

# <WORKAROUND>
# This work around is needed to allow asynchronous networking operations
# to complete after the resource has returned. These asynchronous operations
# can take an undefined amount of time so there's no guarentee these sleeps
# will always be sufficient. However, they should be suitable for the majority
# of executions. Additionally, there appears to be a limit on the number of 
# parallel operations that can successfully run against the vnet and so we 
# stage the subnet/nsg deployments.
#
# If you do hit an issue, please re-run.
# TODO: Consider using script to check for desired state rather than sleeps

resource "time_sleep" "until_subnets" {
  depends_on = [
    azurerm_subnet.secrets_subnet,
    azurerm_subnet.audit_subnet,
    azurerm_subnet.data_subnet,
  ]
  create_duration = "120s"
}

resource "time_sleep" "until_subnets_2" {
  depends_on = [
    time_sleep.until_subnets
  ]
  create_duration = "120s"
}

resource "time_sleep" "until_nsg_association" {
  # TODO: work out why depending on network_security_group_association doesn't work
  depends_on = [
    time_sleep.until_subnets_2,
    module.audit_nsg.network_security_groups,
    module.secrets_nsg.network_security_groups,
    module.data_nsg.network_security_groups
  ]
  create_duration = "240s"
}

resource "null_resource" "wait" {
  depends_on = [
    time_sleep.until_nsg_association
  ]
}
# </WORKAROUND>
