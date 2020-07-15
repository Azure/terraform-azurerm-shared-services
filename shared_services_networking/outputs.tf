output "resource_group" {
  value = data.azurerm_resource_group.current
}

output "virtual_network" {
  value = module.virtual_network.virtual_network
}

output "firewall" {
  value = module.firewall
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

output "data_subnet_network_security_group" {
  value = module.virtual_network.data_subnet_network_security_group
}

output "secrets_subnet_network_security_group" {
  value = module.virtual_network.secrets_subnet_network_security_group
}

output "audit_subnet_network_security_group" {
  value = module.virtual_network.audit_subnet_network_security_group
}

output "nsg_ids" {
  value = {
    "data_nsg"    = module.virtual_network.data_subnet_network_security_group.id
    "secrets_nsg" = module.virtual_network.secrets_subnet_network_security_group.id
    "audit_nsg"   = module.virtual_network.audit_subnet_network_security_group.id
  }
}
