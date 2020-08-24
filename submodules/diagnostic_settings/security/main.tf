provider "azurerm" {
  version = "~>2.13"
  features {}
}

resource "azurerm_monitor_diagnostic_setting" "key_vault_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = var.shared_service_key_vault.id
  storage_account_id         = var.shared_service_diag_storage.id
  log_analytics_workspace_id = var.shared_service_diag_log_analytics.id

  log {
    category = "AuditEvent"
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
