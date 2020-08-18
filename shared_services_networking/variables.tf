#Required Variables
variable "virtual_network_cidr" {
  type        = string
  description = "A string CIDR address to create the Virtual Network to."
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
  description = "The location to create the Shared Services Network Azure Resources."
  default     = ""
}

/* variable "firewall_public_ip_sku" {
  type        = string
  description = "The pricing and performance sku to create the Azure Firewalls public IP address to."
  default     = "Standard"
} */



