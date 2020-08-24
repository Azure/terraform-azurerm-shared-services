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

/* output "firewall_subnet" {
  value = azurerm_subnet.firewall_subnet
} */
