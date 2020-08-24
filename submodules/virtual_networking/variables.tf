#Required Variables
variable "virtual_network_name" {
  type        = string
  description = "The name of the bootstrapped Shared Services virtual network to use."
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "The name of the bootstrapped Azure Resource Group that the Shared Services virtual network has been deployed to."
}

#Optional Variables
variable "suffix" {
  type        = list(string)
  description = "A naming suffix to be used in the creation of unique names for Azure resources."
  default     = []
}

/* variable "firewall_public_ip_sku" {
  type        = string
  description = "The pricing and performance sku to create the Azure Firewalls public IP address to."
  default     = "Standard"
} */



