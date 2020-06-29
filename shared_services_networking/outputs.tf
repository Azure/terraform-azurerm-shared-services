output "resource_group" {
  value = data.azurerm_resource_group.current
}

output "virtual_network" {
  value = module.virtual_network.virtual_network
}

output "firewall_subnet" {
  value = module.virtual_network.firewall_subnet
}

output "secrets_subnet" {
  value = module.virtual_network.secrets_subnet
}

output "audit_subnet" {
  value = module.virtual_network.audit_subnet
}

output "data_subnet" {
  value = module.virtual_network.data_subnet
}


