variable "shared_service_diag_storage" {
  type = any
}

variable "shared_service_diag_log_analytics" {
  type = any
}

variable "shared_service_eventhub_namespace" {
  type = any
}

variable "shared_service_automation_account" {
  type = any
}

variable "shared_service_log_retention_duration" {
  type = number
}

variable "module_depends_on" {
  default = [""]
}
