output "firewall_subnet" {
  value = azurerm_subnet.firewall_subnet
}

output "secrets_subnet" {
  value = azurerm_subnet.secrets_subnet
}

output "secrets_subnet_network_security_group" {
  value = module.secrets_nsg.network_security_groups
}

output "audit_subnet" {
  value = azurerm_subnet.audit_subnet
}

output "audit_subnet_network_security_group" {
  value = module.audit_nsg.network_security_groups
}

output "data_subnet" {
  value = azurerm_subnet.data_subnet
}

output "data_subnet_network_security_group" {
  value = module.data_nsg.network_security_groups
}

output "virtual_network" {
  value = azurerm_virtual_network.virtual_network
  depends_on = [
    azurerm_subnet.firewall_subnet,
    azurerm_subnet.secrets_subnet,
    azurerm_subnet.audit_subnet,
    azurerm_subnet.data_subnet
  ]
}