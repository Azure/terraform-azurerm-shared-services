provider "azurerm" {
  version = "~>2.13"
  features {}
}

locals {
  suffix                          = join("", var.suffix)
  build_agent_resource_group_name = "rg-dev-${local.suffix}"
  network_resource_group_name     = "rg-net-${local.suffix}"
}

resource "azurerm_monitor_diagnostic_setting" "container_registry_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = data.azurerm_resources.dev_container_registry.resources[0].id
  storage_account_id         = var.shared_service_diag_storage.id
  log_analytics_workspace_id = var.shared_service_diag_log_analytics.id

  log {
    category = "ContainerRegistryRepositoryEvents"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "ContainerRegistryLoginEvents"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "dev_nsg_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = data.azurerm_resources.dev_network_secruity_group.resources[0].id
  storage_account_id         = var.shared_service_diag_storage.id
  log_analytics_workspace_id = var.shared_service_diag_log_analytics.id

  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }
}

resource "azurerm_storage_account_network_rules" "dev_storage_account" {
  resource_group_name  = local.build_agent_resource_group_name
  storage_account_name = data.azurerm_resources.dev_storage_account.resources[0].name
  default_action       = "Deny"
  bypass               = ["Logging", "Metrics", "AzureServices"]
}
