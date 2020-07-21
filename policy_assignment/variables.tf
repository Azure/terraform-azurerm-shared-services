#Required Variables
variable "target_resource_group" {
  type        = any
  description = "The resource group to which the policies will be applied."
}

variable "log_retention_days" {
  type        = string
  description = "The number of days to retain logs for."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The id of the Azure Log Analytics Workspace to persist logs to."
}

variable "log_storage_account_name" {
  type        = string
  description = "The name of the Azure Storage Account to persist logs to."
}
