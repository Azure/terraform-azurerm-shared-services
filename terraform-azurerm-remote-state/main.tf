#############################################################################
# Inspired by https://github.com/ned1313/Implementing-Terraform-on-Microsoft-Azure
#############################################################################

#############################################################################
# VARIABLES
#############################################################################

variable "environment_id" {
  type        = string
  description = "The globally unique root identifier for this set of resources."
}

variable "location" {
  type    = string
  description = "The Azure region into which these resources will be deployed e.g. 'uksouth'."
}

##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {
  version = "~> 2.10"
  features {}
}

##################################################################################
# RESOURCES
##################################################################################

resource "azurerm_resource_group" "setup" {
  name     = "be-${var.environment_id}"
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.environment_id
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-tfstate"
  storage_account_name = azurerm_storage_account.sa.name
}

##################################################################################
# OUTPUT
##################################################################################

output "resource_group_name" {
  value = azurerm_resource_group.setup.name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_container_name" {
  value = azurerm_storage_container.ct.name
}
