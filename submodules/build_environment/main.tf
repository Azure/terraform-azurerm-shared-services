locals {
  suffix = concat(["dev", "ss"], var.suffix)
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  suffix = local.suffix
}

locals {
  cis_policy_display_name      = "CIS Microsoft Azure Foundations Benchmark 1.1.0"
  official_policy_display_name = "UK OFFICIAL and UK NHS"
}

##########################
# Backend Resource Group
##########################

resource "azurerm_resource_group" "backend" {
  name     = "${module.naming.resource_group.slug}-${join("-", local.suffix)}"
  location = var.resource_group_location
}

resource "azurerm_policy_assignment" "cis_assignment" {
  name                 = local.cis_policy_display_name
  scope                = azurerm_resource_group.backend.id
  policy_definition_id = data.azurerm_policy_set_definition.cis_set_definition.id
  description          = data.azurerm_policy_set_definition.cis_set_definition.description
  display_name         = local.cis_policy_display_name
}

resource "azurerm_policy_assignment" "official_assignment" {
  name                 = local.official_policy_display_name
  scope                = azurerm_resource_group.backend.id
  policy_definition_id = data.azurerm_policy_set_definition.official_set_definition.id
  description          = data.azurerm_policy_set_definition.official_set_definition.description
  display_name         = local.official_policy_display_name
  location             = azurerm_resource_group.backend.location

  #Specifying a system assigned identity here due to this policy having create if not exists effect policies. 
  identity {
    type = "SystemAssigned"
  }
}

##########################
# Backend Networking
##########################

resource "azurerm_subnet" "build" {
  name                 = join(module.naming.subnet.dashes ? "-" : "", [module.naming.subnet.slug, "dev", local.suffix])
  resource_group_name  = var.virtual_network_resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 4, 0)]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_network_security_group" "build_nsg" {
  name                = join(module.naming.network_security_group.dashes ? "-" : "", [module.naming.network_security_group.slug, "dev", local.suffix])
  location            = azurerm_resource_group.backend.location
  resource_group_name = var.virtual_network_resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "build_nsg_asso" {
  subnet_id                 = azurerm_subnet.build.id
  network_security_group_id = azurerm_network_security_group.build_nsg.id
}

##########################
# Backend Storage Account
##########################

resource "azurerm_storage_account" "backend_state" {
  name                      = join("", concat(["sadevss"], var.suffix))
  resource_group_name       = azurerm_resource_group.backend.name
  location                  = azurerm_resource_group.backend.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = false
}

resource "azurerm_storage_container" "backend_state_container" {
  name                  = "terraform-tfstate"
  storage_account_name  = azurerm_storage_account.backend_state.name
  container_access_type = "private"
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
  name                = "${module.naming.network_interface.slug}-${join("-", local.suffix)}"
  location            = azurerm_resource_group.backend.location
  resource_group_name = azurerm_resource_group.backend.name

  ip_configuration {
    name                          = "${module.naming.network_interface.slug}-${join("-", local.suffix)}"
    subnet_id                     = azurerm_subnet.build.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "build_agent" {
  name                  = "${module.naming.virtual_machine.slug}-${join("-", local.suffix)}"
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
    name              = "osdisk-${join("-", local.suffix)}"
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
        "script": "${base64encode(templatefile("${path.module}/agent_installer.sh", {
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
  name                = "${module.naming.container_registry.slug}${join("", local.suffix)}"
  resource_group_name = azurerm_resource_group.backend.name
  location            = azurerm_resource_group.backend.location
  sku                 = "Basic"
  admin_enabled       = false

  /* There is an approach to automatically creating the Docker Registery Service Connection however currently 
  this doesnt grant permission to all pipelines. Commenting this out to avoid the creation of a broken service 
  connection 

  provisioner "local-exec" {
    command     = "./create_acr_connection.sh"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "./destroy_acr_connection.sh"
    working_dir = path.module
  }
  */
}

