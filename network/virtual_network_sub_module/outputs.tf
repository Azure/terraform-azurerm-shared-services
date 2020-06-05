output "firewall_subnet" {
  value = azurerm_subnet.firewall_subnet
}

output "secrets_subnet" {
  value = azurerm_subnet.secrets_subnet
}

output "audit_subnet" {
  value = azurerm_subnet.audit_subnet
}

output "virtual_network" {
  value = azurerm_virtual_network.virtual_network
  depends_on = [
    azurerm_subnet.firewall_subnet,
    azurerm_subnet.secrets_subnet,
    azurerm_subnet.audit_subnet
  ]
}



