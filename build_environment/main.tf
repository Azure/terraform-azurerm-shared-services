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

resource "azurerm_subnet" "build" {
  name                 = "internal"
  resource_group_name  = var.virtual_network_resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_network_interface" "build" {
  name                = "build-nic"
  location            = azurerm_resource_group.backend.location
  resource_group_name = azurerm_resource_group.backend.name

  ip_configuration {
    name                          = "build"
    subnet_id                     = azurerm_subnet.build.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "build" {
  name                  = "${var.environment_id}-build-agent"
  location              = azurerm_resource_group.backend.location
  resource_group_name   = azurerm_resource_group.backend.name
  network_interface_ids = [azurerm_network_interface.build.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
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
    computer_name  = "${var.environment_id}-build-agent"
    admin_username = "buildadmin"
    admin_password = "Kubla1Khan;"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  depends_on = [azuredevops_agent_pool.build]
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
  ORG  = "${var.org}",
  PAT  = "${var.pat_token}",
  NAME = azurerm_virtual_machine.build.name,
  POOL = "${var.agent_pool}"
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

resource "azurerm_container_registry" "build" {
  name                = "ACR${var.environment_id}"
  resource_group_name = azurerm_resource_group.backend.name
  location            = azurerm_resource_group.backend.location
  sku                 = "Basic"
  admin_enabled       = false

  provisioner "local-exec" {
    command     = "./create_acr_connection.sh"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "./destroy_acr_connection.sh"
    working_dir = path.module
  }
}

