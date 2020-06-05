provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  prefix = var.prefix
  suffix = concat(["ss"], var.suffix)
}

module "network" {
  source                      = "${path.module}/network"
  virtual_network_cidr        = var.virtual_network_cidr
  use_existing_resource_group = var.use_existing_resource_group
  resource_group_name         = var.resource_group_name
  resource_group_location     = var.resource_group_location
  prefix                      = local.prefix
  suffix                      = local.suffix
}

module "audit_diagnostics" {
  source                                     = "git@github.com:Azure/terraform-azurerm-sec-audit-diagnostics-group"
  storage_account_private_endpoint_subnet_id = module.network.audit_subnet.id
  use_existing_resource_group                = var.use_existing_resource_group
  resource_group_name                        = var.resource_group_name
  resource_group_location                    = var.resource_group_location
  prefix                                     = local.prefix
  suffix                                     = local.suffix
}

module "security" {
  source                               = "git@github.com:Azure/terraform-azurerm-sec-security-group"
  key_vault_private_endpoint_subnet_id = module.network.secrets_subnet.id
  use_existing_resource_group          = var.use_existing_resource_group
  resource_group_name                  = var.resource_group_name
  resource_group_location              = var.resource_group_location
  prefix                               = local.prefix
  suffix                               = local.suffix
}

