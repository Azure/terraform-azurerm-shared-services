locals {
  suffix = concat(["ss"], var.suffix)
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = local.suffix
}

##########################
# Backend Resource Group
##########################


resource "azurerm_resource_group" "backend" {
  name     = "${module.naming.resource_group.slug}-priv-build-${join("-", local.suffix)}"
  location = var.resource_group_location
}

##########################
# Backend Networking
##########################

resource "azurerm_subnet" "build" {
  name                 = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.name, "private", "build"])
  resource_group_name  = var.virtual_network_resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 4, 0)]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_network_security_group" "secrets_nsg" {
  name                = module.naming.network_security_group.name_unique
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "secrets_nsg_asso" {
  subnet_id                 = azurerm_subnet.secrets_subnet.id
  network_security_group_id = azurerm_network_security_group.secrets_nsg.id
}

##########################
# Backend Storage Account
##########################

module "backend_state" {
  source                           = "git::https://github.com/Azure/terraform-azurerm-sec-storage-account"
  resource_group_name              = azurerm_resource_group.backend.name
  resource_group_location          = azurerm_resource_group.backend.location
  storage_account_name             = join("", ["state", module.naming.storage_account.name_unique])
  storage_account_tier             = "Standard"
  storage_account_replication_type = "LRS"
  bypass_internal_network_rules    = true
}

resource "azurerm_storage_container" "backend_state_container" {
  name                 = "terraform-tfstate"
  storage_account_name = module.backend_state.name
}

##########################
# Build Agent Pool
##########################

resource "azuredevops_agent_pool" "build_agent_pool" {
  name           = var.azure_devops_agent_pool
  auto_provision = true
}

##########################
# Build Agent
##########################

resource "azurerm_network_interface" "build_agent_nic" {
  name                = "${module.naming.network_interface.slug}-build-agent-${join("-", local.suffix)}"
  location            = azurerm_resource_group.backend.location
  resource_group_name = azurerm_resource_group.backend.name

  ip_configuration {
    name                          = "${module.naming.network_interface.slug}-build-agent-${join("-", local.suffix)}"
    subnet_id                     = azurerm_subnet.build.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "build_agent" {
  name                  = "${module.naming.virtual_machine.slug}-build-agent-${join("-", local.suffix)}"
  location              = azurerm_resource_group.backend.location
  resource_group_name   = azurerm_resource_group.backend.name
  network_interface_ids = [azurerm_network_interface.build_agent_nic.id]
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
    computer_name  = "${module.naming.virtual_machine.slug}-build-agent-${join("-", local.suffix)}"
    admin_username = var.build_agent_admin_username
    admin_password = var.build_agent_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  depends_on = [azuredevops_agent_pool.build_agent_pool]
}

######################################
# Build Agent Installer
######################################

resource "azurerm_virtual_machine_extension" "build_agent_extension" {
  name                 = "buildagent"
  virtual_machine_id   = azurerm_virtual_machine.build_agent.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SCRIPT
    {
        "script": "${base64encode(templatefile("${path.module}/scripts/agent_installer.sh", {
  ORG  = "${var.azure_devops_organisation}",
  PAT  = "${var.azure_devops_pat}",
  NAME = azurerm_virtual_machine.build_agent.name,
  POOL = "${var.azure_devops_agent_pool}"
}))}"
    }
SCRIPT

tags = {
  environment = "Build"
}
}

###########################################
# Development Container Container Registry
###########################################

resource "azurerm_container_registry" "devcontainer_container_registry" {
  name                = "${module.naming.container_registry.slug}-dev-cont-${join("-", local.suffix)}"
  resource_group_name = azurerm_resource_group.backend.name
  location            = azurerm_resource_group.backend.location
  sku                 = "Basic"
  admin_enabled       = false

  provisioner "local-exec" {
    command     = "./scripts/create_acr_connection.sh"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "./scripts/destroy_acr_connection.sh"
    working_dir = path.module
  }
}

