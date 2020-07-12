provider "azurerm" {
  version = "~>2.13"
  features {}
}

locals {
  network_watcher_resource_group          = "NetworkWatcherRG"
  shared_service_network_watcher_location = var.shared_service_network_watcher_location
}

resource "azurerm_monitor_diagnostic_setting" "virtual_network_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = var.shared_service_virtual_network.id
  storage_account_id         = var.shared_service_diag_storage.id
  log_analytics_workspace_id = var.shared_service_diag_log_analytics.id

  log {
    category = "VMProtectionAlerts"
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

resource "azurerm_monitor_diagnostic_setting" "data_nsg_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = var.shared_service_data_nsg.id
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

resource "azurerm_monitor_diagnostic_setting" "audit_nsg_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = var.shared_service_audit_nsg.id
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

resource "azurerm_monitor_diagnostic_setting" "secrets_nsg_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = var.shared_service_secrets_nsg.id
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

resource "azurerm_network_watcher_flow_log" "network_flow_diagnostics" {
  for_each             = var.shared_service_subnet_nsg_ids
  network_watcher_name = data.azurerm_network_watcher.network_watcher.name
  resource_group_name  = local.network_watcher_resource_group

  network_security_group_id = each.value
  storage_account_id        = var.shared_service_diag_storage.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = var.shared_service_log_retention_duration
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.shared_service_diag_log_analytics.workspace_id
    workspace_region      = var.shared_service_diag_log_analytics.location
    workspace_resource_id = var.shared_service_diag_log_analytics.id
    interval_in_minutes   = 10
  }
}
