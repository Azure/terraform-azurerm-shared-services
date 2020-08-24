provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  unique_name_stub  = substr(module.naming.unique-seed, 0, 3)
  retention_in_days = 30
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}

resource "azurerm_resource_group" "example_rg" {
  name     = "${module.naming.resource_group.slug}-pol-max-test-${local.unique_name_stub}"
  location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "example_law" {
  name                = module.naming.log_analytics_workspace.name_unique
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = local.retention_in_days
}

resource "azurerm_storage_account" "example_sa" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "policy_assignment" {
  source                     = "../"
  target_resource_group_name = azurerm_resource_group.example_rg.name
  log_retention_days         = "30"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example_law.id
  log_storage_account_name   = azurerm_storage_account.example_sa.name
}
