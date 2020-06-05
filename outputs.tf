output "sec_resource_group" {
  value = module.security.resource_group
}

output "sec_key_vault" {
  value = module.security.key_vault
}

output "diag_resource_group" {
  value = module.audit_diagnostics.resource_group
}

output "diag_log_analytics_workspace" {
  value = module.audit_diagnostics.log_analytics_workspace
}

output "diag_event_hub_namespace" {
  value = module.audit_diagnostics.event_hub_namespace
}

output "diag_event_hubs" {
  value = module.audit_diagnostics.event_hubs
}

output "diag_storage_account" {
  value = module.audit_diagnostics.storage_account
}

output "net_resource_group" {
  value = module.network.resource_group
}

output "net_virtual_network" {
  value = module.network.virtual_network
}

output "net_firewall_subnet" {
  value = module.network.firewall_subnet
}

output "net_secrets_subnet" {
  value = module.network.secrets_subnet
}

output "net_audit_subnet" {
  value = module.network.audit_subnet
}



