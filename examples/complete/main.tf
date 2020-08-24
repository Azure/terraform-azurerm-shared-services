provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  unique_name_stub = substr(module.naming.unique-seed, 0, 3)
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}

resource "azurerm_resource_group" "workload" {
  name     = "${module.naming.resource_group.slug}-ss-complete-${local.unique_name_stub}"
  location = "uksouth"
}

resource "azurerm_virtual_network" "example_shared_vnet" {
  name                = "${module.naming.virtual_network.slug}-shared-${local.unique_name_stub}"
  resource_group_name = azurerm_resource_group.workload.name
  location            = azurerm_resource_group.workload.location
  address_space       = ["10.0.0.0/20"]
}

resource "azurerm_subnet" "example_build_subnet" {
  name                 = "${module.naming.subnet.slug}-priv-build"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.example_shared_vnet.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.example_shared_vnet.address_space[0], 4, 0)]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

resource "azurerm_virtual_network" "example_workload_vnet" {
  name                = "${module.naming.virtual_network.slug}-workload-${local.unique_name_stub}"
  resource_group_name = azurerm_resource_group.workload.name
  location            = azurerm_resource_group.workload.location
  address_space       = ["11.0.0.0/20"]
}

resource "azurerm_subnet" "example_workload_subnet" {
  name                 = "${module.naming.subnet.slug}-workload-${local.unique_name_stub}"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.example_workload_vnet.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.example_workload_vnet.address_space[0], 1, 0)]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

module "shared_services" {
  source                                              = "../../"
  shared_services_virtual_network_name                = azurerm_virtual_network.example_shared_vnet.name
  shared_services_virtual_network_resource_group_name = azurerm_resource_group.workload.name
  suffix                                              = [local.unique_name_stub]
  use_existing_resource_group                         = false
  resource_group_location                             = "uksouth"
  log_retention_duration                              = 365
  authorized_audit_client_ips                         = [data.external.test_client_ip.result.ip]
  authorized_audit_subnet_ids                         = [azurerm_subnet.example_workload_subnet.id]
  authorized_security_client_ips                      = [data.external.test_client_ip.result.ip]
  authorized_security_subnet_ids                      = [azurerm_subnet.example_workload_subnet.id]
  authorized_persistent_data_client_ips               = [data.external.test_client_ip.result.ip]
  #firewall_public_ip_sku                             = "Standard"
}


