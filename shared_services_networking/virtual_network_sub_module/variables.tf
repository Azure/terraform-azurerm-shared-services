#Required Variables
variable "virtual_network_cidr" {
  type        = string
  description = "A string CIDR address to create the Virtual Network to."
}

variable "resource_group" {
  type = any
  description = "The Resource Group object which the Shared Services Virtual Network will be provisioned to."
}

#Optional Variables
variable "suffix" {
  type        = list(string)
  description = "A naming suffix to be used in the creation of unique names for Azure resources."
  default     = []
}


