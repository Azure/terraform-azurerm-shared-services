output "resource_group" {
  value = module.virtual_networking.resource_group
}

output "firewall_subnet" {
  value = module.virtual_networking.firewall_subnet
}

output "secrets_subnet" {
  value = module.virtual_networking.secrets_subnet
}

output "audit_subnet" {
  value = module.virtual_networking.audit_subnet
}

output "data_subnet" {
  value = module.virtual_networking.data_subnet
}

output "virtual_network" {
  value = module.virtual_networking.virtual_network
  depends_on = [
    module.virtual_networking.firewall_subnet,
    module.virtual_networking.secrets_subnet,
    module.virtual_networking.audit_subnet,
    module.virtual_networking.data_subnet
  ]
}



