data "azurerm_resources" "dev_container_registry" {
  resource_group_name = local.build_agent_resource_group_name
  type                = "Microsoft.ContainerRegistry"
}

data "azurerm_resources" "dev_storage_account" {
  resource_group_name = local.build_agent_resource_group_name
  type                = "Microsoft.Storage"
}

data "azurerm_resources" "dev_network_secruity_group" {
  resource_group_name = local.network_resource_group_name
  type                = "Microsoft.Network/networkSecurityGroups"
}
