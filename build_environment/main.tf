##########################
# Inputs
##########################

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

##########################
# Backend Storage Account
##########################

resource "azurerm_resource_group" "backend" {
  name     = "backend-${var.environment_id}"
  location = var.location
}

resource "azurerm_storage_account" "backend" {
  name                     = var.environment_id
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "backend" {
  name                 = "terraform-tfstate"
  storage_account_name = azurerm_storage_account.backend.name
}

##########################
# Build Agent Pool
##########################

resource "azuredevops_agent_pool" "build" {
  name           = var.agent_pool
  auto_provision = true
}

##########################
# Build Agent
##########################

resource "azurerm_virtual_network" "build" {
  name                = "build-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.backend.location
  resource_group_name = azurerm_resource_group.backend.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.backend.name
  virtual_network_name = azurerm_virtual_network.build.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "build" {
  name                = "build-nic"
  location            = azurerm_resource_group.backend.location
  resource_group_name = azurerm_resource_group.backend.name

  ip_configuration {
    name                          = "build"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "build" {
  name                  = "${var.environment_id}-build-agent"
  location              = azurerm_resource_group.backend.location
  resource_group_name   = azurerm_resource_group.backend.name
  network_interface_ids = [azurerm_network_interface.build.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name   = "${var.environment_id}-build-agent"
    admin_username  = "buildadmin"
    admin_password  = "Kubla1Khan;"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  depends_on        = [ azuredevops_agent_pool.build ]
}

######################################
# Build Agent Installer
######################################

resource "azurerm_virtual_machine_extension" "build" {
  name                 = "buildagent"
  virtual_machine_id   = azurerm_virtual_machine.build.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SCRIPT
    {
        "script": "${base64encode(templatefile("${path.module}/agent_installer.sh", {
          ORG="${var.org}",
          PAT="${var.pat_token}",
          NAME=azurerm_virtual_machine.build.name,
          POOL="${var.agent_pool}"
        }))}"
    }
SCRIPT

  tags = {
    environment = "Build"
  }
}

###############################
# ACR
###############################

data "azuredevops_project" "devops_project" {
  project_name          = var.project
}

resource "azurerm_container_registry" "build" {
  name                     = "ACR${var.environment_id}"
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = azurerm_resource_group.backend.location
  sku                      = "Basic"
  admin_enabled            = false
}


###############################
# Outputs
###############################

output "build_subnet_id" {
  value = azurerm_virtual_network.build.id
}
