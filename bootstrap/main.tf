###############################################################
# Inputs
###############################################################

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

##############################################################

provider "azurerm" {
  version = "~>2.0"
  features {}
}

provider "azuredevops" {
  version               = ">= 0.0.1"
  org_service_url       = var.devops_org
  personal_access_token = var.devops_pat_token
}

###############################################################

module "backend" {
  source         = "../build_environment"
  org            = var.devops_org
  project        = var.devops_project
  pat_token      = var.devops_pat_token
  environment_id = var.environment_id
  location       = var.location
}
