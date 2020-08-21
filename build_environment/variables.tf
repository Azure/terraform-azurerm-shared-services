variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network to use for the build environment."
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "The name of the resource group containing the virtual network to use for the build environment."
}

variable "environment_id" {
  type        = string
  description = "The globally unique root identifier for this set of resources."
}

variable "location" {
  type        = string
  description = "The Azure region into which these resources will be deployed e.g. 'uksouth'."
}

variable "org" {
  type        = string
  description = "The name of the devops org into which the build agent will be installed e.g. https://dev.azure.com/myDevOrg"
}

variable "project" {
  type        = string
  description = "The name of the pre-existing ADO project to which the build agent will be attached"
}

variable "pat_token" {
  type        = string
  description = "PAT token with 'Owner' level access. Create this token via https://dev.azure.com/<ORG>/_usersSettings/tokens"
}

variable "agent_pool" {
  type        = string
  description = "Name of an agent pool that will be created within the ADO project"
  default     = "SharedServices"
}

