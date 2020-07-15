provider "azurerm" {
  version = "~>2.13"
  features {}
}

resource "azurerm_monitor_diagnostic_setting" "eventhub_namespace_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = var.shared_service_eventhub_namespace.id
  storage_account_id         = var.shared_service_diag_storage.id
  log_analytics_workspace_id = var.shared_service_diag_log_analytics.id

  log {
    category = "ArchiveLogs"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "OperationalLogs"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "AutoScaleLogs"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "KafkaCoordinatorLogs"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "KafkaUserErrorLogs"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "EventHubVNetConnectionEvent"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "CustomerManagedKeyUserLogs"
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

resource "azurerm_monitor_diagnostic_setting" "automation_account_diagnostic_setting" {
  name                       = "setByPolicy"
  target_resource_id         = var.shared_service_automation_account.id
  storage_account_id         = var.shared_service_diag_storage.id
  log_analytics_workspace_id = var.shared_service_diag_log_analytics.id

  log {
    category = "JobLogs"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "JobStreams"
    enabled  = true

    retention_policy {
      days    = var.shared_service_log_retention_duration
      enabled = true
    }
  }

  log {
    category = "DscNodeStatus"
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

