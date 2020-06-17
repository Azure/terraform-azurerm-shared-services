#Required Variables
variable "virtual_network_cidr" {
  type        = string
  description = "A string CIDR address space for the Shared Services virtual network to be deployed to."
}

#Optional Variables
variable "suffix" {
  type        = list(string)
  description = "A naming suffix to be used in the creation of unique names for Azure resources."
  default     = []
}

variable "use_existing_resource_group" {
  type        = string
  description = "Boolean flag to determine whether or not to deploy services to an existing Azure Resource Group. When false specify a resource_group_location, when true specify the resource_group_name."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of an existing Resource Group to deploy the shared services networking services into."
  default     = ""
}

variable "resource_group_location" {
  type        = string
  description = "The location to create the Shared Services Resources."
  default     = ""
}

variable "log_retention_duration" {
  type        = number
  description = "The duration in days to retain any logs created by the Shared Services. Note: Deleting the Shared Services in its entirety will delete any captured logs. This parameter allows you to control log retention within the lifecycle of the Shared Services."
  default     = "30"
}

variable "authorised_audit_client_ips" {
  type        = list(string)
  description = "A list of IP addresses of the clients or endpoints athorised to directly access the Shared Servicess audit logs."
  default     = []
}

variable "authorised_audit_subnet_ids" {
  type        = list(string)
  description = "A list of Azure Subnet ids of the subnets that are allowed to directly access the Shared Servicess audit subnet."
  default     = []
}

variable "authorised_persistent_data_client_ips" {
  type        = list(string)
  description = "A list of IP addresses of the clients or endpoints athorised to directly access the Shared Servicess persistent data store."
  default     = []
}

variable "authorised_persistent_data_subnet_ids" {
  type        = list(string)
  description = "A list of Azure Subnet ids of the subnets that are allowed to directly access the Shared Servicess persistent data subnet."
  default     = []
}

variable "authorised_security_client_ips" {
  type        = list(string)
  description = "A list of IP addresses of the clients or endpoints athorised to directly access the Shared Servicess KeyVault."
  default     = []
}

variable "authorised_security_subnet_ids" {
  type        = list(string)
  description = "A list of Azure Subnet ids of the subnets that are allowed to directly access the Shared Servicess security subnet."
  default     = []
}

variable "firewall_public_ip_sku" {
  type        = string 
  description = "The pricing and performance sku to create the Azure Firewalls public IP address to."
  default     = "Standard"
}






