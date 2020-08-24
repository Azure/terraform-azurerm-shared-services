data "azurerm_network_watcher" "network_watcher" {
  name                = "NetworkWatcher_${local.shared_service_network_watcher_location}"
  resource_group_name = local.network_watcher_resource_group
}
