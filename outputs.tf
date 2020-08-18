output "sec_resource_group" {
  value = module.security_package.resource_group
}

output "sec_key_vault" {
  value = module.security_package.key_vault
}

output "diag_resource_group" {
  value = module.audit_diagnostics_package.resource_group
}

output "diag_log_analytics_workspace" {
  value = module.audit_diagnostics_package.log_analytics_workspace
}

output "diag_event_hub_namespace" {
  value = module.audit_diagnostics_package.event_hub_namespace
}

output "diag_event_hubs" {
  value = module.audit_diagnostics_package.event_hubs
}

output "diag_storage_account" {
  value = module.audit_diagnostics_package.storage_account
}

output "net_resource_group" {
  value = module.virtual_network.resource_group
}

output "net_virtual_network" {
  value = module.virtual_network.virtual_network
}

/* output "net_firewall_subnet" {
  value = module.virtual_network.firewall_subnet
} */

output "net_secrets_subnet" {
  value = module.virtual_network.secrets_subnet
}

output "net_secrets_network_security_group" {
  value = module.virtual_network.secrets_subnet_network_security_group
}

output "net_audit_subnet" {
  value = module.virtual_network.audit_subnet
}

output "net_audit_network_security_group" {
  value = module.virtual_network.audit_subnet_network_security_group
}

output "net_data_subnet" {
  value = module.virtual_network.data_subnet
}

output "net_data_network_security_group" {
  value = module.virtual_network.data_subnet_network_security_group
}

output "data_storage_account" {
  value = module.persistent_data.storage_account
}
