data "azurerm_resource_group" "virtual_network_resource_group" {
  name = var.virtual_network_resource_group_name
}

data "azurerm_virtual_network" "virtual_network" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}

data "azurerm_subnet" "private_build_agent_subnet" {
  name                 = "snet-priv-build"
  virtual_network_name = data.azurerm_virtual_network.virtual_network.name
  resource_group_name  = var.virtual_network_resource_group_name
}


