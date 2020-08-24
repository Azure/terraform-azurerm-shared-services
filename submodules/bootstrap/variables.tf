#Required Variables
variable "environment_id" {
  type        = string
  description = "The globally unique root identifier for this set of resources."
}

variable "location" {
  type        = string
  description = "The Azure region into which these resources will be deployed e.g. 'uksouth'."
}

variable "devops_org" {
  type        = string
  description = "The name of the devops org into which the build agent will be installed e.g. https://dev.azure.com/myDevOrg"
}

variable "devops_project" {
  type        = string
  description = "The name of the pre-existing ADO project to which the build agent will be attached"
}

variable "devops_pat_token" {
  type        = string
  description = "PAT token with 'Owner' level access. Create this token via https://dev.azure.com/<ORG>/_usersSettings/tokens"
}

variable "virtual_network_cidr" {
  type        = string
  description = "A string CIDR address space for the Shared Services virtual network to be deployed to."
}

#Optional Variables
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

variable "suffix" {
  type        = list(string)
  description = "A naming suffix to be used in the creation of unique names for Azure resources."
  default     = []
}
