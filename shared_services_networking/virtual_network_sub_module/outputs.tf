output "resource_group" {
  value = var.resource_group
}

/* output "firewall_subnet" {
  value = azurerm_subnet.firewall_subnet
} */

output "secrets_subnet" {
  value = azurerm_subnet.secrets_subnet
}

output "secrets_subnet_network_security_group" {
  value = azurerm_network_security_group.secrets_nsg
}

output "audit_subnet" {
  value = azurerm_subnet.audit_subnet
}

output "audit_subnet_network_security_group" {
  value = azurerm_network_security_group.audit_nsg
}

output "data_subnet" {
  value = azurerm_subnet.data_subnet
}

output "data_subnet_network_security_group" {
  value = azurerm_network_security_group.data_nsg
}

output "virtual_network" {
  value = azurerm_virtual_network.virtual_network
  depends_on = [
    #azurerm_subnet.firewall_subnet,
    azurerm_subnet.secrets_subnet,
    azurerm_subnet.audit_subnet,
    azurerm_subnet.data_subnet
  ]
}
