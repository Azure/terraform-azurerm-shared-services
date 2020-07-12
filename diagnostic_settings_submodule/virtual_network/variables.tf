variable "shared_service_network_watcher_location" {
  type = string
}

variable "shared_service_virtual_network" {
  type = any
}

variable "shared_service_subnet_nsg_ids" {
  type = map
}

variable "shared_service_data_nsg" {
  type = any
}

variable "shared_service_audit_nsg" {
  type = any
}

variable "shared_service_secrets_nsg" {
  type = any
}

variable "shared_service_firewall" {
  type = any
}

variable "shared_service_diag_storage" {
  type = any
}

variable "shared_service_diag_log_analytics" {
  type = any
}

variable "shared_service_log_retention_duration" {
  type = number
}

variable "module_depends_on" {
  default = [""]
}
