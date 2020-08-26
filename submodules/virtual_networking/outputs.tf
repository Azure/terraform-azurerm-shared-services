output "resource_group" {
  value = data.azurerm_resource_group.virtual_network_resource_group
}

output "virtual_network" {
  value = data.azurerm_virtual_network.virtual_network
}

output "private_build_agent_subnet" {
  value = data.azurerm_subnet.private_build_agent_subnet
}

output "secrets_subnet" {
  value = azurerm_subnet.secrets_subnet
}

output "audit_subnet" {
  value = azurerm_subnet.audit_subnet
}

output "data_subnet" {
  value = azurerm_subnet.data_subnet
}

/*output "firewall_subnet" {
  value = azurerm_subnet.firewall_subnet
}*/

output "data_subnet_network_security_group" {
  value = azurerm_network_security_group.data_nsg
}

output "secrets_subnet_network_security_group" {
  value = azurerm_network_security_group.secrets_nsg
}

output "audit_subnet_network_security_group" {
  value = azurerm_network_security_group.audit_nsg
}

output "nsg_ids" {
  value = {
    "data_nsg"    = azurerm_network_security_group.data_nsg.id
    "secrets_nsg" = azurerm_network_security_group.secrets_nsg.id
    "audit_nsg"   = azurerm_network_security_group.audit_nsg.id
  }
}

/* output "firewall" {
  value = module.firewall
}
*/


