provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  cis_policy_display_name       = "CIS Microsoft Azure Foundations Benchmark 1.1.0"
  official_policy_display_name  = "UK OFFICIAL and UK NHS"
  auto_diagnostics_display_name = "Auto Diagnostics Policy Initiative"
}

resource "azurerm_policy_assignment" "cis_assignment" {
  name                 = local.cis_policy_display_name
  scope                = var.target_resource_group.id
  policy_definition_id = data.azurerm_policy_set_definition.cis_set_definition.id
  description          = data.azurerm_policy_set_definition.cis_set_definition.description
  display_name         = local.cis_policy_display_name
}

resource "azurerm_policy_assignment" "official_assignment" {
  name                 = local.official_policy_display_name
  scope                = var.target_resource_group.id
  policy_definition_id = data.azurerm_policy_set_definition.official_set_definition.id
  description          = data.azurerm_policy_set_definition.official_set_definition.description
  display_name         = local.official_policy_display_name
  location             = var.target_resource_group.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_policy_assignment" "diagnostics_assignment" {
  name                 = local.auto_diagnostics_display_name
  scope                = var.target_resource_group.id
  policy_definition_id = data.azurerm_policy_set_definition.auto_diagnostics_set_definition.id
  description          = data.azurerm_policy_set_definition.auto_diagnostics_set_definition.description
  display_name         = local.auto_diagnostics_display_name
  location             = var.target_resource_group.location

  identity {
    type = "SystemAssigned"
  }

  parameters = <<PARAMETERS
    {
        "requiredRetentionDays": {
            "value": "${var.log_retention_days}"
        },
        "workspaceId": {
            "value": "${var.log_analytics_workspace_id}"
        },
        "storageAccountName": {
            "value" : "${var.log_storage_account_name}"
        },
        "resourceLocation": {
            "value" : "${var.target_resource_group.location}"
        }
    }
PARAMETERS
}
